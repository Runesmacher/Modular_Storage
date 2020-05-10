--Main class variable
Stockpile = {}
Stockpile.__index = Stockpile
--[[
stockpile = {
  +id = int,
  +tiles = {entity},
  +storedItems = {String},
  +inputs = {entity},
  +outputs  = {entity},
  +interfaces = {entity},
  +inventory_panels  = {entity},
  +controller = entity,
  +maxStorage = uint64_t,
  +PowerUsage = uint64_t,
  +LastChange = int,
  +LastScan = int,
  +enabled = boolean,
}

inputData  = {
  +stockpileID = int
}

outputData  = {
  +stockpileID = int,
  +enabled = boolean,
  +item1 = String,
  +item2 = String
}

inventoryPanelData  = {
  stockpileID, int
}

interfaceData  = {
  +stockpileID = int,
  +enabled = boolean,
  +items = {String}
}
]]--

--Global static variables
Stockpile.MAX_ITEM_COUNT = 2000000000
Stockpile.RESCAN_DELAY = 600
Stockpile.TILES_TICK = 100

--Global variables
Stockpile.Max_Tiles = 0

--Temporary variable
FoundTiles = 0

--Create new stockpile
function Stockpile:Create(controllerEntity)
    local this =
    {
        id = 0,
        tiles = {},
        storedItems = {},
        inputs = {},
        outputs  = {},
        interfaces = {},
        inventory_panels  = {},
        controller = controllerEntity,
        maxStorage = 0,
        powerUsage = 0,
        lastChange = 0,
        lastScan = 0,
        enabled = false
    }

    --Disable interaction with controller
    this.controller.operable = false

    setmetatable(this, Stockpile)
    return this
end

--Initialize stockpile with power and connected tiles
function Stockpile:Init()
    Entity.set_data(self.controller,{stockpileID = self.id})
    self:findConnectedTiles()
    self:reloadSettings()
end

function Stockpile:reloadSettings()
    --Recalculate from static variable
    Stockpile.Max_Tiles = Stockpile.MAX_ITEM_COUNT / settings.global["modular-storage-items-per-tile"].value

    --Update derivatives
    self:calcMaxStorageSpace()
    self:updatePowerNeed()
end

function Stockpile:calcMaxStorageSpace()
    self.maxStorage = Table.size(self.tiles) * settings.global["modular-storage-items-per-tile"].value
end

function Stockpile:calcPowerPerTick()
    return (settings.global["modular-storage-base-power"].value 
            + (Table.size(self.tiles) * settings.global["modular-storage-power-per-tile"].value) 
            + (Table.size(self.inputs) * settings.global["modular-storage-power-per-InOut"].value) 
            + (Table.size(self.outputs) * settings.global["modular-storage-power-per-InOut"].value) 
            + (Table.size(self.interfaces) * settings.global["modular-storage-power-per-interface"].value))
end

function Stockpile:updatePowerNeed()
    self.powerUsage = self:calcPowerPerTick()
    self.controller.electric_buffer_size = self.powerUsage * 120 --Buffer size will always be 2 seconds worth of power (given 1s = 60ticks)
end

function Stockpile:maxAddebleItemCount(countToAdd)
    local maxCountToAdd = self.maxStorage - self:getUsedStorageSpace(stockpileID)

    if maxCountToAdd >= countToAdd then
        return countToAdd
    else
        return maxCountToAdd
    end
end

function Stockpile:getUsedStorageSpace()
    local currStorageUsed = 0

    for itemName, itemCount in pairs(self.storedItems) do
        currStorageUsed = currStorageUsed + itemCount
    end

    return currStorageUsed
end

function Stockpile:rescan()
    -- Only rescan the stockpile when changes occured after last scan and last chang was more then 10sec ago 
    local tick = game.tick
    --When last scan was a minute ago
    if  (self.lastScan<self.lastChange) and ((tick - self.lastChange) > Stockpile.RESCAN_DELAY) then
        self:cleanStockpile()
        self:findConnectedTiles()        
        LOGGER.log("Stockpile rescanned tileCount= " .. Table.size(self.tiles))
    end
end

function Stockpile:findConnectedTiles()
    --Find all connected tiles, starting from the controller    
    resetVisited()
    self:findConnectedEntities (self.controller,nil)
    self:calcMaxStorageSpace()
    self:updatePowerNeed()
    self.lastScan = game.tick
end

function Stockpile:findConnectedTilesWithDelete (entityToDelete)
    --Find all connected tiles, starting from the controller while deleting current item
    resetVisited()
    FoundTiles = 0
    --Find all connected tiles
    self:findConnectedEntities(self.controller,entityToDelete)
    return FoundTiles * settings.global["modular-storage-items-per-tile"].value
end

function Stockpile:findConnectedEntities (entity,entityToDelete)
    if entity ~= entityToDelete and not isVisited(entity) then
        local nameToSearch = TILE_ENTITY

        if isGhost(entity) then
            nameToSearch = entity.name
        end

        if entity.name  == TILE_ENTITY and isVisited(entity) == false then
            --Only really add it when not only checking the size
            if entityToDelete == nil then
                self:addTile(entity)
            elseif not isGhost(entity) then
                --Only count tiles that are already placed
                FoundTiles = FoundTiles + 1
            end
        end

        setVisited(entity)

        local x = entity.position.x
        local y = entity.position.y

        --check y positive position
        local neighbor = entity.surface.find_entity(nameToSearch,{x, y + 1})
        if neighbor ~= nil and isVisited(neighbor) == false then
            self:findConnectedEntities(neighbor,entityToDelete)
        else
            self:checkConnectedIO(entity,{x, y + 1})
        end

        --check y negative position
        local neighbor = entity.surface.find_entity(nameToSearch,{x, y - 1})
        if neighbor ~= nil and isVisited(neighbor) == false then
            self:findConnectedEntities(neighbor,entityToDelete)
        else
            self:checkConnectedIO(entity,{x, y - 1})
        end

        --check x positive position
        local neighbor = entity.surface.find_entity(nameToSearch,{x + 1, y})
        if neighbor ~= nil and isVisited(neighbor)== false then
            self:findConnectedEntities(neighbor,entityToDelete)
        else
            self:checkConnectedIO(entity,{x + 1, y})
        end

        --check x negative position
        local neighbor = entity.surface.find_entity(nameToSearch,{x - 1, y})
        if neighbor ~= nil and isVisited(neighbor) == false then
            self:findConnectedEntities(neighbor,entityToDelete)
        else
            self:checkConnectedIO(entity,{x - 1, y})
        end
    end
end

function Stockpile:checkConnectedIO (stockpileEntity,positionToCheck)
    local foundEntities = stockpileEntity.surface.find_entities_filtered{position = positionToCheck}

    for _, en in pairs(foundEntities) do
        local foundID = getStockpileID(en)
        if en.name==INPUT_ENTITY then
            local translatedPosition = Position.translate(en.position, en.direction, 1)
            if Position.equals(translatedPosition, stockpileEntity.position) then
                self:addInput(en)
            end      
        elseif en.name==OUTPUT_ENTITY then
            local translatedPosition = Position.translate(en.position, en.direction, -1)
            if Position.equals(translatedPosition, stockpileEntity.position) then
                self:addOutput(en)
            end     
        elseif en.name==INTERFACE_ENTITY and (foundID == nil or foundID == self.id) then
            self:addInterface(en)
        elseif en.name==PANEL_ENTITY then
            local translatedPosition = Position.translate(en.position, en.direction, -1)
            if Position.equals(translatedPosition, stockpileEntity.position) then
                self:addInventoryPanel(en)
            end
        end
    end
end

function Stockpile:prepareTile(en)
    setStockpileID(en,self.id)
    self.lastChange = game.tick
end

function Stockpile:addTile(en)
    self:prepareTile(en)
    self.tiles[en.unit_number] = en
end

function Stockpile:removeTile(en)
    removeEntityFromTable(self.tiles, en)
    resetStockpileID(en)
    self.lastChange = game.tick
    LOGGER.log("Removed tile from stockPile. tilecount=" .. Table.size(self.tiles))
end

function Stockpile:addInput(en)
    setStockpileID(en,self.id)
    en.rotatable = false
    self.inputs[en.unit_number] = en
end

function Stockpile:addOutput(en)
    local data = Entity.get_data(en)
    if data == nil then
        Entity.set_data(en, {stockpileID = self.id, enabled = true , item1="", item2=""})
    else
        data.stockpileID = ID
        Entity.set_data(en,data)
    end
    en.rotatable = false
    self.outputs[en.unit_number] = en
end

function Stockpile:addInterface(en)
    local data = Entity.get_data(en)
    if data == nil then
        Entity.set_data(en, {stockpileID = self.id, enabled = true , items={}})
    else
        data.stockpileID = ID
        Entity.set_data(en,data)
    end
    self.interfaces[en.unit_number] = en
end

function Stockpile:addInventoryPanel(en)
    setStockpileID(en,self.id)
    en.rotatable = false
    en.operable = false
    self.inventory_panels[en.unit_number] = en
end

function Stockpile:cleanStockpile()
    Table.each(self.tiles, function(entity) resetStockpileID(entity) end)
    self.tiles = {}

    Table.each(self.inputs, function(entity) resetStockpileID(entity) end)
    self.inputs = {}

    Table.each(self.outputs, function(entity) resetStockpileID(entity) end)
    self.outputs = {}

    Table.each(self.interfaces, function(entity) resetStockpileID(entity) end)
    self.interfaces = {}

    Table.each(self.inventory_panels, function(entity) resetStockpileID(entity) end)
    self.inventory_panels = {}
end

function Stockpile:tick(event)
    --Rescan stockpile
    self:rescan()

    local enabled = false
    if self.controller ~= nil and self.controller.valid then
        if self.controller.energy < self.powerUsage then
            enabled = false
        else
            enabled = true
            self.controller.energy = self.controller.energy - self.powerUsage
        end
    else
        --Controller is gone somehow
        return false
    end

    --If power was OK
    if enabled then
        local gametick = game.tick

        --Handle input belts
        if Table.size(self.inputs) > 0 then
            Table.each(self.inputs, function(input)
                if input.valid then
                    for itemName, itemCount in pairs(input.get_transport_line(1).get_contents()) do
                        if self.storedItems[itemName] == nil then self.storedItems[itemName] = 0 end --Catch for nil
                        local maxCount = self:maxAddebleItemCount(itemCount)

                        if maxCount > 0 then
                            input.get_transport_line(1).remove_item({name=itemName, count=maxCount})
                            self.storedItems[itemName] = self.storedItems[itemName] + maxCount
                        end
                    end
                    for itemName, itemCount in pairs(input.get_transport_line(2).get_contents()) do
                        if self.storedItems[itemName] == nil then self.storedItems[itemName] = 0 end --Catch for nil
                        local maxCount = self:maxAddebleItemCount(itemCount)

                        if maxCount > 0 then
                            input.get_transport_line(2).remove_item({name=itemName, count=maxCount})
                            self.storedItems[itemName] = self.storedItems[itemName] + maxCount
                        end
                    end
                end
            end)
        end

        --Handle interfaces
        if Table.size(self.interfaces) > 0 then
            Table.each(self.interfaces, function(interface)
                if interface.valid then
                    local data = Entity.get_data(interface)
                    --Handle interface inputs
                    local contents = interface.get_inventory(defines.inventory.chest).get_contents()
                    for itemName, itemCount in pairs(interface.get_inventory(defines.inventory.chest).get_contents()) do
                        if self.storedItems[itemName] == nil then self.storedItems[itemName] = 0 end --Catch for nil
                        local maxCount = self:maxAddebleItemCount(itemCount)

                        if maxCount > 0 then
                            interface.get_inventory(defines.inventory.chest).remove({name=itemName, count=maxCount})
                            self.storedItems[itemName] = self.storedItems[itemName] + maxCount
                        end
                    end

                    --Handle interface output
                    if Table.size(data.items) > 0 and data.enabled then
                        local items = {}
                        for i = 1, Table.size(data.items) do
                            if items[data.items[i]] == nil then items[data.items[i]] = 0 end --Catch for nil
                            items[data.items[i]] = items[data.items[i]] + game.item_prototypes[data.items[i]].stack_size
                        end
                        
                        for itemName, itemCount in pairs(items) do
                            if self.storedItems[itemName] ~= nil and self.storedItems[itemName] > 0 then
                                local foundStoredItemCount = 0
                                for storedItemName, storedItemCount in pairs(interface.get_inventory(defines.inventory.chest).get_contents()) do
                                    if storedItemName == itemName then
                                        foundStoredItemCount = storedItemCount
                                    end
                                end

                                local itemsToAdd = itemCount - foundStoredItemCount
                                if itemsToAdd > 0 then
                                    local maxToAdd = 0
                                    if itemsToAdd >= self.storedItems[itemName]  then
                                        maxToAdd = self.storedItems[itemName] 
                                    else
                                        maxToAdd = itemsToAdd
                                    end

                                    if maxToAdd > 0 and self.storedItems[itemName] - maxToAdd >= 0 then
                                        local itemStack = {name=itemName, count=maxToAdd}

                                        if interface.get_inventory(defines.inventory.chest).can_insert(itemStack) then
                                            local insertedCount = interface.get_inventory(defines.inventory.chest).insert(itemStack)
                                            self.storedItems[itemName] = self.storedItems[itemName] - insertedCount
                                        end
                                    end
                                end
                            end
                        end
                    end

                end 
            end)
        end

        --Handle output belts
        if Table.size(self.outputs) > 0 then
            Table.each(self.outputs, function(output) 
                if output.valid then
                    local data = Entity.get_data(output)
                    if data.item1 ~= "" and data.enabled then
                        if self.storedItems[data.item1] == nil then self.storedItems[data.item1] = 0 end --Catch for nil
                        -- Fill the belt with selected item
                        line1 = output.get_transport_line(1)
                        if line1.can_insert_at(0.1) and self.storedItems[data.item1] > 0 then
                            if line1.insert_at(0.1,{name = data.item1}) then
                                self.storedItems[data.item1] = self.storedItems[data.item1] - 1
                            end
                        end
                    end

                    if data.item2 ~= "" and data.enabled then
                        if self.storedItems[data.item2] == nil then self.storedItems[data.item2] = 0 end --Catch for nil
                        -- Fill the belt with selected item
                        line2 = output.get_transport_line(2)
                        if line2.can_insert_at(0.1) and self.storedItems[data.item2] > 0 then
                            if line2.insert_at(0.1,{name = data.item2}) then
                                self.storedItems[data.item2] = self.storedItems[data.item2] - 1
                            end
                        end
                    end
                end            
            end)
        end

        --Update panels
        if Table.size(self.inventory_panels) > 0 and gametick % settings.global["modular-storage-circuit-update-rate"].value == 0 then      
            local signals = {}
            local spaceLeft = self.maxStorage - self:getUsedStorageSpace()
            --if spaceLeft > maxCount then spaceLeft = maxCount end

            local signalMax = self.maxStorage
            --if signalMax > maxCount then signalMax = maxCount end

            signals[1] = {index = 1, signal = {type = "virtual",name = "stocpile-space-left"},count = spaceLeft}
            signals[2] = {index = 2, signal = {type = "virtual",name = "stocpile-size"},count = signalMax }            

            local signalIndex = 3
            for k,v in pairs(self.storedItems) do
                if v > 0 then
                        signals[signalIndex] = {index = signalIndex, signal = {type = "item",name = k},count = v }
                        signalIndex = signalIndex+1
                    end
                end
            Table.each(self.inventory_panels, function(panel) 
                if panel.valid then
                    panel.get_control_behavior().parameters = {parameters=signals}
                end
            end)
        end
    end
    return true
end



-- Static functions (unknown stockpiles)

-- Recursively find connected blocks (depth-first search)
function removeController(event)
    local stockpileToRemove = Stockpiles.getStockpileByEntity(event.entity)

    --Check if empty   
    if stockpileToRemove:getUsedStorageSpace() == 0 then
        stockpileToRemove:cleanStockpile()
        Stockpiles.deleteStockpile(stockpileToRemove.id)
        return true
    else
        stockpileToRemove.controller = cancelRemove(event)
        Entity.set_data(stockpileToRemove.controller,{stockpileID = stockpileToRemove.id})
        setScreenErrorText(stockpileToRemove.controller.surface,"text.error-stockpile-not-empty",stockpileToRemove.controller.position)
        return false
    end
end
Stockpile.removeController = removeController
require 'stdlib/game'

Stockpile = {}

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
  +disabled = boolean,
}

inputData  = {
  +stockpileID = int
}

outputData  = {
  +stockpileID = int,
  +item1,
  +item2
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


local visited = {}

local function getPowerUsagePerTick(stockpile)
    return (settings.global["mudular-storage-base-power"].value + (#stockpile.tiles * settings.global["mudular-storage-stockpile-power"].value)) * (1/60) -- /60 for TPS
end

local function updatePowerNeed(stockpile)
    stockpile.controller.electric_buffer_size = getPowerUsagePerTick(stockpile) * 120 --Buffer size will always be 2 seconds worth of power
    --stockpile.controller.electric_input_flow_limit = getPowerUsagePerTick(stockpile) * 10 --Flow rate will always be 10 times more then the needed power
end

local function getMaxStorageSpace(stockpile)
    return #stockpile.tiles * settings.global["mudular-storage-items-per-tile"].value
end
Stockpile.getMaxStorageSpace = getMaxStorageSpace

local function getUsedStorageSpace(stockpile)
    local currStorageUsed = 0

    for itemName, itemCount in pairs(stockpile.storedItems) do
        currStorageUsed = currStorageUsed + itemCount
    end

    return currStorageUsed
end
Stockpile.getUsedStorageSpace = getUsedStorageSpace

local function cleanStockpile(stockpile)
    table.each(stockpile.tiles, function(entity)
        Entity.set_data(entity,nil)
    end)
    stockpile.tiles = {}

    table.each(stockpile.inputs, function(entity)
        Entity.set_data(entity,nil)
    end)
    stockpile.inputs = {}

    table.each(stockpile.outputs, function(entity)
        local data = Entity.get_data(entity)
        data.stockpileID = 0
        Entity.set_data(entity,data)
    end)
    stockpile.outputs = {}

    table.each(stockpile.interfaces, function(entity)
        local data = Entity.get_data(entity)
        data.stockpileID = 0
        Entity.set_data(entity,data)
    end)
    stockpile.interfaces = {}

    table.each(stockpile.inventory_panels, function(entity)
        Entity.set_data(entity,nil)
    end)
    stockpile.inventory_panels = {}
end
Stockpile.cleanStockpile = cleanStockpile

local function setVisited(entity)
    visited[entity.position.x .. "," .. entity.position.y] = true
end

local function isVisited(entity)
    return visited[entity.position.x .. "," .. entity.position.y] ~= nil
end

local function addInput(stockpile, en)
    Entity.set_data(en, { stockpileID = stockpile.id })
    en.rotatable = false
    table.insert(stockpile.inputs,en)
end
Stockpile.addInput = addInput

local function removeInput(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeElementFromTable(stockpile.inputs, en)
    end
end
Stockpile.removeInput = removeInput

local function addOutput(stockpile, en)
    local data = Entity.get_data(en)
    data.stockpileID = stockpile.id
    Entity.set_data(en, data)

    en.rotatable = false
    table.insert(stockpile.outputs,en)
end
Stockpile.addOutput = addOutput

local function removeOutput(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeElementFromTable(stockpile.outputs, en)
    end
end
Stockpile.removeOutput = removeOutput

local function addInterface(stockpile, en)
    local data = Entity.get_data(en)
    data.stockpileID = stockpile.id
    Entity.set_data(en, data)
    
    table.insert(stockpile.interfaces,en)
end
Stockpile.addInterface = addInterface

local function removeInterface(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeElementFromTable(stockpile.interfaces, en)
    end
end
Stockpile.removeInterface = removeInterface

local function addInventoryPanel(stockpile, en)
    Entity.set_data(en, { stockpileID = stockpile.id })
    en.rotatable = false
    en.operable = false
    table.insert(stockpile.inventory_panels,en)
end
Stockpile.addInventoryPanel = addInventoryPanel

local function removeInventoryPanel(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeElementFromTable(stockpile.inventory_panels, en)
    end
end
Stockpile.removeInventoryPanel = removeInventoryPanel

local function checkIOConnected (stockpile,stockpileEntity,positionToCheck)
    local foundEntities = stockpileEntity.surface.find_entities_filtered{position = positionToCheck} -- gets all resources in the rectangle

    for _, en in pairs(foundEntities) do
        if en.name=="input" then
            local translatedPosition = Position.translate(en.position, en.direction, 1)
            if Position.equals(translatedPosition, stockpileEntity.position) then
                addInput(stockpile, en)
            end      
        elseif en.name=="output" then
            local translatedPosition = Position.translate(en.position, en.direction, -1)
            if Position.equals(translatedPosition, stockpileEntity.position) then
                addOutput(stockpile, en)
            end     
        elseif en.name=="interface" then
            addInterface(stockpile, en)
        elseif en.name=="inventory-panel" then
            local translatedPosition = Position.translate(en.position, en.direction, -1)
            if Position.equals(translatedPosition, stockpileEntity.position) then
                addInventoryPanel(stockpile, en)
            end
        end
    end
end

-- Recursively find connected blocks (depth-first search)
local function searchNeighbour (stockpile,entity,entityToDelete)
    if entity ~= entityToDelete then
        if entity.name  ~= "controller" and isVisited(entity) == false then
            Entity.set_data(entity, { stockpileID = stockpile.id })
            table.insert(stockpile.tiles,entity)
        end

        setVisited(entity)

        local x = entity.position.x
        local y = entity.position.y

        --check y positive position
        local neighbor = entity.surface.find_entity('stockpileTile',{x, y + 1})
        if neighbor ~= nil and isVisited(neighbor) == false then
            searchNeighbour(stockpile,neighbor,entityToDelete)
        else
            checkIOConnected(stockpile,entity,{x, y + 1})
        end

        --check y negative position
        local neighbor = entity.surface.find_entity('stockpileTile',{x, y - 1})
        if neighbor ~= nil and isVisited(neighbor) == false then
            searchNeighbour(stockpile,neighbor,entityToDelete)
        else
            checkIOConnected(stockpile,entity,{x, y - 1})
        end

        --check x positive position
        local neighbor = entity.surface.find_entity('stockpileTile',{x + 1, y})
        if neighbor ~= nil and isVisited(neighbor)== false then
            searchNeighbour(stockpile,neighbor,entityToDelete)
        else
            checkIOConnected(stockpile,entity,{x + 1, y})
        end

        --check x negative position
        local neighbor = entity.surface.find_entity('stockpileTile',{x - 1, y})
        if neighbor ~= nil and isVisited(neighbor) == false then
            searchNeighbour(stockpile,neighbor,entityToDelete)
        else
            checkIOConnected(stockpile,entity,{x - 1, y})
        end

    end
end

local function searchTilesWithDelete (stockpile,en, entityToDelete)
    --Remove all entitys from stockpile
    cleanStockpile(stockpile)
    visited = {}

    --Find all connected tiles
    searchNeighbour (stockpile,en,entityToDelete)
    updatePowerNeed (stockpile)
    visited = nil
end
Stockpile.searchTilesWithDelete = searchTilesWithDelete

local function searchTiles (stockpile,en)
    searchTilesWithDelete (stockpile,en, nil)
end
Stockpile.searchTiles = searchTiles

local function newStockpile(controllerEntity)
    local stockpile = {}
    stockpile.tiles = {}
    stockpile.inputs = {}
    stockpile.outputs = {}
    stockpile.interfaces = {}
    stockpile.inventory_panels = {}
    stockpile.controller = controllerEntity
    stockpile.enabled = false
    stockpile.storedItems = {}
    
    local stockpiles = Stockpiles.getAll()
    if #stockpiles > 0 then
        local lastPile =  table.last(stockpiles)         
        stockpile.id = lastPile.id + 1
    else
        stockpile.id = 1
    end

    Entity.set_data(controllerEntity,{stockpileID = stockpile.id})

    updatePowerNeed(stockpile)
    searchTiles (stockpile,controllerEntity)
  return stockpile
end
Stockpile.newStockpile = newStockpile

local function maxCountToAdd(stockpile,countToAdd)
    local maxCountToAdd = getMaxStorageSpace(stockpile) - getUsedStorageSpace(stockpile)

    if maxCountToAdd >= countToAdd then
        return countToAdd
    else
        return maxCountToAdd
    end
end

local function tick(stockpile,event)
    local enabled = false
    if stockpile.controller ~= nil and stockpile.controller.valid then
        if stockpile.controller.energy == 0 then
            enabled = false
        else
            enabled = true
            stockpile.controller.energy = stockpile.controller.energy  - getPowerUsagePerTick(stockpile)
        end
    else
        return false
    end

    --If power was OK
    if enabled then
        local maxStorage = getMaxStorageSpace(stockpile)

        local inputs = stockpile.inputs
        local outputs = stockpile.outputs
        local interfaces = stockpile.interfaces
        local storedItems = stockpile.storedItems
        local inventory_panels = stockpile.inventory_panels

        --Handle input belts
        for j = 1, #inputs do
            if inputs[j].valid then
                for itemName, itemCount in pairs(inputs[j].get_transport_line(1).get_contents()) do
                    if storedItems[itemName] == nil then storedItems[itemName] = 0 end --Catch for nil
                    local maxCount = maxCountToAdd(stockpile,itemCount)

                    if maxCount > 0 then
                        inputs[j].get_transport_line(1).remove_item({name=itemName, count=maxCount})
                        storedItems[itemName] = storedItems[itemName] + maxCount
                    end
                end
                for itemName, itemCount in pairs(inputs[j].get_transport_line(2).get_contents()) do
                    if storedItems[itemName] == nil then storedItems[itemName] = 0 end --Catch for nil
                    local maxCount = maxCountToAdd(stockpile,itemCount)

                    if maxCount > 0 then
                        inputs[j].get_transport_line(2).remove_item({name=itemName, count=maxCount})
                        storedItems[itemName] = storedItems[itemName] + maxCount
                    end
                end
            end
        end

        --Handle interfaces (inputs)
        for j = 1, #interfaces do
            if interfaces[j].valid then
                local data = Entity.get_data(interfaces[j])
                if #data.items == 0 then
                    for itemName, itemCount in pairs(interfaces[j].get_inventory(defines.inventory.chest).get_contents()) do
                        if storedItems[itemName] == nil then storedItems[itemName] = 0 end --Catch for nil
                        local maxCount = maxCountToAdd(stockpile,itemCount)

                        if maxCount > 0 then
                            interfaces[j].get_inventory(defines.inventory.chest).remove({name=itemName, count=maxCount})
                            storedItems[itemName] = storedItems[itemName] + maxCount
                        end
                    end
                end
            end
        end

        --Handle output belts
        for j = 1, #outputs do
            if outputs[j].valid then
                local data = Entity.get_data(outputs[j])
                if data.item1 ~= "" and data.enabled then
                    if storedItems[data.item1] == nil then storedItems[data.item1] = 0 end --Catch for nil
                    -- Fill the belt with selected item
                    line1 = outputs[j].get_transport_line(1)
                    if line1.can_insert_at(0.1) and storedItems[data.item1] > 0 then
                        if line1.insert_at(0.1,{name = data.item1}) then
                            storedItems[data.item1] = storedItems[data.item1] - 1
                        end
                    end
                end

                if data.item2 ~= "" and data.enabled then
                    if storedItems[data.item2] == nil then storedItems[data.itesm2] = 0 end --Catch for nil
                    -- Fill the belt with selected item
                    line2 = outputs[j].get_transport_line(2)
                    if line2.can_insert_at(0.1) and storedItems[data.item2] > 0 then
                        if line2.insert_at(0.1,{name = data.item2}) then
                            storedItems[data.item2] = storedItems[data.item2] - 1
                        end
                    end
                end
            end
        end

        --Handle interfaces (outputs)
        local tick = game.tick
        if tick % settings.global["mudular-storage-interface-update-rate"].value == 0 then      
            for j = 1, #interfaces do
                if interfaces[j].valid then
                    local data = Entity.get_data(interfaces[j])
                    if #data.items > 0 and data.enabled then
                        local items = {}
                        for i = 1, #data.items do
                            if items[data.items[i]] == nil then items[data.items[i]] = 0 end --Catch for nil
                            items[data.items[i]] = items[data.items[i]] + game.item_prototypes[data.items[i]].stack_size
                        end
                        
                        for itemName, itemCount in pairs(items) do
                            if storedItems[itemName] ~= nil and storedItems[itemName] > 0 then
                                local foundStoredItemCount = 0
                                for storedItemName, storedItemCount in pairs(interfaces[j].get_inventory(defines.inventory.chest).get_contents()) do
                                    if storedItemName == itemName then
                                        foundStoredItemCount = storedItemCount
                                    end
                                end

                                local itemsToAdd = itemCount - foundStoredItemCount
                                if itemsToAdd > 0 then
                                    local maxToAdd = 0
                                    if itemsToAdd >= storedItems[itemName]  then
                                        maxToAdd = storedItems[itemName] 
                                    else
                                        maxToAdd = itemsToAdd
                                    end

                                    if maxToAdd > 0 and storedItems[itemName] - maxToAdd >= 0 then
                                        local itemStack = {name=itemName, count=maxToAdd}

                                        if interfaces[j].get_inventory(defines.inventory.chest).can_insert(itemStack) then
                                            local insertedCount = interfaces[j].get_inventory(defines.inventory.chest).insert(itemStack)
                                            storedItems[itemName] = storedItems[itemName] - insertedCount
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        --Update panels
        tick = game.tick
        if tick % settings.global["mudular-storage-circuit-update-rate"].value == 0 then      
            local signals = {}
            --Set max storage
            local maxCount = 2147483647 --Theoretical max of int         

            local spaceLeft = maxStorage - getUsedStorageSpace(stockpile)
            if spaceLeft > maxCount then spaceLeft = maxCount end

            local signalMax = maxStorage
            if signalMax > maxCount then signalMax = maxCount end

            signals[1] = {index = 1, signal = {type = "virtual",name = "stocpile-space-left"},count = spaceLeft}
            signals[2] = {index = 2, signal = {type = "virtual",name = "stocpile-size"},count = signalMax }            

            local signalIndex = 3
            for k,v in pairs(storedItems) do
                if v > 0 then
                    if v > maxCount then v = maxCount end
                        signals[signalIndex] = {index = signalIndex, signal = {type = "item",name = k},count = v }
                        signalIndex = signalIndex+1
                    end
                end
            for j = 1, #inventory_panels do
                if inventory_panels[j].valid then
                    inventory_panels[j].get_control_behavior().parameters = {parameters=signals}
                end
            end
        end
    end
    return true
end
Stockpile.tick = tick
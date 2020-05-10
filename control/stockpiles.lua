require 'control/stockpile'
Stockpiles = {}
--[[
stockpiles = {
  stockpile,
}
]]--

local stockpiles

local function init()
  if global.stockpiles == nil then
    global.stockpiles = {}
  end
    stockpiles = global.stockpiles

  Table.each(stockpiles,function(stockpile) setmetatable(stockpile,Stockpile) end)
end
Stockpiles.init = init

local function reloadSettings()
    Table.each(stockpiles, function(stockpile)
        stockpile:reloadSettings()
    end)
end
Stockpiles.reloadSettings = reloadSettings

function placeController(e)
    local en=e.created_entity
    local foundStockpiles = Stockpiles.findNeighbouringStockpiles(en)
    local stockipelesNoZero = Table.filter(foundStockpiles, function(v) return v.id ~=0 end)

    if #stockipelesNoZero > 0 then
        --Already a controller for this stockpile, remove
        setScreenErrorText(en.surface,"text.error-stockpile-controller-exists",en.position)
        cancelBuild(e)
        return false
    elseif isGhost(en) then
        return false
    else
        local stockpile = Stockpile:Create(en)
    
        --Add new stockpile to stockpiles table
        table.insert(stockpiles,stockpile)
        stockpile.id = #stockpiles
    
        --Set needed variables
        stockpile:Init();
        LOGGER.log("Addding controller to stockPile. Found ".. Table.size(stockpile.tiles) .. " tiles")
        return true
    end
end
Stockpiles.placeController = placeController

local function deleteStockpile(stockpileID)
    stockpiles[stockpileID] = nil
    return true;
end
Stockpiles.deleteStockpile = deleteStockpile

local function getAll()
    return stockpiles
end
Stockpiles.getAll = getAll

local function getStockpileByID (stockpileID)
    return stockpiles[stockpileID]
end
Stockpiles.getStockpileByID = getStockpileByID

local function getStockpileByEntity (en)
  local data = Entity.get_data(en)
    if data ~= nil then
        return getStockpileByID (data.stockpileID)
    end
end
Stockpiles.getStockpileByEntity = getStockpileByEntity

local function getStockpileIDAtLocation (surface,pos)
    foundEntities = surface.find_entities_filtered({position = pos})  
    for i, entity in pairs(foundEntities) do
        local stockpileID = getStockpileID(entity)
        if stockpileID ~= nil then
            return {id= stockpileID, entity= entity}
        elseif getEntityName(entity) == TILE_ENTITY then
            return {id= 0, entity= entity}
        end
    end
    return nil
end
Stockpiles.getStockpileIDAtLocation = getStockpileIDAtLocation

local function getStockpileAtLocation (surface,pos)
    foundEntities = surface.find_entities_filtered({position = pos})  
    for i, entity in pairs(foundEntities) do
        return Stockpiles.getStockpileByEntity (entity)
    end
    return nil
end
Stockpiles.getStockpileAtLocation = getStockpileAtLocation

local function getStockpileAtTileLocation (surface,pos)
    foundEntities = surface.find_entities_filtered({name= TILE_ENTITY, position = pos})  
    for i, entity in pairs(foundEntities) do
        return Stockpiles.getStockpileByEntity (entity)
    end
    return nil
end
Stockpiles.getStockpileAtTileLocation = getStockpileAtTileLocation

local function findNeighbouringStockpiles(en)
    local foundStockpiles = {}
    local x = en.position.x
    local y = en.position.y

    local stockpileID = getStockpileIDAtLocation (en.surface,{x,y+1})
    Table.insert(foundStockpiles,stockpileID)

    stockpileID = getStockpileIDAtLocation (en.surface,{x,y-1})
    Table.insert(foundStockpiles,stockpileID)

    stockpileID = getStockpileIDAtLocation (en.surface,{x+1,y})
    Table.insert(foundStockpiles,stockpileID)

    stockpileID = getStockpileIDAtLocation (en.surface,{x-1,y})
    Table.insert(foundStockpiles,stockpileID)
    
    return foundStockpiles
end
Stockpiles.findNeighbouringStockpiles = findNeighbouringStockpiles

local function tick(event)
    if stockpiles ~= nil and #stockpiles > 0 then  
        Table.each(stockpiles, function(stockpile)
            if not stockpile:tick(event) then
                stockpile = nil
            end
        end)
    end
end
Stockpiles.tick = tick

--Stockpile functions when the stockpile is not known
local function addTile(e)
    local en = e.created_entity
    local foundStockpiles = Stockpiles.findNeighbouringStockpiles(en)
    
    --Check if all are the same
    if #foundStockpiles == 0 then
        return false
    elseif areStockpilesTheSame(foundStockpiles,en) then
        return true
    else
        --Not all stockpiles are matching
        setScreenErrorText(en.surface,"text.error-stockpile-adjecent",en.position)
        cancelBuild(e)
        return false
    end
end
Stockpiles.addTile = addTile

local function removeTile(e)
    en = e.entity
    --Find stockpile this Tile belongs to
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil and not isGhost(en) then 
        --Remove tile (check from controller if there is still enough space for the current items)
        local storageSpaceAfterDelete = stockpile:findConnectedTilesWithDelete(en)

        if storageSpaceAfterDelete > stockpile:getUsedStorageSpace() then
            stockpile:removeTile(en)
        else
            --Not allowed to remove so place back
            en = cancelRemove(e)
            setScreenErrorText(en.surface,"text.error-stockpile-to-small",en.position)
        end
    end
end
Stockpiles.removeTile = removeTile

local function addInOut(e)
    local en = e.created_entity
    local name = getEntityName(en)
    local offset = 1
    local count = 0

    if name == OUTPUT_ENTITY then
        offset = -1
    end

    local positionToSearch = Position.translate(en.position, en.direction, offset)
    local stockpile =  Stockpiles.getStockpileAtTileLocation (en.surface,positionToSearch)
    if stockpile ~= nil then
        if beltAdjecentInterfering(en) then
            setScreenErrorText(en.surface,"text.error-cant-connect-belt",en.position)
            cancelBuild(e)
        elseif isGhost(en) then
            return false
        else
            if name == INPUT_ENTITY then
                stockpile:addInput(en)
                count = Table.size(stockpile.inputs)
            else
                stockpile:addOutput(en)
                count = Table.size(stockpile.outputs)
            end
            LOGGER.log("Addding " .. name .. " to stockPile. " .. name .. "count after add=" .. count)
            return true
        end
    else
        --setScreenErrorText(en.surface,"text.error-" .. name .. "-must-be-connected-to-stockpile",en.position)
        --cancelBuild(e)
    end
end
Stockpiles.addInOut = addInOut

local function removeInput(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeEntityFromTable(stockpile.inputs, en)
    end
end
Stockpiles.removeInput = removeInput

local function removeOutput(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeEntityFromTable(stockpile.outputs, en)
    end
end
Stockpiles.removeOutput = removeOutput

local function addInterface(e)
    local en = e.created_entity
    local foundStockpiles = Stockpiles.findNeighbouringStockpiles(en)

    if #foundStockpiles == 0 then
        setScreenErrorText(en.surface,"text.error-interface-must-be-connected-to-stockpile",en.position)
        cancelBuild(e)
        return false
    elseif areStockpilesTheSame(foundStockpiles,en) then            
        if isGhost(en) then
            return false
        else
            stockpiles[foundStockpiles[1].id]:addInterface(en)
            LOGGER.log("Addding interface to stockPile. interfacecount after add=" .. Table.size(stockpiles[foundStockpiles[1].id].interfaces))
            return true
        end
    else
        --Not all stockpiles are matching
        setScreenErrorText(en.surface,"text.error-stockpile-adjecent",en.position)
        cancelBuild(e)
        return false
    end
end
Stockpiles.addInterface = addInterface

local function removeInterface(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeEntityFromTable(stockpile.interfaces, en)
        LOGGER.log("Removed interface from stockPile. interface=" .. Table.size(stockpile.interfaces))
    end
end
Stockpiles.removeInterface = removeInterface

local function addInventoryPanel(e)
    local en = e.created_entity
    local positionToSearch = Position.translate(en.position, en.direction, -1)
        local stockpileID = Stockpiles.getStockpileIDAtLocation (en.surface,positionToSearch)
        if stockpileID ~= nil then
            if isGhost(en) then
                return false
            else
                stockpiles[stockpileID.id]:addInventoryPanel(en)
                LOGGER.log("Addding inventory panel to stockPile. interfacecount after add=" .. Table.size(stockpiles[stockpileID.id].inventory_panels))
                return true
            end
        else
            setScreenErrorText(en.surface,"text.error-inventory-panel-must-be-connected-to-stockpile",en.position)
            cancelBuild(e)
        end
end
Stockpiles.addInventoryPanel = addInventoryPanel

local function removeInventoryPanel(en)
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        removeEntityFromTable(stockpile.inventory_panels, en)
    end
end
Stockpiles.removeInventoryPanel = removeInventoryPanel
require 'control/stockpile'
Stockpiles = {}
--[[
stockpiles = {
  stocpile,
}
]]--

local stockpiles

local function init()
  if global.stockpiles == nil then
    global.stockpiles = {}
  end
    stockpiles = global.stockpiles
end
Stockpiles.init = init

local function getAll()
    return stockpiles
end
Stockpiles.getAll = getAll

local function getStockpileByID (stockpileID)
    for _, stockpile in pairs(stockpiles) do
        if stockpile.id == stockpileID then
            return stockpile
        end
    end
end
Stockpiles.GetStockpileByID = GetStockpileByID

local function getStockpileByEntity (en)
  local data = Entity.get_data(en)
    if data ~= nil then
        return getStockpileByID (data.stockpileID)
    end
end
Stockpiles.getStockpileByEntity = getStockpileByEntity

local function getStockpileAtLocation (surface,pos)
    local stockpile = nil
    foundEntities = surface.find_entities_filtered({position = pos})  

    for _, entity in pairs(foundEntities) do
        if entity.name == "stockpileTile" or entity.name == "controller" then
            local data = Entity.get_data(entity)
            if data ~= nil then
                return getStockpileByID(data.stockpileID)
            end
        end
    end
end
Stockpiles.getStockpileAtLocation = getStockpileAtLocation

local function add(controller)
    local stockpile = Stockpile.newStockpile(controller) 
    table.insert(stockpiles,stockpile)
end
Stockpiles.add = add

local function remove(e)
    local controller = e.entity
    local stockpile = getStockpileByEntity(controller)
    local data = Entity.get_data(controller)

    if stockpile ~= nil then
        if Stockpile.getUsedStorageSpace(stockpile) == 0 then
            Stockpile.cleanStockpile(stockpile)
            removeElementFromTable(stockpiles,stockpile)
            return true
        else
            stockpile.controller = cancelRemove(e)
            Entity.set_data(stockpile.controller,{stockpileID = stockpile.id})
            setScreenErrorText(stockpile.controller.surface,"text.error-stockpile-not-empty",stockpile.controller.position.x,stockpile.controller.position.y)
        end
    end
end
Stockpiles.remove = remove

local function findNeighbouringStockpiles(en)
    local foundStockpiles = {}
    local x = en.position.x
    local y = en.position.y

    local stockpile = getStockpileAtLocation (en.surface,{x,y+1})
    table.insert(foundStockpiles,stockpile)

    stockpile = getStockpileAtLocation (en.surface,{x,y-1})
    table.insert(foundStockpiles,stockpile)

    stockpile = getStockpileAtLocation (en.surface,{x+1,y})
    table.insert(foundStockpiles,stockpile)

    stockpile = getStockpileAtLocation (en.surface,{x-1,y})
    table.insert(foundStockpiles,stockpile)
    
    return foundStockpiles
end
Stockpiles.findNeighbouringStockpiles = findNeighbouringStockpiles

local function tick(event)
    if stockpiles ~= nil and #stockpiles > 0 then  
        table.each(stockpiles, function(stockpile)
            if not Stockpile.tick(stockpile,event) then
                stockpile = nil
            end
        end)
    end
end
Stockpiles.tick = tick

--entity.prototype.subgroup.name == "modularStorage"
--control.lua
Logger = require('__stdlib__/stdlib/misc/logger')
Position = require('__stdlib__/stdlib/area/position')
Entity = require('__stdlib__/stdlib/entity/entity')
table = require('__stdlib__/stdlib/utils/table')
local Direction = require('__stdlib__/stdlib/area/direction')
require 'control/stockpiles'

--LOGGER = Logger.new('modular_storage', 'debug', true, { log_ticks = true }) --Instant debug logging
LOGGER = Logger.new('modular_storage', 'main', false, { log_ticks = true }) --Normal logging

script.on_init(function(event)
    Stockpiles.init()
end)

script.on_load(function(event)
    Stockpiles.init()
end)

script.on_configuration_changed(function()
    --Do something here
end)

--Define events
script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity},function(event)
	  onEntityBuilt(event)
end)

script.on_event({defines.events.on_player_mined_entity,defines.events.on_robot_mined_entity},function(event)
	  onEntityMined(event)
end)
  
script.on_event(defines.events.on_tick,function(event)
	  Stockpiles.tick(event)
end)
  
script.on_event(defines.events.on_marked_for_deconstruction,function(event)
    if event.entity.name == "output" or event.entity.name == "interface" then
        local data = Entity.get_data(event.entity)
        data.enabled = false
        Entity.set_data(event.entity,data)
    end
end)
  
script.on_event(defines.events.on_cancelled_deconstruction,function(event)
    if event.entity.name == "output" or event.entity.name == "interface" then
        local data = Entity.get_data(event.entity)
        data.enabled = true
        Entity.set_data(event.entity,data)
    end
end)

--Custom event for changing items
script.on_event("change-output-item-1", function(event)
    changeOutput(1, event)
end)

script.on_event("change-output-item-2", function(event)
    changeOutput(2, event)
end)

script.on_event("change-interface-items", function(event)
    changeInterfaceItems(event)
end)

function changeOutput(side, event)
    local selection = game.players[event.player_index].selected
    if selection and selection.name == "output" then
        local outputData = Entity.get_data(selection)
        local ChangeTo = ""
        
        cursorStack = game.players[event.player_index].cursor_stack    
        if cursorStack ~= nil and cursorStack.valid_for_read then
            ChangeTo = cursorStack.name
        end

        if side == 1 then 
            outputData.item1 = ChangeTo
        else 
            outputData.item2 = ChangeTo
        end
        Entity.set_data(selection,outputData)
    end
end

function changeInterfaceItems(event)
    local selection = game.players[event.player_index].selected
    if selection and selection.name == "interface" then
        local interfaceData = Entity.get_data(selection)
        local ChangeTo = ""

        cursorStack = game.players[event.player_index].cursor_stack    
        if cursorStack ~= nil and cursorStack.valid_for_read then
            ChangeTo = cursorStack.name
        end

        if ChangeTo ~= "" then
            if #interfaceData.items < #selection.get_inventory(defines.inventory.chest) then
                table.insert(interfaceData.items,ChangeTo)
            else
                setScreenErrorText(selection.surface,"text.error-interface-to-many-items-selected",selection.position.x,selection.position.y)
            end
        else
            --Remove last entry from table
            local size = #interfaceData.items
            if size > 0 then
                table.remove(interfaceData.items,size)                
            end
        end
        
        Entity.set_data(selection,interfaceData)
    end
end
  
script.on_event(defines.events.on_entity_settings_pasted,function(event)
    if event.source.name == "output" and event.destination.name == "output" then
        local outputData_Source = Entity.get_data(event.source)
        local outputData_Destination = Entity.get_data(event.destination)

        outputData_Destination.item1 = outputData_Source.item1
        outputData_Destination.item2 = outputData_Source.item2

        Entity.set_data(event.destination,outputData_Destination)
    end
end)

function onEntityBuilt (e)
    local en=e.created_entity
    if en.name=='controller' then
        placeController(e)
    elseif en.name=="stockpileTile" then
        addTileToStockpile(e)
    elseif en.name=="input" then
        local positionToSearch = Position.translate(en.position, en.direction, 1)
        local stockpile = Stockpiles.getStockpileAtLocation (en.surface,positionToSearch)
        if stockpile ~= nil then
            Stockpile.addInput(stockpile,en)
            LOGGER.log("Addding input to stockPile. inputcount after add=" .. #stockpile.inputs)
        else
            setScreenErrorText(en.surface,"text.error-input-must-be-connected-to-stockpile",en.position.x,en.position.y)
            cancelBuild(e)
        end
    elseif en.name=="output" then
        local positionToSearch = Position.translate(en.position, en.direction, -1)
        local stockpile = Stockpiles.getStockpileAtLocation (en.surface,positionToSearch)
        if stockpile ~= nil then        
            Entity.set_data(en, {enabled = true , item1="", item2=""})
            Stockpile.addOutput(stockpile,en)
            LOGGER.log("Addding output to stockPile. outputcount after add=" .. #stockpile.outputs)
        else
            setScreenErrorText(en.surface,"text.error-output-must-be-connected-to-stockpile",en.position.x,en.position.y)
            cancelBuild(e)
        end
    elseif en.name=="interface" then
        local foundStockpiles = Stockpiles.findNeighbouringStockpiles(en)

        if #foundStockpiles == 1 then
            Entity.set_data(en, {enabled = true , items={}})
            Stockpile.addInterface(foundStockpiles[1], en)
            LOGGER.log("Addding interface to stockPile. interfacecount after add=" .. #foundStockpiles[1].interfaces)
        elseif #foundStockpiles > 1 then
            for i = 2, #foundStockpiles do
                if foundStockpiles[i] ~= foundStockpiles[i-1] then
                    --Not all stockpiles are matching
                    setScreenErrorText(en.surface,"text.error-stockpile-adjecent",x,y)
                    cancelBuild(e)
                end
            end
            Entity.set_data(en, {enabled = true , items={}})
            Stockpile.addInterface(foundStockpiles[1], en)
            LOGGER.log("Addding interface to stockPile. interfacecount after add=" .. #foundStockpiles[1].interfaces)
        else
            setScreenErrorText(en.surface,"text.error-interface-must-be-connected-to-stockpile",en.position.x,en.position.y)
            cancelBuild(e)
        end
    elseif en.name=="inventory-panel" then
        local positionToSearch = Position.translate(en.position, en.direction, -1)
        local stockpile = Stockpiles.getStockpileAtLocation (en.surface,positionToSearch)
        if stockpile ~= nil then
            Stockpile.addInventoryPanel(stockpile, en)
            LOGGER.log("Addding interface to stockPile. interfacecount after add=" .. #stockpile.inventory_panels)
        else
            setScreenErrorText(en.surface,"text.error-inventory-panel-must-be-connected-to-stockpile",en.position.x,en.position.y)
            cancelBuild(e)
        end
    end
end

function placeController(e)
    local en=e.created_entity
    local foundStockpiles = Stockpiles.findNeighbouringStockpiles(en)

    if #foundStockpiles > 0 then
        --Already a controller for this stockpile, remove
        setScreenErrorText(en.surface,"text.error-stockpile-controller-exists",en.position.x,en.position.y)
        cancelBuild(e)
        return false
    else
        Stockpiles.add(en)
        LOGGER.log("Addding controller to stockPile.")
    end
end

function onEntityMined (e)
    local en=e.entity
    if en.name=='controller' then
        Stockpiles.remove(e)
    elseif en.name=='stockpileTile' then
        removeTileFromStockPile(e)    
    elseif en.name=="input" then
        Stockpile.removeInput(en)
    elseif en.name=="output" then
        Stockpile.removeOutput(en)
    elseif en.name=="interface" then
        Stockpile.removeInterface(en)
    elseif en.name=="inventory-panel" then
        Stockpile.removeInventoryPanel(en)
    end
end

function cancelBuild(e)
    if e.robot ~= nil then -- IF placed by robot
        --Robot placed the item, schedule it for removal
        e.created_entity.order_deconstruction(e.robot.force)      
    else
        game.players[e.player_index].get_main_inventory().insert({name=e.created_entity.name,count=1})
        e.created_entity.destroy()
    end
end

function cancelRemove(e)
    if e.robot ~= nil then -- IF placed by robot
        e.robot.buffer.remove({name=e.entity.name,count=1})
    else
        game.players[e.player_index].remove_item({name=e.entity.name,count=1})
    end
    --Physicly put it back
    return e.entity.surface.create_entity{
        name = e.entity.name,
        position = e.entity.position,
        force=game.forces.player
    }
end

function removeElementFromTable(tab,el)
    table.remove(tab,tablefind(tab,el))
end

function tablefind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

function addTileToStockpile(e,en)
    if en == nil then en = e.created_entity end
    local foundStockpiles = Stockpiles.findNeighbouringStockpiles(en)

    x = en.position.x
    y = en.position.y

    --Check if all are the same
    if #foundStockpiles == 0 then
        return false
    elseif #foundStockpiles > 1 then
        for i = 2, #foundStockpiles do
            if foundStockpiles[i] ~= foundStockpiles[i-1] then
                --Not all stockpiles are matching
                setScreenErrorText(en.surface,"text.error-stockpile-adjecent",x,y)
                cancelBuild(e)
                return false
            end
        end
    end
    --If we get here, only one stockpile is found OR all stockpiles are the same
    Stockpile.searchTiles(foundStockpiles[1], en)
    LOGGER.log("Addding tile to stockPile. tilecount after add=" .. #foundStockpiles[1].tiles)
    return true
end

function removeTileFromStockPile(e)
    en = e.entity
    --Find stockpile this output belongs to
    stockpile = Stockpiles.getStockpileByEntity(en)

    if stockpile ~= nil then
        --Remove tile (Just recheck from controller)
        Stockpile.searchTilesWithDelete (stockpile, stockpile.controller,en)    
        if Stockpile.getUsedStorageSpace(stockpile) > Stockpile.getMaxStorageSpace(stockpile) then
            --Not allowed to remove so place back
            en = cancelRemove(e)
            Stockpile.searchTiles(stockpile,stockpile.controller)
            setScreenErrorText(en.surface,"text.error-stockpile-to-small",x,y)
        else
          LOGGER.log("Removed tile from stockPile. tilecount=" .. #stockpile.tiles)
        end
    end
end

function setScreenErrorText (surface,textkey,x,y)
    setScreenText (surface,textkey,x,y,{r = 255, g = 0, b = 0})
end

function setScreenText (surface,textkey,x,y,color)
    surface.create_entity{
        name = "flying-text",
        position = {x = x, y = y}, 
        color = color,
        text = {textkey}
    }
end
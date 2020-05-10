--control.lua
Logger = require('__stdlib__/stdlib/misc/logger')
Position = require('__stdlib__/stdlib/area/position')
Entity = require('__stdlib__/stdlib/entity/entity')
Table = require('__stdlib__/stdlib/utils/table')
require 'control/helperFunctions'
require 'control/stockpiles'

--LOGGER = Logger.new('debug', true, { log_ticks = true }) --Instant debug logging
LOGGER = Logger.new('main', false, { log_ticks = true }) --Normal logging

script.on_init(function(event)
    Stockpiles.init()
end)

script.on_load(function(event)
    Stockpiles.init()
end)

script.on_configuration_changed(function(data)
    if data and data.mod_changes["modular_storage"] then
        local oldVersion= data.mod_changes["modular_storage"].old_version
        local newVersion = data.mod_changes["modular_storage"].new_version
        LOGGER.log("mod versions have changed from v".. oldVersion .. " to v".. newVersion)

        --Update to new system
        if newVersion == "0.2.2" then
            if global.stockpiles ~= nil and #global.stockpiles > 0 then
                local oldStockpiles = CopyTable (global.stockpiles)
               
                --Clear stockpiles
                global.stockpiles = {}

                --Create new stockpiles
                Table.each(oldStockpiles, function(oldStockpile)
                    local stockpile = Stockpile:Create(oldStockpile.controller)
                    table.insert(global.stockpiles,stockpile)
                    stockpile.id = #global.stockpiles
                    Entity.set_data(stockpile.controller,{stockpileID = stockpile.id})
                
                    --Set needed variables
                    stockpile:Init()
                    stockpile:reloadSettings()
                    
                    --Rescan stockpile
                    stockpile.lastChange = game.tick

                    --Copy over items
                    stockpile.storedItems = CopyTable (oldStockpile.storedItems)
                end)
            end
            Stockpiles.init()
        end
    end
end)

--Define events
script.on_event(defines.events.on_runtime_mod_setting_changed,function(event)
    --When settings are changed
    Stockpiles.reloadSettings();
end)

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
    if event.entity.name == OUTPUT_ENTITY or event.entity.name == INTERFACE_ENTITY then
        local data = Entity.get_data(event.entity)
        data.enabled = false
        Entity.set_data(event.entity,data)
    end
end)
  
script.on_event(defines.events.on_cancelled_deconstruction,function(event)
    if event.entity.name == OUTPUT_ENTITY or event.entity.name == INTERFACE_ENTITY then
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
    if selection and selection.name == OUTPUT_ENTITY then
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
    if selection and selection.name == INTERFACE_ENTITY then
        local interfaceData = Entity.get_data(selection)
        local ChangeTo = ""

        cursorStack = game.players[event.player_index].cursor_stack    
        if cursorStack ~= nil and cursorStack.valid_for_read then
            ChangeTo = cursorStack.name
        end

        if ChangeTo ~= "" then
            if Table.size(interfaceData.items) < #selection.get_inventory(defines.inventory.chest) then
                Table.insert(interfaceData.items,ChangeTo)
            else
                setScreenErrorText(selection.surface,"text.error-interface-to-many-items-selected",selection.position)
            end
        else
            --Remove last entry from table
            local size = Table.size(interfaceData.items)
            if size > 0 then
                Table.remove(interfaceData.items,size)                
            end
        end
        
        Entity.set_data(selection,interfaceData)
    end
end
  
script.on_event(defines.events.on_entity_settings_pasted,function(event)
    if event.source.name == OUTPUT_ENTITY and event.destination.name == OUTPUT_ENTITY then
        local outputData_Source = Entity.get_data(event.source)
        local outputData_Destination = Entity.get_data(event.destination)

        outputData_Destination.item1 = outputData_Source.item1
        outputData_Destination.item2 = outputData_Source.item2

        Entity.set_data(event.destination,outputData_Destination)
    end
end)

function onEntityBuilt (e)
    local en = e.created_entity
    local name = getEntityName(en)
    if name==CONTROLLER_ENTITY then
        Stockpiles.placeController(e)
    elseif name==TILE_ENTITY then
        Stockpiles.addTile(e)
    elseif name==INPUT_ENTITY or name==OUTPUT_ENTITY then
        Stockpiles.addInOut(e)
    elseif name==INTERFACE_ENTITY then
        Stockpiles.addInterface(e)
    elseif name==PANEL_ENTITY then
        Stockpiles.addInventoryPanel(e)
    elseif type=="transport-belt" then
        local positionToSearch = Position.translate(en.position, en.direction, 1)
        foundEntities = en.surface.find_entities_filtered({position = positionToSearch})    
        for _, entity in pairs(foundEntities) do
            if (entity.name == INPUT_ENTITY and en.direction ~= entity.direction) or entity.name == OUTPUT_ENTIY then
                setScreenErrorText(en.surface,"text.error-cant-connect-belt",en.position)
                cancelBuild(e)
            end
        end
    end
end

function onEntityMined (e)
    local en=e.entity
    if en.name==CONTROLLER_ENTITY then
        Stockpile.removeController(e)
    elseif en.name==TILE_ENTITY then
        Stockpiles.removeTile(e)
    elseif en.name==INPUT_ENTITY then
        Stockpiles.removeInput(en)
    elseif en.name==OUTPUT_ENTITY then
        Stockpiles.removeOutput(en)
    elseif en.name==INTERFACE_ENTITY then
        Stockpiles.removeInterface(en)
    elseif en.name==PANEL_ENTITY then
        Stockpiles.removeInventoryPanel(en)
    end
end
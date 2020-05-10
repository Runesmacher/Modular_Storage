local Direction = require('__stdlib__/stdlib/area/direction')

--Global static variables
TILE_ENTITY = "modular-storage-stockpileTile"
CONTROLLER_ENTITY = "modular-storage-controller"
INPUT_ENTITY = "modular-storage-input"
OUTPUT_ENTITY = "modular-storage-output"
INTERFACE_ENTITY = "modular-storage-interface"
PANEL_ENTITY = "modular-storage-inventory-panel"

function setScreenText (surface,textkey,position,color)
    local flyingTexts = surface.find_entities_filtered{name = "flying-text", position = position, radius = 2}

    local exists = Table.any(flyingTexts,function(entity)
        return entity.text[1] == textkey
    end)
    
    if not exists then
        flyingText = surface.create_entity{
            name = "flying-text",
            position = position, 
            color = color,
            text = {textkey}
        }
    end
end

function setScreenErrorText (surface,textkey,position)
    setScreenText (surface,textkey,position,{r = 255, g = 0, b = 0})
end

function isGhost(en)
    return Entity.has(en,"ghost_name")
end

function getEntityName(en)
    --Get name of entity or the ghost
    if isGhost(en) then
        return en.ghost_name
    else
        return en.name
    end
end

function setStockpileID(entity,ID)
    local data = Entity.get_data(entity)
    if data == nil then        
        Entity.set_data(entity, { stockpileID = ID })
    else
        data.stockpileID = ID
        Entity.set_data(entity,data)
    end
end

function resetStockpileID(entity)
    if entity.valid then 
        setStockpileID(entity,nil) 
    end
end

function getStockpileID(entity)
    local data = Entity.get_data(entity)
    if data ~= nil then
        return data.stockpileID
    end
    return nil
end

function areStockpilesTheSame(foundStockpiles,en)
    if #foundStockpiles == 1 then
        if foundStockpiles[1].id ~= 0 then
            Stockpiles.getStockpileByID(foundStockpiles[1].id):prepareTile(en)
        end
        return true
    elseif #foundStockpiles > 1 then
        --Check if stockpiles are the same
        local stockipelesNoZero = Table.filter(foundStockpiles, function(v) return v.id ~=0 end)
        if #stockipelesNoZero > 1 then
            for i = 2, #stockipelesNoZero do
                if stockipelesNoZero[i].id ~= stockipelesNoZero[i-1].id then
                    return false
                end
            end
        end
        if #stockipelesNoZero >= 1 and en.name== TILE_ENTITY then
            --all are the same
            local stockipelesZero = Table.filter(foundStockpiles, function(v) return v.id ==0 end)
            if #stockipelesZero ~= 0 then
                --If connected to multiple tiles with no ID, update ID of those tiles
                resetVisited()
                for i = 1, #stockipelesZero do
                    --Start recursive function to find connected empty tiles
                    en = stockipelesZero[i].entity
                    if isVisited(en) == false then
                        findConnectedTiles (stockipelesNoZero[1].id,en)
                    end
                end
            else
                Stockpiles.getStockpileByID(stockipelesNoZero[1].id):prepareTile(en)
            end
        end
    end
    return true
end


function findConnectedTiles (stockpileID,entity)
    local nameToSearch = TILE_ENTITY

    if isGhost(entity) then
        nameToSearch = entity.name
    end

    --Check if already has an ID
    local ID = getStockpileID(entity)
    if ID ~= nil and ID ~= 0 then
        return true
    end

    if isVisited(entity) == false then
        Stockpiles.getStockpileByID(stockpileID):prepareTile(entity)
    end

    setVisited(entity)

    local x = entity.position.x
    local y = entity.position.y

    --check y positive position
    local neighbor = entity.surface.find_entity(nameToSearch,{x, y + 1})
    if neighbor ~= nil and isVisited(neighbor) == false then
        findConnectedTiles(stockpileID, neighbor)
    end

    --check y negative position
    local neighbor = entity.surface.find_entity(nameToSearch,{x, y - 1})
    if neighbor ~= nil and isVisited(neighbor) == false then
        findConnectedTiles(stockpileID, neighbor)
    end

    --check x positive position
    local neighbor = entity.surface.find_entity(nameToSearch,{x + 1, y})
    if neighbor ~= nil and isVisited(neighbor)== false then
        findConnectedTiles(stockpileID, neighbor)
    end

    --check x negative position
    local neighbor = entity.surface.find_entity(nameToSearch,{x - 1, y})
    if neighbor ~= nil and isVisited(neighbor) == false then
        findConnectedTiles(stockpileID, neighbor)
    end
end

function removeEntityFromTable(tab,en)
    tab[en.unit_number] = nil
end

function beltAdjecentInterfering(placedEntity)
    --Get sideways direction
    local direction = Direction.next_direction(placedEntity.direction)
    local positionToSearchPos = Position.translate(placedEntity.position, direction, 1)
    local positionToSearchNeg = Position.translate(placedEntity.position, direction, -1)

    if isBeltAtPositionAimedAtEntity(placedEntity,positionToSearchPos) then
        return true
    end
    if isBeltAtPositionAimedAtEntity(placedEntity,positionToSearchNeg) then
        return true
    end

    return false
end

function isBeltAtPositionAimedAtEntity(placedEntity,position)
    foundEntities = placedEntity.surface.find_entities_filtered({position=position,type="transport-belt"})    
    for _, entity in pairs(foundEntities) do
        if Position.translate(entity.position, entity.direction, 1) == Position.new(placedEntity.position) then
            return true
        end
    end
    return false
end


local visited = {}

function resetVisited()
    visited = {}
end

function setVisited(entity)
    visited[entity.position.x .. "," .. entity.position.y] = true
end

function isVisited(entity)
    return visited[entity.position.x .. "," .. entity.position.y] ~= nil
end

function cancelBuild(e)
    if isGhost(e.created_entity) then
        e.created_entity.destroy()
    else
        if e.robot ~= nil then -- IF placed by robot
            --Robot placed the item, schedule it for removal
            e.created_entity.order_deconstruction(e.robot.force)
        elseif e.created_entity.destroy() then
            game.players[e.player_index].cursor_stack.count = game.players[e.player_index].cursor_stack.count + 1;
        end
    end
end

function cancelRemove(e)
    local en = e.entity
    local data = Entity.get_data(en)
    if e.robot ~= nil then -- IF picked up by robot
        e.buffer.remove({name=en.name,count=1})
    else
        game.players[e.player_index].remove_item({name=en.name,count=1})
    end
    --Physicly put it back
    replacedEntity = en.surface.create_entity{
        name = en.name,
        position = en.position,
        force=game.forces.player
    }
    Entity.set_data(replacedEntity,data)
    return replacedEntity
end

function CopyTable (oldTable)
    local newTable = {}
    for k,v in pairs(oldTable) do
        newTable[k] = v
    end
    return newTable
end
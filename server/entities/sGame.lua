---@class SGame
---@field core TPNRPServer Core
---@field entities table<string, TEntity> Dictionary of entities managed by sGame, keyed by entityId
SGame = {}
SGame.__index = SGame

---@param core TPNRPServer Core
---@return SGame
function SGame.new(core)
    ---@class SGame
    local self = setmetatable({}, SGame)

    -- Core
    self.core = core

    ---@type table<string, TEntity>
    self.entities = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Spawn static mesh
    ---@param params TSpawnStaticMeshParams
    ---@return {status:boolean; entityId:string; entity:unknown} returnValue 
    function self:spawnStaticMesh(params)
        local spawnPosition = params.position
        local spawnRotation = params.rotation
        local spawnScale = params.scale
        local entityPath = params.entityPath or ''

        if entityPath == '' then
            print('[ERROR] SGame.SPAWN_STATIC_MESH - Entity path is empty!')
            return {
                status = false,
                entityId = nil,
                entity = nil,
            }
        end

        local entity = StaticMesh(spawnPosition, spawnRotation, entityPath, ECollisionType.StaticOnly)
        if not entity then
            print('[ERROR] SGame.SPAWN_STATIC_MESH - Failed to spawn static mesh!')
            return {
                status = false,
                entityId = nil,
                entity = nil,
            }
        end
        entity:SetActorScale3D(spawnScale)
        local entityId = string.format('sm-%d', self.core.shared.randomId(6))

        -- Push entity to list for manage later
        self.entities[entityId] = {
            id = entityId,
            entity = entity,
            isInteractable = false,
        }

        return {
            status = true,
            entityId = entityId,
            entity = entity,
        }
    end
    
    ---Add interactable to entity
    ---@param params TAddInteractableParams
    ---@return {status:boolean} returnValue 
    function self:addInteractable(params)
        local entity = params.entity
        local options = params.options
        if not entity or not options then
            print('[ERROR] SGame.ADD_INTERACTABLE - Entity or options is empty!')
            return {
                status = false,
            }
        end

        local entityInteractable = Interactable({
            options,
        })

        -- Attach the interactable to our existing cube
        entityInteractable:SetInteractableProp(entity)

        -- Update entity interactable
        self.entities[entity.id].isInteractable = true

        return {
            status = true,
        }
    end

    ---Destroy entity
    ---@param id string Entity id
    ---@return {status:boolean} returnValue 
    function self:destroyEntity(id)
        local entity = self.entities[id]
        if not entity then
            print('[ERROR] SGame.DESTROY_ENTITY - Entity not found!')
            return {
                status = false,
            }
        end

        -- Destroy entity
        -- TODO: Need to destroy entity and Interactable
        -- self.entities[id].entity:Destroy()

        -- Remove entity from list
        self.entities[id] = nil

        return {
            status = true,
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SGame

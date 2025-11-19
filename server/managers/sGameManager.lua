---@class SGameManager
---@field core TPNRPServer Core
---@field entities table<string, TEntity> Dictionary of entities managed by SGameManager, keyed by entityId
SGameManager = {}
SGameManager.__index = SGameManager

---@param core TPNRPServer Core
---@return SGameManager
function SGameManager.new(core)
    ---@class SGameManager
    local self = setmetatable({}, SGameManager)

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
    ---@return {status:boolean; entityId:string; entity:unknown; message: string} returnValue 
    function self:spawnStaticMesh(params)
        local spawnPosition = params.position
        local spawnRotation = params.rotation
        local spawnScale = params.scale
        local entityPath = params.entityPath or ''

        if entityPath == '' then
            print('[ERROR] SGameManager.SPAWN_STATIC_MESH - Entity path is empty!')
            return {
                status = false,
                entityId = nil,
                entity = nil,
                message = 'Entity path is empty!',
            }
        end

        local entity = StaticMesh(spawnPosition, spawnRotation, entityPath, ECollisionType.StaticOnly)
        if not entity then
            print('[ERROR] SGameManager.SPAWN_STATIC_MESH - Failed to spawn static mesh!')
            return {
                status = false,
                entityId = nil,
                entity = nil,
                message = 'Failed to spawn static mesh!',
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
            message = 'Static mesh spawned successfully!',
        }
    end
    
    ---Add interactable to entity
    ---@param params TAddInteractableParams
    ---@return {status:boolean; message: string} returnValue 
    function self:addInteractable(params)
        local entity = params.entity
        local options = params.options
        if not entity or not options then
            print('[ERROR] SGameManager.ADD_INTERACTABLE - Entity or options is empty!')
            return {
                status = false,
                message = 'Entity or options is empty!',
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
            message = 'Interactable added successfully!',
        }
    end

    ---Destroy entity
    ---@param id string Entity id
    ---@return {status:boolean; message:string } returnValue 
    function self:destroyEntity(id)
        local entity = self.entities[id]
        if not entity then
            print('[ERROR] SGameManager.DESTROY_ENTITY - Entity not found!')
            return {
                status = false,
                message = 'Entity not found!',
            }
        end

        -- Destroy entity
        -- TODO: Need to destroy entity and Interactable
        -- self.entities[id].entity:Destroy()

        -- Remove entity from list
        self.entities[id] = nil

        return {
            status = true,
            message = 'Entity destroyed successfully!',
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SGameManager

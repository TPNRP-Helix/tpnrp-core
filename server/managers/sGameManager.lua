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
        local collisionType = params.collisionType or ECollisionType.StaticOnly
        local mobilityType = params.mobilityType or EMobilityType.Stationary

        if entityPath == '' then
            return {
                status = false,
                entityId = nil,
                entity = nil,
                message = 'Entity path is empty!',
            }
        end

        local entity = StaticMesh(spawnPosition, spawnRotation, entityPath, collisionType)
        if not entity then
            return {
                status = false,
                entityId = nil,
                entity = nil,
                message = 'Failed to spawn static mesh!',
            }
        end
        entity:SetActorScale3D(Vector(spawnScale.x, spawnScale.y, spawnScale.z))
        entity:SetMobility(mobilityType)
        local entityId = SHARED.randomId(3) .. '-' .. SHARED.randomInt(11111,99999)
        -- Push entity to list for manage later
        self.entities[entityId] = {
            id = entityId,
            entity = entity,
            isInteractable = false,
            interactableEntity = nil,
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
        local entityId = params.entityId
        local entity = params.entity
        local options = params.options
        if not entity or not options then
            return {
                status = false,
                message = 'Entity or options is empty!',
            }
        end
        local entityInteractable = Interactable(options)
        -- Attach the interactable to our existing cube
        entityInteractable:SetInteractableProp(entity)
        entityInteractable.BoxCollision:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Pawn, UE.ECollisionResponse.ECR_Overlap)
        if self.entities[entityId] then
            -- Update entity interactable
            self.entities[entityId].isInteractable = true
            self.entities[entityId].interactableEntity = entityInteractable
        end
        
        return {
            status = true,
            message = 'Interactable added successfully!',
        }
    end

    ---Destroy entity
    ---@param id string Entity id
    ---@return {status:boolean; message:string } returnValue 
    function self:destroyEntity(id)
        local object = self.entities[id]
        if not object then
            return {
                status = false,
                message = 'Object not found!',
            }
        end
        -- Destroy entity and interactable
        if object.entity then DeleteEntity(object.entity) end
        if object.interactableEntity then DeleteEntity(object.interactableEntity) end
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

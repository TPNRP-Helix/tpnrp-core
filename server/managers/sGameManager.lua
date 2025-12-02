---@class SGameManager
---@field core TPNRPServer Core
SGameManager = {}
SGameManager.__index = SGameManager

---@param core TPNRPServer Core
---@return SGameManager
function SGameManager.new(core)
    ---@class SGameManager
    local self = setmetatable({}, SGameManager)

    -- Core
    self.core = core

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        RegisterCallback('requestPlayerNearBy', function(source, data)
            return self:requestPlayerNearBy(source, data)
        end)
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Create random id
    ---@param type 'bag_item' | 'entity' | nil type of id
    ---@return string random id
    function self:createId(type)
        local randomId = SHARED.randomId(3) .. '-' .. SHARED.randomInt(11111,99999)
        if type == 'bag_item' then
            return SHARED.randomId(3) .. '-' .. randomId
        end

        return randomId
    end

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
        local entityId = params.containerId or self:createId()

        return {
            status = true,
            entityId = entityId,
            entity = entity,
            message = 'Static mesh spawned successfully!',
        }
    end
    
    ---Add interactable to entity
    ---@param params TAddInteractableParams
    ---@return {status:boolean; message: string; interactableEntity: unknown|nil} returnValue 
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
        
        return {
            status = true,
            message = 'Interactable added successfully!',
            interactableEntity = entityInteractable,
        }
    end

    ---Request player near by
    ---@param source PlayerController source id
    ---@param data {radius: number} radius in meter
    ---@return {status:boolean, message:string, players:table} returnValue 
    function self:requestPlayerNearBy(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = 'Player not found!',
            }
        end
        local playerCoords = player:getCoords()
        local playersInArea = GetPlayersInArea(playerCoords, data.radius or 5)
        local players = {}
        for _, playerId in pairs(playersInArea) do
            print('playerId', playerId)
        end
        return {
            status = true,
            message = 'Players near by requested successfully!',
            players = players,
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SGameManager

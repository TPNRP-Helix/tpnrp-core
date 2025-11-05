---@class CPlayer
---@field playerData PlayerData|nil
---@field inventory CInventory|nil
CPlayer = {}
CPlayer.__index = CPlayer

---@return CPlayer
function CPlayer.new(playerSource)
    ---@class CPlayer
    local self = setmetatable({}, CPlayer)

    -- Player's fields
    self.playerSource = playerSource
    self.playerData = nil
    -- Player's Stacks
    self.inventory = nil

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- Get player's inventory
        self.inventory = CInventory.new(self)
        -- On Update playerData
        ---@param playerData PlayerData
        RegisterClientEvent('TPN:player:updatePlayerData', function(playerData)
            self.playerData = playerData
        end)
    end

    /********************************/
    /*           Player             */
    /********************************/

    ---Get player coords
    ---@return Vector3 coords Player's coords
    function self:getCoords()
        local ped = self.playerSource:K2_GetPawn()
        if ped then
            return ped:K2_GetActorLocation()
        end
        -- Default coords from config
        return SHARED.DEFAULT.SPAWN.POSITION
    end

    ---Get player heading
    ---@return number heading Player's heading
    function self:getHeading()
        local ped = self.playerSource:K2_GetPawn()
        if ped then
            return ped:K2_GetActorRotation().Yaw
        end
        -- Default heading from config
        return SHARED.DEFAULT.SPAWN.HEADING
    end

    /********************************/
    /*          Functions           */
    /********************************/
    

    _contructor()
    ---- END ----
    return self
end

return CPlayer

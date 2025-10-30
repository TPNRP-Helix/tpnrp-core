---@class SPlayer
---@field playerData PlayerData|nil
---@field inventories SInventory|nil
SPlayer = {}
SPlayer.__index = SPlayer

---@return SPlayer
function SPlayer.new(playerSource, playerLicense)
    ---@class SPlayer
    local self = setmetatable({}, SPlayer)

    -- Public
    self.playerSource = playerSource
    self.license = playerLicense
    self.playerData = nil
    self.inventories = nil

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- Get player data
        self.playerData = DAO.getPlayer(self.playerData.citizen_id)
        -- Get player inventory
        self.inventories = SInventory.new(self)
    end

    /********************************/
    /*           Player             */
    /********************************/

    ---Save player
    ---@return boolean success is save success or not
    function self:save()
        if not self.playerData then
            print('[ERROR] SPLAYER.SAVE - playerData is empty!')
            return false
        end

        -- Save player data
        local isSaved = DAO.savePlayer(self)
        local isInventoriesSaved = self.inventories:save()
        if not isSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player!')
        end

        if not isInventoriesSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player inventories!')
        end

        return isSaved and isInventoriesSaved
    end

    ---Get player coords
    ---@return Vector3 coords Player's coords
    function self:getCoords()
        local ped = self.playerSource:K2_GetPawn()
        if ped then
            return ped:K2_GetActorLocation()
        end
        -- Default coords from config
        return SHARED.CONFIG.DEFAULT_SPAWN.POSITION
    end

    ---Get player heading
    ---@return number heading
    function self:getHeading()
        local ped = self.playerSource:K2_GetPawn()
        if ped then
            return ped:K2_GetActorRotation().Yaw
        end
        -- Default heading from config
        return SHARED.CONFIG.DEFAULT_SPAWN.HEADING
    end

    /********************************/
    /*          Functions           */
    /********************************/

    ---**Update playerData**
    --
    ---Sync playerData to client-side
    function self:UpdatePlayerData()
        TriggerClientEvent('TPN:player:updatePlayerData', self.playerSource, self.playerData)
    end

    _contructor()
    ---- END ----
    return self
end

return SPlayer
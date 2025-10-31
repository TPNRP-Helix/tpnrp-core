---@class SPlayer
---@field playerData PlayerData|nil
---@field inventories SInventory|nil
SPlayer = {}
SPlayer.__index = SPlayer

---@return SPlayer
function SPlayer.new(playerSource)
    ---@class SPlayer
    local self = setmetatable({}, SPlayer)

    -- Player's fields
    self.playerSource = playerSource
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
        local isSaved = DAO.player.save(self)
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
    function self:updatePlayerData()
        TriggerClientEvent('TPN:player:updatePlayerData', self.playerSource, self.playerData)
    end

    ---On Player logged in
    function self:login()
        local playerData = DAO.player.get(self.playerData.citizen_id)
        if not playerData then
            print('[ERROR] SPLAYER.LOGIN - playerData is empty!')
            return false
        end
        -- Assign playerData
        self.playerData = playerData
        playerData.source = self.playerSource
        -- Get player state
        local PlayerState = self.playerSource:GetLyraPlayerState()
        playerData.netId = PlayerState:GetPlayerId()
        playerData.license = PlayerState:GetHelixUserId()
        playerData.name = PlayerState:GetPlayerName()
    end

    ---Logout player
    function self:logout()
        -- This will broadcast the event to all other resources in client-side
        TriggerClientEvent('TPN:client:onPlayerUnloaded', self.playerSource)
        -- This will broadcast the event to all other resources in server-side
        TriggerLocalServerEvent('TPN:server:onPlayerUnloaded', self.playerSource)

        -- Wait for 200ms to ensure the player is logged out
        Wait(200)
        -- Save player data into database
        local isSaved = self:save()
        if not isSaved then
            print('[ERROR] SPLAYER.LOGOUT - Failed to save player data!')
        end
        -- Remove player from players table
        TPNRPServer.players[self.playerSource] = nil
    end

    _contructor()
    ---- END ----
    return self
end

return SPlayer
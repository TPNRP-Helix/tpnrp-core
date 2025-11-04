---@class SPlayer
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment SEquipment|nil
SPlayer = {}
SPlayer.__index = SPlayer

---@return SPlayer
function SPlayer.new(playerSource)
    ---@class SPlayer
    local self = setmetatable({}, SPlayer)

    -- Player's fields
    self.playerSource = playerSource
    self.playerData = nil
    -- Player's Stacks
    self.inventory = nil
    self.equipment = nil

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- Get player data
        self.playerData = DAO.getPlayer(self.playerData.citizen_id)
        
        -- Get player's inventory
        self.inventory = SInventory.new(self)
        -- Load player's inventory for this player
        self.inventory:load('player')

        -- Get player's equipment
        self.equipment = SEquipment.new(self)
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
        local isInventoriesSaved = self.inventory:save()
        local isEquipmentsSaved = self.equipment:save()
        if not isSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player!')
        end

        if not isInventoriesSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player inventories!')
        end

        if not isEquipmentsSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player equipment!')
        end

        return isSaved and isInventoriesSaved and isEquipmentsSaved
    end

    ---Get player coords
    ---@return Vector3 coords Player's coords
    function self:getCoords()
        local ped = GetPlayerPawn(self.playerSource)
        if ped then
            return GetEntityCoords(ped)
        end
        -- Default coords from config
        return SHARED.CONFIG.DEFAULT_SPAWN.POSITION
    end

    ---Get player heading
    ---@return number heading
    function self:getHeading()
        local ped = GetPlayerPawn(self.playerSource)
        if ped then
            return GetEntityRotation(ped).Yaw
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
        -- Get player state
        local PlayerState = self.playerSource:GetLyraPlayerState()
        -- Get player data from database
        local playerData = DAO.player.get(self.playerData.citizen_id)
        if not playerData then
            -- User first time login, create new player data
            playerData = {
                money = {},
                character_info = {},
                job = {},
                gang = {},
                position = SHARED.CONFIG.DEFAULT_SPAWN.POSITION,
                metadata = {},
                source = self.playerSource,
                license = PlayerState:GetHelixUserId(),
                name = PlayerState:GetPlayerName(),
                character_id = 0,
                citizen_id = SHARED.createCitizenId(),
            }
        end
        -- Assign playerData
        self.playerData = playerData
        self.playerData.source = self.playerSource
        -- Assign Helix data to playerData
        self.playerData.netId = PlayerState:GetPlayerId()
        self.playerData.license = PlayerState:GetHelixUserId()
        self.playerData.name = PlayerState:GetPlayerName()
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
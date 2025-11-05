---@class SPlayer
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment SEquipment|nil
---@field level SLevel|nil
SPlayer = {}
SPlayer.__index = SPlayer

---@return SPlayer
function SPlayer.new(playerController)
    ---@class SPlayer
    local self = setmetatable({}, SPlayer)

    -- Player's controller
    self.playerController = playerController
    -- Player's data
    self.playerData = nil
    -- Player's level
    self.level = nil
    -- Player's inventory
    self.inventory = nil
    -- Player's equipment
    self.equipment = nil

    -- Player's custom properties
    self.properties = {}
    -- Player's custom methods
    self.methods = {}

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- Get player data
        self.playerData = DAO.getPlayer(self.playerData.citizen_id)
        -- Get player's level
        self.level = SLevel.new(self)
        -- Get player's inventory
        self.inventory = SInventory.new(self, 'player')
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
        local isLevelSaved = self.level:save()
        if not isSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player!')
        end

        if not isInventoriesSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player inventories!')
        end

        if not isEquipmentsSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player equipment!')
        end

        if not isLevelSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player level!')
        end
        -- Return true if all save success
        return isSaved and isInventoriesSaved and isEquipmentsSaved and isLevelSaved
    end

    ---Get player coords
    ---@return Vector3 coords Player's coords
    function self:getCoords()
        local ped = GetPlayerPawn(self.playerController)
        if ped then
            return GetEntityCoords(ped)
        end
        -- Default coords from config
        return SHARED.DEFAULT.SPAWN.POSITION
    end

    ---Get player heading
    ---@return number heading
    function self:getHeading()
        local ped = GetPlayerPawn(self.playerController)
        if ped then
            return GetEntityRotation(ped).Yaw
        end
        -- Default heading from config
        return SHARED.DEFAULT.SPAWN.HEADING
    end

    /********************************/
    /*          Functions           */
    /********************************/

    ---**Update playerData**
    --
    ---Sync playerData to client-side
    function self:updatePlayerData()
        TriggerClientEvent(self.playerController, 'TPN:player:updatePlayerData', self.playerData, self.properties)
    end

    ---On Player logged in
    function self:login()
        -- Get player state
        local PlayerState = self.playerController:GetLyraPlayerState()
        -- Get player data from database
        local playerData = DAO.player.get(self.playerData.citizen_id)
        if not playerData then
            -- User first time login, create new player data
            playerData = {
                money = {},
                character_info = {},
                job = {},
                gang = {},
                position = SHARED.DEFAULT.SPAWN.POSITION,
                metadata = {},
                source = self.playerController,
                license = PlayerState:GetHelixUserId(),
                name = PlayerState:GetPlayerName(),
                character_id = 0,
                citizen_id = SHARED.createCitizenId(),
            }
        end
        -- Assign playerData
        self.playerData = playerData
        self.playerData.source = self.playerController
        -- Assign Helix data to playerData
        self.playerData.netId = PlayerState:GetPlayerId()
        self.playerData.license = PlayerState:GetHelixUserId()
        self.playerData.name = PlayerState:GetPlayerName()
    end

    ---Logout player
    function self:logout()
        -- This will broadcast the event to all other resources in client-side
        TriggerClientEvent(self.playerController, 'TPN:client:onPlayerUnloaded')
        -- This will broadcast the event to all other resources in server-side
        TriggerLocalServerEvent('TPN:server:onPlayerUnloaded', self.playerController)

        -- Wait for 200ms to ensure the player is logged out
        Wait(200)
        -- Save player data into database
        local isSaved = self:save()
        if not isSaved then
            print('[ERROR] SPLAYER.LOGOUT - Failed to save player data!')
        end
        -- Remove player from players table
        TPNRPServer.players[self.playerController] = nil
    end

    ---Add custom method to player
    ---@param methodName string method name
    ---@param methodFunction function method function
    function self:addMethod(methodName, methodFunction)
        self.methods[methodName] = methodFunction
    end

    ---Add custom property to player
    ---@param propertyName string property name
    ---@param propertyValue any property value
    function self:addProperty(propertyName, propertyValue)
        self.properties[propertyName] = propertyValue
    end

    _contructor()
    ---- END ----
    return self
end

return SPlayer

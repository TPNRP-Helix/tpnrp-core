---@class SPlayer
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment SEquipment|nil
---@field level SLevel|nil
SPlayer = {}
SPlayer.__index = SPlayer

--- Creates a new instance of SPlayer.
---@param core TPNRPServer core entity
---@param playerController PlayerController player controller
---@param playerData PlayerData player data
---@return SPlayer
function SPlayer.new(core, playerController, playerData)
    ---@class SPlayer
    local self = setmetatable({}, SPlayer)

    self.core = core
    -- Player's controller
    self.playerController = playerController
    -- Player's data
    self.playerData = playerData
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

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- Get player data
        self:login()
        -- Get player's level
        self.level = SLevel.new(self)
        -- Get player's inventory
        self.inventory = SInventory.new(self, 'player')
        -- Get player's equipment
        self.equipment = SEquipment.new(self)
    end

    ---/********************************/
    ---/*           Player             */
    ---/********************************/

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

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---**Update playerData**
    --
    ---Sync playerData to client-side
    function self:updatePlayerData()
        TriggerClientEvent(self.playerController, 'TPN:player:updatePlayerData', self.playerData, self.properties)
    end

    ---On Player logged in
    ---@return PlayerData player data
    function self:login()
        -- Get player state
        local PlayerState = self.playerController:GetLyraPlayerState()
        -- Get player data from database
        local playerData = DAO.player.get(self.playerData.citizenId)
        -- Assign playerData
        self.playerData = playerData
        -- Assign Helix data to playerData
        self.playerData.netId = PlayerState:GetPlayerId()
        self.playerData.license = PlayerState:GetHelixUserId()
        self.playerData.name = PlayerState:GetPlayerName()

        return self.playerData
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

    ---Set metadata value
    ---@param key string metadata key
    ---@param value any metadata value
    ---@param isSyncToClient boolean|nil is sync to client (optional, defaults to true)
    function self:setMetaData(key, value, isSyncToClient)
        if isSyncToClient == nil then
            isSyncToClient = true
        end
        -- hunger and thirst must be between 0 and 100
        if key == 'hunger' or key == 'thirst' then
            value = value > 100 and 100 or value
        end
        -- Assign new metadata
        self.playerData.metadata[key] = value
        -- Sync to client if needed
        if isSyncToClient then
            self:updatePlayerData()
        end
    end

    ---Update basic needs
    function self:basicNeedTick()
        local newHunger = self.playerData.metadata['hunger'] - SHARED.CONFIG.BASIC_NEEDS.HUNGER_RATE
        local newThirst = self.playerData.metadata['thirst'] - SHARED.CONFIG.BASIC_NEEDS.THIRST_RATE
        if newHunger <= 0 then newHunger = 0 end
        if newThirst <= 0 then newThirst = 0 end
        -- Assign new hunger and thirst
        -- Don't sync to client because we will sync at next line
        -- This strategy is to optimize packet sending
        self:setMetaData('hunger', newHunger, false)
        -- Set metadata and sync to client
        self:setMetaData('thirst', newThirst)
        -- Update hunger and thirst in client-side UI
        TriggerClientEvent(self.playerController, 'TPN:ui:updateBasicNeeds', newHunger, newThirst)
    end

    _contructor()
    ---- END ----
    return self
end

return SPlayer

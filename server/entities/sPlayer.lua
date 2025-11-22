---@class SPlayer
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment SEquipment|nil
---@field level SLevel|nil
---@field missionManager SMission|nil
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
    -- Player's missions
    self.missionManager = nil

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
        -- Get player's missions
        self.missionManager = SMission.new(self)
        -- Get player's permission
        self.properties.permission = self.core:getPermission(self.playerController)
    end

    ---/********************************/
    ---/*           Player             */
    ---/********************************/

    ---Save player
    ---@return boolean status is save success or not
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
        local isMissionsSaved = self.missionManager:save()
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
        if not isMissionsSaved then
            print('[ERROR] SPLAYER.SAVE - Failed to save player missions!')
        end
        -- Return true if all save success
        return isSaved and isInventoriesSaved and isEquipmentsSaved and isLevelSaved and isMissionsSaved
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
        -- Sync player data
        TriggerClientEvent(self.playerController, 'TPN:player:updatePlayerData', self.playerData, self.properties)
        -- Sync player inventory
        -- Inventory already sync by each addItem, removeItem
        -- Player level already sync at each addExp, addSkillExp
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
        -- Update Pawn position and heading
        local ped = GetPlayerPawn(self.playerController)
        if ped then
            SetEntityCoords(ped, Vector(self.playerData.position.x, self.playerData.position.y, self.playerData.position.z))
            SetEntityRotation(ped, Rotator(0, self.playerData.heading, 0))
        end
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
        TriggerClientEvent(self.playerController, 'TPN:player:updateBasicNeeds', newHunger, newThirst)
    end

    ---Add Money
    ---@param type 'cash' | 'bank' money type
    ---@param amount number amount to add
    ---@return boolean status success status
    function self:addMoney(type, amount)
        if not type or type(type) ~= 'string' or type ~= 'cash' or type ~= 'bank' then
            print('[ERROR] SPLAYER.ADD_MONEY - Invalid type!')
            return false
        end
        if not amount or type(amount) ~= 'number' or amount <= 0 then
            print('[ERROR] SPLAYER.ADD_CASH - Invalid amount!')
            return false
        end
        if type == 'cash' then
            -- Add cash to player
            self.playerData.money.cash = self.playerData.money.cash + amount
        elseif type == 'bank' then
            self.playerData.money.bank = self.playerData.money.bank + amount
        end
        -- Trigger mission action
        self.missionManager:triggerAction('receive', {
            name = type,
            amount = amount
        })
        -- Sync to client
        self:updatePlayerData()
        return true
    end

    function self:removeMoney(type, amount)
        if not type or type(type) ~= 'string' or type ~= 'cash' or type ~= 'bank' then
            print('[ERROR] SPLAYER.REMOVE_MONEY - Invalid type!')
            return false
        end
        if not amount or type(amount) ~= 'number' or amount <= 0 then
            print('[ERROR] SPLAYER.REMOVE_MONEY - Invalid amount!')
            return false
        end
        if type == 'cash' then
            -- Remove cash from player
            self.playerData.money.cash = self.playerData.money.cash - amount
        elseif type == 'bank' then
            -- Remove bank from player
            self.playerData.money.bank = self.playerData.money.bank - amount
        end

        -- Trigger mission action
        self.missionManager:triggerAction('spend', {
            name = type,
            amount = amount
        })
        -- Sync to client
        self:updatePlayerData()
        return true
    end

    _contructor()
    ---- END ----
    return self
end

return SPlayer

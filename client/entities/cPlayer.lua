---@class CPlayer
---@field core TPNRPClient core entity
---@field playerData PlayerData|nil
---@field inventory CInventory|nil
CPlayer = {}
CPlayer.__index = CPlayer

---@return CPlayer
function CPlayer.new(core)
    ---@class CPlayer
    local self = setmetatable({}, CPlayer)

    self.core = core
    self.playerData = nil
    -- Player's inventory
    self.inventory = nil
    -- Player's custom properties
    self.properties = {}
    -- Player's dead state
    self.isDead = false

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- Bind Helix events (Default events of game)
        self:bindHelixEvents()
        -- Bind TPN events (Custom events of TPNRP-Core)
        self:bindTPNEvents()
        -- Get player's inventory
        self.inventory = CInventory.new(self)
        -- Update
        Timer.SetInterval(function()
            TriggerServerEvent('TPN:player:syncPlayer')
        end, (1000 * 60) * SHARED.CONFIG.UPDATE_INTERVAL)
    end

    ---/********************************/
    ---/*           Player             */
    ---/********************************/

    ---Get player coords
    ---@return Vector3 coords Player's coords
    function self:getCoords()
        -- TODO: Implement this
        -- Default coords from config
        return SHARED.DEFAULT.SPAWN.POSITION
    end

    ---Get player heading
    ---@return number heading Player's heading
    function self:getHeading()
        -- TODO: Implement this
        -- Default heading from config
        return SHARED.DEFAULT.SPAWN.HEADING
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    ---Bind Helix events
    function self:bindHelixEvents()
        -- On Player death
        RegisterClientEvent('HEvent:Death', function()
            self.isDead = true
        end)
        -- On Voice state changed
        RegisterClientEvent('HEvent:VoiceStateChanged', function(isTalking)
            print('HEvent:VoiceStateChanged')
        end)
        -- On Health changed
        RegisterClientEvent('HEvent:HealthChanged', function(oldHealth, newHealth)
            self.core.webUI:sendEvent('setHealth', newHealth)
        end)
    end

    ---Bind TPN events
    function self:bindTPNEvents()
        -- On Update playerData
        ---@param playerData PlayerData
        RegisterClientEvent('TPN:player:updatePlayerData', function(playerData, properties)
            self.playerData = playerData
            self.properties = properties or {}
        end)
    end

    _contructor()
    ---- END ----
    return self
end

return CPlayer

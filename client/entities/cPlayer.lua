---@class CPlayer
---@field core TPNRPClient core entity
---@field playerData PlayerData|nil
---@field inventory CInventory|nil
CPlayer = {}
CPlayer.__index = CPlayer

--- Creates a new instance of CPlayer.
---@param core TPNRPClient core entity
---@param playerData PlayerData player data
---@return CPlayer
function CPlayer.new(core, playerData)
    ---@class CPlayer
    local self = setmetatable({}, CPlayer)

    self.core = core
    self.playerData = playerData
    self.playerController = nil
    -- Player's inventory
    self.inventory = nil
    -- Player's equipment
    self.equipment = nil
    -- Player's custom properties
    self.properties = {}
    -- Player's dead state
    self.isDead = false

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        self.playerController = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
        -- Bind Helix events (Default events of game)
        self:bindHelixEvents()
        -- Bind TPN events (Custom events of TPNRP-Core)
        self:bindTPNEvents()
        -- Bind WebUI events (Custom events of WebUI)
        self:bindWebUIEvents()
        -- Get player's inventory
        self.inventory = CInventory.new(self)
        -- Get player's equipment
        self.equipment = CEquipment.new(self)
        -- Update
        Timer.SetInterval(function()
            TriggerServerEvent('TPN:player:syncPlayer')
        end, (1000 * 60) * SHARED.CONFIG.UPDATE_INTERVAL)

        -- Update basic needs
        self.core.webUI:sendEvent('setBasicNeeds', {
            hunger = self.playerData.metadata['hunger'] or 100,
            thirst = self.playerData.metadata['thirst'] or 100,
        })
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
        -- On Weapon equipped
        RegisterClientEvent('HEvent:WeaponEquipped', function(displayName, weaponName)
            print('Equipped weapon: ' .. displayName .. ' (' .. weaponName .. ')')
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

        -- On Update basic needs
        RegisterClientEvent('TPN:player:updateBasicNeeds', function(newHunger, newThirst)
            self.core.webUI:sendEvent('setBasicNeeds', {
                hunger = newHunger,
                thirst = newThirst,
            })
        end)
    end

    ---Bind WebUI events
    function self:bindWebUIEvents()
        -- [TEST] Test function only, it should not be exist on production
        self.core.webUI:registerEventHandler('playAnimation', function(data)
            self.core.game:playAnimation(nil, data.animationName, {
                onEnd = function()
                    print('Animation Ended')
                end,
            })
        end)
    end

    function self:getPawn()
        return self.playerController:K2_GetPawn()
    end

    _contructor()
    ---- END ----
    return self
end

return CPlayer

---@class TPNRPClient
---@field player CPlayer
---@field ui CWebUI webUI entity
TPNRPClient = {}
TPNRPClient.__index = TPNRPClient

---/********************************/
---/*        [Server] Core         */
---/********************************/

--- Creates a new instance of TPNRPClient.
---@return TPNRPClient
function TPNRPClient.new()
    ---@class TPNRPClient
    local self = setmetatable({}, TPNRPClient)
    
    self.player = nil
    self.shared = SHARED    -- Bind shared for other resources to use it via exports
    self.webUI = nil

    ---Contructor function
    local function _contructor()
        self.webUI = CWebUI.new(self)
        self:bindHelixEvents()
        self:bindTPNEvents()
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    ---Bind Helix events
    function self:bindHelixEvents()
        -- Helix event
        -- RegisterClientEvent('HEvent:PlayerLoggedIn', function()
        --     print('[TPN][CLIENT] HEvent:PlayerLoggedIn')
        -- end)
        
        -- RegisterClientEvent('HEvent:PlayerLoaded', function()
        --     print('[TPN][CLIENT] HEvent:PlayerLoaded')
        -- end)    
        -- -- On Player unpossessed
        -- RegisterClientEvent('HEvent:PlayerUnPossessed', function()
        --     print('[CLIENT] HEvent:PlayerUnPossessed')
        -- end)
    end

    ---Bind TPN events
    function self:bindTPNEvents()
        -- On Player Loaded
        RegisterClientEvent('TPN:client:onPlayerLoaded', function(source)
            self.player = CPlayer.new(source)
        end)

        -- On Player Unloaded
        RegisterClientEvent('TPN:client:onPlayerUnloaded', function()
            self.player = nil
        end)
        
        RegisterClientEvent('TPN:client:setCharacters', function(result)
            -- TODO: Teleport player to Select character Room

            -- Lock game input (Focus input on UI)
            self.webUI:focus()
            -- Show Select Character UI
            self.webUI:sendEvent('setPlayerCharacters', result)
        end)
        
        -- On create character
        self.webUI:registerEventHandler('createCharacter', function(data)
            TriggerCallback('createCharacter', function(result)
                if not result.success then return end
                print(JSON.stringify(result.playerData))
                self.webUI:sendEvent('onCreateCharacterSuccess', result.playerData)
            end, data)
        end)
    end

    ---On shutdown
    function self:onShutdown()
        if not self.webUI then return end
        self.webUI:destroy()
        self.webUI = nil
    end

    _contructor()
    return self
end

return TPNRPClient
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
        self:bindWebUIEvents()
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
        -- On Player Unloaded
        RegisterClientEvent('TPN:client:onPlayerUnloaded', function()
            self.player = nil
        end)

        RegisterClientEvent('TPN:client:setCharacters', function(result)
            -- TODO: Teleport player to Select character Room

            -- Lock game input (Focus input on UI)
            self.webUI:focus()
            -- Show Select Character UI
            self.webUI:sendEvent('setPlayerCharacters', result.maxCharacters, result.characters)
        end)
    end

    ---Bind WebUI events (Called from WebUI)
    function self:bindWebUIEvents()
        -- On create character
        self.webUI:registerEventHandler('createCharacter', function(data)
            TriggerCallback('createCharacter', function(result)
                if not result.success then return end
                -- Show notification
                self:showNotification({
                    title = result.message,
                    type = 'success',
                    duration = 5000,
                })
                print('[CLIENT] On create character success: ', JSON.stringify(result))
                -- Send event to WebUI
                self.webUI:sendEvent('onCreateCharacterSuccess', result.playerData)
            end, data)
        end)

        -- On Player click join game
        self.webUI:registerEventHandler('joinGame', function(data)
            MODEL.player.joinGame(data.citizenId, function(result)
                if not result.success then
                    self:showNotification({
                        title = SHARED.t('error.joinGameFailed'),
                        message = result.message,
                        type = 'error',
                        duration = 5000,
                    })
                    return
                end
                self.playerData = result.playerData
                -- Create client player entity
                self.player = CPlayer.new(self, result.playerData)
                -- Send event to WebUI
                self.webUI:sendEvent('joinGameSuccess', result.playerData)
                -- Out focus from WebUI to focus on game
                self.webUI:outFocus()
            end)
        end)
    end

    ---On shutdown
    function self:onShutdown()
        if not self.webUI then return end
        self.webUI:destroy()
        self.webUI = nil
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Show Notification in UI
    ---@param notification TNotification Notification data
    function self:showNotification(notification)
        -- Show notification in UI
        self.webUI:sendEvent('showNotification', notification)
    end

    _contructor()
    return self
end

return TPNRPClient
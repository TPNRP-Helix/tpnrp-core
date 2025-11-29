---@class TPNRPClient
---@field player CPlayer
---@field webUI CWebUI webUI entity
---@field game CGame game entity
---@field permission string permission
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
    self.game = nil -- Game entity

    -- Permission
    self.permission = 'player'

    ---Contructor function
    local function _contructor()
        self.webUI = CWebUI.new(self)
        self.game = CGame.new(self)
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
        RegisterClientEvent('HEvent:PlayerLoggedIn', function()
            print('[TPN][CLIENT] HEvent:PlayerLoggedIn')
            
        end)
        
        RegisterClientEvent('HEvent:PlayerLoaded', function()
            print('[TPN][CLIENT] HEvent:PlayerLoaded')
            
        end)    
        -- On Player unpossessed
        RegisterClientEvent('HEvent:PlayerPossessed', function()
            TriggerCallback('getPermissions', function(result)
                self.webUI:sendEvent('setPermission', result)
                self.permission = result
                self.webUI:sendEvent('syncItemsLibrary', SHARED.items)
            end, { citizenId = 'empty' })
        end)
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
                if not result.status then return end
                -- Show notification
                self:showNotification({
                    title = result.message,
                    type = 'success',
                    duration = 5000,
                })
                -- Send event to WebUI
                self.webUI:sendEvent('onCreateCharacterSuccess', result.playerData)
            end, data)
        end)

        self.webUI:registerEventHandler('deleteCharacter', function(data)
            TriggerCallback('deleteCharacter', function(result)
                local type = 'success'
                if not result.status then
                    type = 'error'
                end
                
                self:showNotification({
                    title = result.message,
                    type = type,
                })
            end, data)
        end)

        -- On Player click join game
        self.webUI:registerEventHandler('joinGame', function(data)
            TriggerCallback('callbackOnPlayerJoinGame', function(result)
                if not result.status then
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
            end, data.citizenId)
        end)

        self.webUI:registerEventHandler('devAddItem', function(data)
            TriggerCallback('devAddItem', function(result)
                if not result.status then
                    self:showNotification({
                        title = result.message,
                        type = 'error',
                        duration = 5000,
                    })
                    return
                end
                self:showNotification({
                    title = result.message,
                    type = 'success',
                    duration = 3000,
                })
            end, data)
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
    
    ---Check if player is in game
    ---@return boolean
    function self:isInGame()
        return self.player ~= nil
    end

    _contructor()
    return self
end

return TPNRPClient
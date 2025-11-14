---@class TPNRPServer
---@field players table<number, SPlayer>
TPNRPServer = {}
TPNRPServer.__index = TPNRPServer

---/********************************/
---/*        [Server] Core         */
---/********************************/

--- Creates a new instance of TPNRPServer.
---@return TPNRPServer
function TPNRPServer.new()
    ---@class TPNRPServer
    local self = setmetatable({}, TPNRPServer)

    self.players = {}       -- Players table
    self.shared = SHARED    -- Bind shared for other resources to use it via exports
    self.useableItems = {}  -- Useable items table

    ---@type SCheatDetector cheat detector entity
    self.cheatDetector = nil
    ---@type SGame game manager entity
    self.gameManager = nil

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        self.cheatDetector = SCheatDetector.new(self)
        self.gameManager = SGame.new(self)
        -- Bind Helix events (Default events of game)
        self:bindHelixEvents()
        -- Bind TPN's events (Custom events of TPNRP-Core)
        self:bindTPNEvents()
        -- Bind callback events (Custom events of TPNRP-Core)
        self:bindCallbackEvents()
    end

    ---/********************************/
    ---/*       Source/Identify        */
    ---/********************************/

    ---Get player by source
    ---@param source number player source
    ---@return SPlayer | nil player SPlayer entity
    function self:getPlayerBySource(source)
        for _, player in pairs(self.players) do
            if player.playerController == source then
                return player
            end
        end
         -- Player not found
        return nil
    end

    ---Get player by license
    ---@param license string player license
    ---@return SPlayer | nil player SPlayer entity
    function self:getPlayerByLicense(license)
        for _, player in pairs(self.players) do
            if player.playerData.license == license then
                return player
            end
        end
        -- Player not found
        return nil
    end

    ---Get player by citizen id
    ---@param citizenId string citizen id
    ---@return SPlayer | nil player SPlayer entity
    function self:getPlayerByCitizenId(citizenId)
        for _, player in pairs(self.players) do
            if player.playerData.citizenId == citizenId then
                return player
            end
        end
        -- Player not found
        return nil
    end

    ---Get license by source
    ---@param source PlayerController player controller
    ---@return string | nil license
    function self:getLicenseBySource(source)
        local playerState = source:GetLyraPlayerState()
        if not playerState then
            print('[ERROR] TPNRPServer.getLicenseBySource - Player state not found!')
            return nil
        end
        return playerState:GetHelixUserId() or nil
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Create a new useable item
    ---@param itemName string item name
    ---@param callback function callback
    function self:createUseableItem(itemName, callback)
        self.useableItems[itemName] = callback
    end

    ---Check if item can be used
    ---@param itemName string item name
    ---@return boolean canUse is this item can use or not
    function self:canUseItem(itemName)
        return self.useableItems[itemName] ~= nil
    end

    ---/********************************/
    ---/*           Events             */
    ---/********************************/
    
    ---Bind Helix events
    function self:bindHelixEvents()
        --- Base-game event
        RegisterServerEvent('HEvent:PlayerUnloaded', function(playerController) self:onPlayerUnloaded(playerController) end)
        RegisterServerEvent('HEvent:PlayerPossessed', function(playerController) self:onPlayerPossessed(playerController) end)
        RegisterServerEvent('HEvent:PlayerReady', function(playerController) self:onPlayerReady(playerController) end)
    end

    ---Bind TPN events
    function self:bindTPNEvents()
        -- TPN events
        RegisterServerEvent('TPN:player:syncPlayer', function(playerController) self:onPlayerSync(playerController) end)
    end

    ---On Player Unloaded
    ---@param source number player source
    function self:onPlayerUnloaded(source)
        ---@type SPlayer | nil
        local player = self:getPlayerBySource(source)
        if not player then
            print('[ERROR] TPNRPServer>onPlayerUnloaded - Player not found!')
            return
        end
        player:logout()
    end

    ---On Player Sync
    ---@param source number player source
    function self:onPlayerSync(source)
        ---@type SPlayer | nil
        local player = self:getPlayerBySource(source)
        if not player then
            print('[ERROR] TPNRPServer.onPlayerSync - Player not found!')
            return
        end
        -- Update basic needs
        player:basicNeedTick()
        -- Save player data
        local isSaved = player:save()
        if not isSaved then
            print('[ERROR] TPNRPServer.onPlayerSync - Failed to save player!')
        end
    end

    ---On Player Possessed
    ---@param source PlayerController player controller
    function self:onPlayerPossessed(source)
        local playerState = source:GetLyraPlayerState()
        local license = playerState:GetHelixUserId()
        local maxCharacters = SHARED.CONFIG.MAX_CHARACTERS or 3 -- Maximum number of characters per player
        local result = DAO.player.getCharacters(license)
        
        if not result then
            TriggerClientEvent(source, 'TPN:client:setCharacters', {
                maxCharacters = maxCharacters,
                characters = {},
            })
            return
        end
        TriggerClientEvent(source, 'TPN:client:setCharacters', {
            maxCharacters = maxCharacters,
            characters = result,
        })
    end

    ---On Player Ready
    ---@param playerController PlayerController player controller
    function self:onPlayerReady(playerController)
        local license = self:getLicenseBySource(playerController)
        if not license then
            print('[ERROR] TPNRPServer.onPlayerReady - Failed to get license by source!')
            return
        end
        local characters = DAO.player.getCharacters(license)
        if not characters then
            print('[ERROR] TPNRPServer.onPlayerReady - Failed to get characters by license!')
            return
        end
        print('[TPN][SERVER] onPlayerReady - characters: ', JSON.stringify(characters))
        -- Set characters to client
        TriggerClientEvent(playerController, 'TPN:client:setCharacters', {
            maxCharacters = SHARED.CONFIG.MAX_CHARACTERS,
            characters = characters,
        })
    end

    ---/********************************/
    ---/*       Callback Events        */
    ---/********************************/
    
    ---Bind callback events
    function self:bindCallbackEvents()
        print('[TPN][SERVER] bindCallbackEvents - register callback')
        -- Get player's role
        ---@param source PlayerController player controller
        ---@return string role
        RegisterCallback('getPermissions', function(source)
            -- Get player's role
            return SHARED.getPermission(source)
        end)

        -- Get player's language
        ---@param source PlayerController player controller
        ---@return string language
        RegisterCallback('getLanguage', function(source)
            -- TODO: Get Player's language from database
            
            -- Return default language by server's config
            return SHARED.CONFIG.LANGUAGE
        end)
        
        -- Create character
        ---@param source PlayerController player controller
        ---@param data table data
        ---@return table result
        RegisterCallback('createCharacter', function(source, data)
            local license = self:getLicenseBySource(source)
            if not license then
                print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get license by source!')
                return {
                    success = false,
                    message = SHARED.t('error.failedToGetLicense'),
                    playerData = nil
                }
            end
            local playerData = {
                citizenId = SHARED.createCitizenId(),
                license = license,
                name = data.firstName .. ' ' .. data.lastName,
                money = SHARED.DEFAULT.PLAYER.money,
                characterInfo = {
                    firstName = data.firstName,
                    lastName = data.lastName,
                    gender = data.gender,
                    birthday = data.dateOfBirth,
                },
                job = SHARED.DEFAULT.PLAYER.job,
                gang = SHARED.DEFAULT.PLAYER.gang,
                position = SHARED.DEFAULT.SPAWN.POSITION,
                heading = SHARED.DEFAULT.SPAWN.HEADING,
                metadata = SHARED.DEFAULT.PLAYER.metadata,
                level = SHARED.DEFAULT.LEVEL,
            }
            -- Create character
            local result = DAO.player.createCharacter(license, playerData)
            if not result then
                print(('[ERROR] TPNRPServer.bindCallbackEvents - Failed to create character for %s (License: %s)'):format(playerData.name, license))
                return {
                    success = false,
                    message = SHARED.t('error.createCharacter.failedToCreateCharacter'),
                    playerData = nil
                }
            end
            -- Return success
            return {
                success = true,
                message = SHARED.t('success.createCharacter'),
                playerData = playerData,
            }
        end)
        
        -- On Player join game
        ---@param source PlayerController player controller
        ---@param citizenId string citizen id
        ---@return table result
        RegisterCallback('callbackOnPlayerJoinGame', function(source, citizenId)
            local license = self:getLicenseBySource(source)
            if not license then
                print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get license by source!')
                return {
                    success = false,
                    message = SHARED.t('error.failedToGetLicense'),
                    playerData = nil
                }
            end
            local playerData = DAO.player.get(citizenId)
            if playerData.license ~= license then
                print('[ERROR] TPNRPServer.bindCallbackEvents - Player license mismatch!')
                -- TODO: Cheat detect!!
                -- TODO: Consider to ban this player by diconnected and add to blacklist
                self.cheatDetector:logCheater({
                    action = 'joinGame',
                    citizenId = citizenId,
                    license = license,
                    content = ('[ERROR] TPNRPServer.bindCallbackEvents - Player license mismatch!')
                })
                -- This player trying to login with character of other player
                return {
                    success = false,
                    message = SHARED.t('error.joinGame.playerNotFound'),
                    playerData = nil
                }
            end
            -- Create player
            local player = SPlayer.new(self, source, playerData)
            -- Assign back playerData with other properties
            playerData = player:login()
            -- Push player into array
            self.players[#self.players + 1] = player

            -- Return success
            return {
                success = true,
                message = SHARED.t('success.joinGame'),
                playerData = playerData,
            }
        end)
    end

    _contructor()
    return self
end

return TPNRPServer
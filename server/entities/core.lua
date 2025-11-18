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

    --- Manager
    --- @type SInventoryManager inventory manager entity
    self.inventoryManager = nil
    --- @type SCharacterManager character manager entity
    self.characterManager = nil

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        self.cheatDetector = SCheatDetector.new(self)
        self.gameManager = SGame.new(self)
        -- Bind all events, callback for inventory
        self.inventoryManager = SInventoryManager.new(self)
        self.characterManager = SCharacterManager.new(self)
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
    ---@param source PlayerController player source
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
    ---@param source PlayerController player source
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
    ---@param source PlayerController player source
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
        local maxCharacters = SHARED.CONFIG.MAX_CHARACTERS or 5 -- Maximum number of characters per player
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
        -- Get player's role
        ---@param source PlayerController player controller
        ---@return string role
        RegisterCallback('getPermissions', function(source, citizenId)
            -- Get player's role
            local permission = SHARED.getPermission(source)
            return permission
        end)

        -- Get player's language
        ---@param source PlayerController player controller
        ---@return string language
        RegisterCallback('getLanguage', function(source)
            -- TODO: Get Player's language from database
            
            -- Return default language by server's config
            return SHARED.CONFIG.LANGUAGE
        end)
    end

    _contructor()
    return self
end

return TPNRPServer
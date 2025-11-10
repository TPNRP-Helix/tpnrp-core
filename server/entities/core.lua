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

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        --- Base-game event
        RegisterServerEvent('HEvent:PlayerUnloaded', function(playerController) self:onPlayerUnloaded(playerController) end)
        RegisterServerEvent('HEvent:PlayerPossessed', function(source) self:onPlayerPossessed(source) end)
        -- TPN events
        RegisterServerEvent('TPN:player:syncPlayer', function(source) self:onPlayerSync(source) end)
        -- Bind callback events
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
            if player.playerData.citizen_id == citizenId then
                return player
            end
        end
        -- Player not found
        return nil
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
            TriggerClientEvent(source, 'TPN:core:setCharacters', {
                maxCharacters = maxCharacters,
                characters = {},
            })
            return
        end

        TriggerClientEvent(source, 'TPN:core:setCharacters', {
            maxCharacters = maxCharacters,
            characters = result,
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
    end


    _contructor()
    return self
end

return TPNRPServer
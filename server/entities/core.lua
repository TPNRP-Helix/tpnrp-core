---@class TPNRPServer
---@field players table<number, SPlayer>
TPNRPServer = {}
TPNRPServer.__index = TPNRPServer

/********************************/
/*        [Server] Core         */
/********************************/

--- Creates a new instance of TPNRPServer.
---@return TPNRPServer
function TPNRPServer.new()
    ---@class TPNRPServer
    local self = setmetatable({}, TPNRPServer)

    self.players = {}       -- Players table
    self.shared = SHARED    -- Bind shared for other resources to use it via exports
    self.useableItems = {}  -- Useable items table

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
       --- Base-game event
       RegisterServerEvent('HEvent:PlayerUnloaded', function(source)
            ---@type SPlayer | nil
            local player = self:getPlayerBySource(source)
            if not player then
                print('[ERROR] TPNRPServer>HEvent:PlayerUnloaded - Player not found!')
                return
            end
            player:logout()
        end)
    end

    /********************************/
    /*       Source/Identify        */
    /********************************/

    ---Get player by source
    ---@param source number player source
    ---@return SPlayer | nil player SPlayer entity
    function self:getPlayerBySource(source)
        for _, player in pairs(self.players) do
            if player.playerSource == source then
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

    /********************************/
    /*          Functions           */
    /********************************/
    
    ---Create a new citizen id
    ---@return string citizen id
    function self:createCitizenId()
        -- CitizenId: ABC12345 (3 characters, 5 numbers)
        return tostring(SHARED.randomStr(3) .. SHARED.randomInt(10000, 99999)):upper()
    end

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

    ----------------------------------------------------------------------
    --- Register Event
    ----------------------------------------------------------------------

    _contructor()
    return self
end

return TPNRPServer
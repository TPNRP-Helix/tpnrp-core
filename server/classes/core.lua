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
    
    ---@type table<number, SPlayer>
    self.players = {}       -- Players table
    self.shared = SHARED    -- Bind shared

    /********************************/
    /*       Source/Identify        */
    /********************************/

    ---Get player source from identifier
    ---@param identifier any
    ---@return number source
    function self:getSource(identifier)
        -- Check if player is already in the server
        for _, player in pairs(self.players) do
            if player.license == identifier then
                return player.playerSource
            end
        end
        -- Player not found
        return -1
    end

    ---Get player by source
    ---@param source number player source
    ---@return SPlayer | nil player
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
    ---@return SPlayer | nil player
    function self:getPlayerByLicense(license)
        for _, player in pairs(self.players) do
            if player.license == license then
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

    ----------------------------------------------------------------------
    --- Register Event
    ----------------------------------------------------------------------


    return self
end

return TPNRPServer
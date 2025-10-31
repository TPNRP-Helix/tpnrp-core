---@class TPNRPClient
---@field player CPlayer
TPNRPClient = {}
TPNRPClient.__index = TPNRPClient

/********************************/
/*        [Server] Core         */
/********************************/

--- Creates a new instance of TPNRPClient.
---@return TPNRPClient
function TPNRPClient.new()
    ---@class TPNRPClient
    local self = setmetatable({}, TPNRPClient)
    
    self.player = nil
    self.shared = SHARED    -- Bind shared

    ---Contructor function
    local function _contructor()
        -- TODO: Init player
        -- TODO: Bind function

        self.player = CPlayer.new()

        -- On Player Unloaded
        RegisterClientEvent('TPN:client:onPlayerUnloaded', function(source)
            -- TODO: Logout player
        end)
    end

    /********************************/
    /*          Functions           */
    /********************************/
    

    _contructor()
    return self
end

return TPNRPClient
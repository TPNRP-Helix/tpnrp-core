---@class TPNRPClient
---@field player CPlayer
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

    ---Contructor function
    local function _contructor()
        -- On Player Loaded
        RegisterClientEvent('TPN:client:onPlayerLoaded', function(source)
            self.player = CPlayer.new(source)
        end)

        -- On Player Unloaded
        RegisterClientEvent('TPN:client:onPlayerUnloaded', function()
            self.player = nil
        end)
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    

    _contructor()
    return self
end

return TPNRPClient
---@class SCheatDetector
---@field core TPNRPServer core entity
SCheatDetector = {}
SCheatDetector.__index = SCheatDetector

---@return SCheatDetector
---@param core TPNRPServer core entity
function SCheatDetector.new(core)
    ---@class SCheatDetector
    local self = setmetatable({}, SCheatDetector)
    -- Server Core
    self.core = core
    

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()

    end

    ---Log cheater
    ---@param data TLogCheatParams data
    function self:logCheater(data)
        local playerName = 'Unknown'
        if data.player ~= nil then
            playerName = data.player.playerData.name or 'Unknown'
        end
        print('[SERVER] [CHEAT] "' .. data.action .. '" | "' .. playerName .. '" | "' .. data.content .. '"')
        -- TODO: Save cheater to database
        -- TODO: Warning to discord via webhook
    end

    function self:log(data)
        local playerName = 'Unknown'
        if data.player ~= nil then
            playerName = data.player.playerData.name or 'Unknown'
        end
        print('[SERVER] [LOG] "' .. data.action .. '" | "' .. playerName .. '" | "' .. data.content .. '"')
        -- TODO: Save cheater to database
        -- TODO: Warning to discord via webhook
    end

    ---Kick player
    ---@param player SPlayer player entity
    ---@param reason string reason to kick player
    function self:kickPlayer(player, reason)
        if not player then
            return
        end
        if not reason or type(reason) ~= 'string' then
            reason = 'You are kicked from the server'
        end
        player.playerController:Kick(reason)
    end

    _contructor()
    ---- END ----
    return self
end

return SCheatDetector

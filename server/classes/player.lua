---@class SPlayer
SPlayer = {}
SPlayer.__index = SPlayer

---@return SPlayer
function SPlayer.new(playerSource, playerLicense)
    ---@class SPlayer
    local self = setmetatable({}, SPlayer)

    -- Public
    self.playerSource = playerSource
    self.license = playerLicense

    self.id = -1            -- Player Id in database
    self.displayName = ""   -- Player display name
    self.level = 0         -- Player level
    self.money = 0         -- Player money (In-game money)
    self.tpnCoin = 0       -- Player tpn coin (Pay)
    
    /********************************/
    /*         Initializes          */
    /********************************/
    
    ---Contructor function
    local function _contructor()
        -- TODO:
    end

    ----------------------------------------------------------------------
    --- Register Event
    ----------------------------------------------------------------------
    _contructor()
    ---- END ----
    return self
end

return SPlayer
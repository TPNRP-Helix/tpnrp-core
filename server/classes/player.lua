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
    
    /********************************/
    /*         Initializes          */
    /********************************/
    
    ---Contructor function
    local function _contructor()
        -- TODO:
    end


    _contructor()
    ---- END ----
    return self
end

return SPlayer
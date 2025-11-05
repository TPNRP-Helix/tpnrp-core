---@class SLevel
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment SEquipment|nil
SLevel = {}
SLevel.__index = SLevel

---@return SLevel
function SLevel.new(playerController)
    ---@class SLevel
    local self = setmetatable({}, SLevel)

    -- Player's fields
    self.playerController = playerController

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        
    end

    /********************************/
    /*           Player             */
    /********************************/

    ---Save player
    ---@return boolean success is save success or not
    function self:save()
        
    end

    /********************************/
    /*          Functions           */
    /********************************/

    _contructor()
    ---- END ----
    return self
end

return SLevel

---@class SInventory
---@field player SPlayer
---@field inventories table<number, SInventoryItem>
SInventory = {}
SInventory.__index = SInventory

---@return SInventory
function SInventory.new(player)
    ---@class SInventory
    local self = setmetatable({}, SInventory)

    -- Public
    self.player = player
    self.inventories = {}

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- TODO: Fetch inventory of user
    end

    /********************************/
    /*           Functions           */
    /********************************/

    ---Save inventory
    ---@return boolean success
    function self:save()
        return DAO.saveInventory(self)
    end

    _contructor()
    ---- END ----
    return self
end

return SInventory
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
        -- Get inventory by citizen_id and type ('player' is default player inventory)
        local inventories = DAO.getPlayerInventory(self.player.playerData.citizen_id, 'player')
        if inventories then
            self.inventories = inventories
        end
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
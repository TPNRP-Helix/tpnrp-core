---@class SInventory
---@field player SPlayer
---@field inventories table<number, SInventoryItemType>
---@field type 'player' | 'stack' | ''
SInventory = {}
SInventory.__index = SInventory

---@return SInventory
function SInventory.new(player)
    ---@class SInventory
    local self = setmetatable({}, SInventory)

    -- Public
    self.player = player
    self.type = 'player'
    self.inventories = {}

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        
    end

    /********************************/
    /*           Functions          */
    /********************************/

    ---Save inventory
    ---@return boolean success
    function self:save()
        return DAO.inventory.save(self)
    end

    ---Load inventory
    ---@param type 'player' | 'stack' | ''
    ---@return boolean success
    function self:load(type)
        -- Type is empty then don't load inventory
        if type == '' then
            return false
        end
        -- Assign type
        self.type = type
        -- Get inventory items
        local inventories = DAO.inventory.get(self.player.playerData.citizen_id, self.type)
        if inventories then
            self.inventories = inventories
        end
        
        return true
    end

    


    _contructor()
    ---- END ----
    return self
end

return SInventory
---@class CInventory
---@field player CPlayer player entity
CInventory = {}
CInventory.__index = CInventory

---@param player CPlayer player entity
---@return CInventory
function CInventory.new(player)
    ---@class CInventory
    local self = setmetatable({}, CInventory)

    self.player = player
    self.items = {}

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- On Update inventory
        RegisterClientEvent('TPN:inventory:sync', function(type, amount, item)
            self:onSyncInventory(type, amount, item)
        end)
    end


    /********************************/
    /*          Functions           */
    /********************************/
    
    -- On Update inventory
    ---@param type 'add' | 'remove' inventory type
    ---@param amount number item amount
    ---@param item SInventoryItemType item data
    function self:onSyncInventory(type, amount, item)
        if type == 'add' then
            -- Push item to items table
            self.items[item.slot] = item
        elseif type == 'remove' then
            -- Remove item from items table
            self.items[item.slot] = nil
        end
        -- Update UI for items changes
        TPNRPUI:SendEvent('ITEM_CHANGED', {
            type = type,
            amount = amount,
            item = item
        })
    end

    _contructor()
    ---- END ----
    return self
end

return CInventory
---@class CInventory
---@field player CPlayer player entity
CInventory = {}
CInventory.__index = CInventory

---@param player CPlayer player entity
---@return CInventory
function CInventory.new(player)
    ---@class CInventory
    local self = setmetatable({}, CInventory)

    self.core = player.core
    self.player = player
    self.items = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- On Update inventory
        RegisterClientEvent('TPN:inventory:sync', function(type, amount, item)
            self:onSyncInventory(type, amount, item)
        end)
        -- Bind key
        -- [Player] [TAB] Inventory
        Input.BindKey('TAB', function()
            if not self.core:isInGame() then
                return
            end
            self:openInventory()
        end, 'Pressed')

        -- On close inventory
        self.core.webUI:registerEventHandler('onCloseInventory', function()
            self.core.webUI:outFocus()
        end)
    end


    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
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
        self.core.webUI:sendEvent('ITEM_CHANGED', {
            type = type,
            amount = amount,
            item = item
        })
    end

    ---Open inventory
    function self:openInventory()
        -- TODO: open inventory
        self.core.webUI:focus()
        self.core.webUI:sendEvent('openInventory')
    end

    function self:doCloseInventory()
        self.core.webUI:outFocus()
        self.core.webUI:sendEvent('closeInventory')
    end

    _contructor()
    ---- END ----
    return self
end

return CInventory
---@class CInventory
---@field player CPlayer player entity
---@field items table<number, SInventoryItemType> item data
CInventory = {}
CInventory.__index = CInventory

---@param player CPlayer player entity
---@return CInventory
function CInventory.new(player)
    ---@class CInventory
    local self = setmetatable({}, CInventory)

    self.core = player.core
    self.player = player
    ---@type table<number, SInventoryItemType> slotNumber, InventoryItem
    self.items = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- On Update inventory
        RegisterClientEvent('TPN:inventory:sync', function(items)
            self:onSyncInventory(items)
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

        -- On move inventory item
        self.core.webUI:registerEventHandler('onMoveInventoryItem', function(data)
            TriggerCallback('onMoveInventoryItem', function(result)
                print('[CLIENT][INFO] CInventory.onMoveInventoryItem - result: ', JSON.stringify(result))
                if not result.status then
                    return
                end
            end, data)
        end)
    end


    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    -- On Update inventory
    ---@param items table<number, SInventoryItemType> item data
    function self:onSyncInventory(items)
        self.items = items
        -- Update UI for items changes
        self.core.webUI:sendEvent('doSyncInventory', {
            type = 'sync',
            items = items
        })
    end

    ---Open inventory
    function self:openInventory()
        TriggerCallback('onOpenInventory', function(result)
            if not result.status then
                self.core:showNotification({
                    title = result.message,
                    type = 'error',
                    duration = 5000,
                })
                return
            end
            print('[INFO] CInventory.openInventory result: ', JSON.stringify(result))
            -- Open inventory
            self.core.webUI:focus()
            self.core.webUI:sendEvent('openInventory')
        end, { type = 'player' })
    end

    ---Close inventory
    function self:doCloseInventory()
        self.core.webUI:outFocus()
        self.core.webUI:sendEvent('closeInventory')
    end

    ---Find items owned by current player that contain the provided name fragment
    ---@param name string item name fragment
    ---@return SInventoryItemType[] matchingItems
    function self:findItemsByName(name)
        if type(name) ~= 'string' or name == '' then
            return {}
        end

        local keyword = name:lower()
        local matchedItems = {}

        for _, item in pairs(self.items or {}) do
            if item and item.name and item.name:lower():find(keyword, 1, true) then
                table.insert(matchedItems, item)
            end
        end

        return matchedItems
    end

    _contructor()
    ---- END ----
    return self
end

return CInventory
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
        ---@param items table<number, SInventoryItemType> item data
        ---@param backpack {items: table<number, SInventoryItemType>, isHaveBackpack: boolean, slotCount: number, maxWeight: number} backpack data
        RegisterClientEvent('clientSyncInventory', function(items, backpack)
            self:onSyncInventory(items, backpack)
        end)

        --- Open drop inventory
        ---@param data {containerId:string}
        RegisterClientEvent('openContainerInventory', function(data)
            self:openInventory({ type = 'container', containerId = data.containerId })
        end)

        RegisterClientEvent('pickUpItem', function(data)
            TriggerCallback('onPickUpItem', function(result)
                
            end, data)
        end)
        -- Bind key
        -- [Player] [TAB] Inventory
        Input.BindKey('TAB', function()
            if not self.core:isInGame() then
                return
            end
            self:openInventory({ type = 'player' })
        end, 'Pressed')

        -- On close inventory
        self.core.webUI:registerEventHandler('onCloseInventory', function()
            self.core.webUI:outFocus()
        end)

        -- On move inventory item
        self.core.webUI:registerEventHandler('onMoveInventoryItem', function(data, cb)
            TriggerCallback('onMoveInventoryItem', function(result)
                cb(result)
                return result
            end, data)
        end)

        -- On create drop item
        ---@param data {itemName: string, amount: number, fromSlot: number} item data
        self.core.webUI:registerEventHandler('createDropItem', function(data, cb)
            TriggerCallback('createDropItem', function(result)
                cb(result)
            end, data)
        end)

        -- On split item
        ---@param data {slot: number} item data
        self.core.webUI:registerEventHandler('splitItem', function(data, cb)
            TriggerCallback('splitItem', function(result)
                cb(result)
            end, data)
        end)

        ---@param data {itemName: string; slot: number} item data
        self.core.webUI:registerEventHandler('useItem', function(data)
            TriggerCallback('useItem', function(result)
                self.core.webUI:sendEvent('onUseItemResponse', result)
            end, data)
        end)

        ---@param data {itemName: string; slot: number} equip item data
        self.core.webUI:registerEventHandler('wearItem', function(data, cb)
            TriggerCallback('wearItem', function(result)
                cb(result)
                -- self.core.webUI:sendEvent('onWearItemResponse', result)
            end, data)
        end)

        ---@param data {itemName: string; slot: number} un-equip item data
        self.core.webUI:registerEventHandler('unequipItem', function(data, cb)
            TriggerCallback('unequipItem', function(result)
                cb(result)
            end, data)
        end)

        self.core.webUI:registerEventHandler('requestPlayerNearBy', function(data, cb)
            TriggerCallback('requestPlayerNearBy', function(result)
                cb(result)
            end, data)
        end)
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    -- On Update inventory
    ---@param items table<number, SInventoryItemType> item data
    ---@param backpack {items: table<number, SInventoryItemType>, isHaveBackpack: boolean, slotCount: number, maxWeight: number} backpack data
    function self:onSyncInventory(items, backpack)
        self.items = items
        -- Update UI for items changes
        self.core.webUI:sendEvent('doSyncInventory', {
            type = 'sync',
            items = items,
            backpack = backpack
        })
    end

    ---Call open inventory
    ---@param data {type:'player' | 'container'; containerId:string|nil} data
    function self:openInventory(data)
        ---@param result TInventoryOpenInventoryResultType result
        TriggerCallback('onOpenInventory', function(result)
            if not result.status then
                self.core:showNotification({
                    title = result.message,
                    type = 'error',
                    duration = 5000,
                })
                return
            end
            -- Open inventory
            self.core.webUI:focus()
            self.core.webUI:sendEvent('openInventory', result)
        end, data)
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
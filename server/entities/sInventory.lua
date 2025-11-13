---@class SInventory
---@field core TPNRPServer
---@field player SPlayer
---@field items table<number, SInventoryItemType>
---@field type 'player' | 'stack' | ''
SInventory = {}
SInventory.__index = SInventory

---@param player SPlayer player entity
---@param type 'player' | 'stack' | ''
---@return SInventory
function SInventory.new(player, type)
    ---@class SInventory
    local self = setmetatable({}, SInventory)

    -- Core
    self.core = player.core
    -- Player's entity
    self.player = player
    self.type = type
    self.items = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- type is player then load it
        if type == 'player' then
            self:load('player')
        end
    end

    ---/********************************/
    ---/*           Functions          */
    ---/********************************/

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
        local inventories = DAO.inventory.get(self.player.playerData.citizenId, self.type)
        if inventories then
            self.items = inventories
        end
        
        return true
    end

    ---Calculate total inventory weight
    ---@return number total inventory weight in Grams
    function self:calculateTotalWeight()
        local totalWeight = 0
        for _, item in pairs(self.items) do
            local itemData = SHARED.items[item.name:lower()]
            totalWeight = totalWeight + (itemData.weight * item.amount)
        end
        return totalWeight
    end

    ---Check if item can be added to inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@return SInventoryCanAddItemResultType {status=boolean, message = string} is this item can add to inventory or not
    function self:canAddItem(itemName, amount)
        -- Get item data
        local itemData = SHARED.items[itemName:lower()]
        if not itemData then
            print(('[ERROR] SInventory.canAddItem: Item %s not found!'):format(itemName))
            return { status = false, message = 'Item not found!' }
        end
        -- Total item weight
        local itemWeight = itemData.weight * amount
        local inventoryWeight = self:calculateTotalWeight()
        local totalWeight = inventoryWeight + itemWeight
        local inventoryCapacity = { status = false, slots = 0, weightLimit = 0 }
        -- Get inventory capacity by self.type
        if self.type == 'player' then
            inventoryCapacity = self.player.equipment:getBackpackCapacity()
        end
        if not inventoryCapacity.status then
            print(('[ERROR] SInventory.canAddItem: Inventory capacity not found for type %s!'):format(self.type))
            return { status = false, message = 'Inventory capacity not found!' }
        end
        -- Check if item weight is greater than backpack weight limit
        if totalWeight > inventoryCapacity.weightLimit then
            return { status = false, message = 'Inventory weight limit reached!' }
        end
        -- Check if item slots is greater than backpack slots limit
        local totalUsedSlots = #self.items
        local totalNewUsedSlots = totalUsedSlots + 1
        if totalNewUsedSlots > inventoryCapacity.slots then
            return { status = false, message = 'Inventory slots limit reached!' }
        end

        return { status = true, message = 'Item can be added to inventory!' }
    end

    ---Find an empty slot in the inventory
    ---@return number | nil number slot number, or nil if no empty slot found
    function self:getEmptySlot()
        -- Get inventory capacity
        local inventoryCapacity = { status = false, slots = 0, weightLimit = 0 }
        if self.type == 'player' then
            inventoryCapacity = self.player.equipment:getBackpackCapacity()
        end
        if not inventoryCapacity.status then
            print(('[ERROR] SInventory.getEmptySlot: Inventory capacity not found for type %s!'):format(self.type))
            return nil
        end

        -- If no capacity found, use default from config or return nil
        local maxSlots = 0
        if inventoryCapacity.status and inventoryCapacity.slots > 0 then
            maxSlots = inventoryCapacity.slots
        else
            -- No capacity available
            return nil
        end
        
        -- Create a set of used slots for quick lookup
        local usedSlots = {}
        for _, item in pairs(self.items) do
            usedSlots[item.slot] = true
        end
        
        -- Find first empty slot
        for slot = 1, maxSlots do
            if not usedSlots[slot] then
                return slot
            end
        end
        
        -- No empty slot found
        return nil
    end

    ---Find an item by name and return its slot number
    ---@param itemName string item name to search for
    ---@return number | nil slot number of the item, or nil if item not found
    function self:findItemSlot(itemName)
        if not itemName then
            return nil
        end
        
        -- Convert item name to lowercase for case-insensitive comparison
        local searchName = itemName:lower()
        
        -- Iterate through all items in the inventory
        for _, item in pairs(self.items) do
            if item.name and item.name:lower() == searchName then
                -- Return the slot number of the matching item
                return item.slot
            end
        end
        
        -- No item slot found
        return nil
    end

    ---Find an item by slot number
    ---@param slotNumber number slot number
    ---@return SInventoryItemType | nil item data, or nil if item not found
    function self:findItemBySlot(slotNumber)
        if not slotNumber then
            return nil
        end
        return self.items[slotNumber] or nil
    end
    
    ---Add item to inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@param slotNumber number | nil slot number (optional)
    ---@param info table | nil item info (optional)
    ---@return SInventoryAddItemResultType {status=boolean, message=string, slot=number} result of adding item
    function self:addItem(itemName, amount, slotNumber, info)
        -- Validate inputs
        if not itemName or type(itemName) ~= 'string' then
            return { status = false, message = 'Invalid item name!', slot = -1 }
        end
        
        if not amount or type(amount) ~= 'number' or amount <= 0 then
            return { status = false, message = 'Invalid item amount!', slot = -1 }
        end
        
        -- Get item data
        local itemData = SHARED.items[itemName:lower()]
        if not itemData then
            return { status = false, message = 'Item not found!', slot = -1 }
        end
        
        -- Check if item can be added to inventory
        local canAddResult = self:canAddItem(itemName, amount)
        if not canAddResult.status then
            return { status = false, message = canAddResult.message, slot = -1 }
        end
        
        -- Determine if item is unique
        local isUnique = itemData.unique or false
        
        -- Determine slot to use
        local targetSlot = nil
        
        -- If slotNumber is provided, validate it
        if slotNumber then
            if type(slotNumber) ~= 'number' or slotNumber <= 0 then
                return { status = false, message = 'Invalid slot number!', slot = -1 }
            end
            
            -- Check if slot is already occupied
            local existingItem = self.items[slotNumber]
            
            if existingItem then
                -- Slot is occupied
                if isUnique then
                    -- Unique items cannot use occupied slots, find an empty slot
                    targetSlot = self:getEmptySlot()
                    if not targetSlot then
                        return { status = false, message = 'No empty slot available!', slot = -1 }
                    end
                else
                    -- Non-unique items can stack if it's the same item
                    if existingItem.name:lower() == itemName:lower() then
                        -- Same item, can stack
                        targetSlot = slotNumber
                    else
                        -- Slot is occupied by a different item, find an empty slot
                        targetSlot = self:getEmptySlot()
                        if not targetSlot then
                            return { status = false, message = 'No empty slot available!', slot = -1 }
                        end
                    end
                end
            else
                -- Slot is empty, can use it
                targetSlot = slotNumber
            end
        else
            -- No slot number provided, need to find one
            if isUnique then
                -- Unique items need an empty slot
                targetSlot = self:getEmptySlot()
                if not targetSlot then
                    return { status = false, message = 'No empty slot available!', slot = -1 }
                end
            else
                -- Non-unique items can stack with existing items
                -- Try to find existing item slot to stack
                targetSlot = self:findItemSlot(itemName)
                
                -- If not found, find empty slot
                if not targetSlot then
                    targetSlot = self:getEmptySlot()
                    if not targetSlot then
                        return { status = false, message = 'No empty slot available!', slot = -1 }
                    end
                end
            end
        end
        
        -- Add or update item in inventory
        if self.items[targetSlot] and not isUnique then
            -- Stack item (non-unique items can stack)
            self.items[targetSlot].amount = self.items[targetSlot].amount + amount
            -- Update info if provided
            if info then
                -- Merge info tables if both exist
                if self.items[targetSlot].info and type(self.items[targetSlot].info) == 'table' then
                    for k, v in pairs(info) do
                        self.items[targetSlot].info[k] = v
                    end
                else
                    self.items[targetSlot].info = info
                end
            end
        else
            -- Create new item entry
            self.items[targetSlot] = {
                name = itemData.name,
                label = itemData.label,
                weight = itemData.weight,
                type = itemData.type,
                image = itemData.image,
                unique = itemData.unique,
                useable = itemData.useable,
                shouldClose = itemData.shouldClose,
                description = itemData.description,
                amount = amount,
                slot = targetSlot,
                info = info or {}
            }
        end
        -- Tell player that item is added to inventory
        TriggerClientEvent(self.player.playerController, 'TPN:inventory:sync', 'add', amount, self.items[targetSlot])
        -- Trigger mission action
        self.player.missionManager:triggerAction('add_item', {
            name = itemName,
            amount = amount,
            info = info or {}
        })
        return { status = true, message = 'Item added to inventory!', slot = targetSlot }
    end

    ---Remove item from inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@param slotNumber number | nil slot number (optional)
    ---@return {status:boolean, message:string, slot:number} result of removing item
    function self:removeItem(itemName, amount, slotNumber)
        -- Validate inputs
        if not itemName or type(itemName) ~= 'string' then
            return { status = false, message = 'Invalid item name!', slot = -1 }
        end
        if not amount or type(amount) ~= 'number' or amount <= 0 then
            return { status = false, message = 'Invalid item amount!', slot = -1 }
        end
        
        -- Determine which slot to remove from
        local targetSlot = nil
        
        if slotNumber then
            -- Slot number provided, validate it
            if type(slotNumber) ~= 'number' or slotNumber <= 0 then
                return { status = false, message = 'Invalid slot number!', slot = -1 }
            end
            
            -- Check if item exists at the specified slot
            local item = self.items[slotNumber]
            if not item then
                return { status = false, message = 'No item found at specified slot!', slot = -1 }
            end
            
            -- Verify the item at that slot matches the itemName (case-insensitive)
            if item.name:lower() ~= itemName:lower() then
                return { status = false, message = 'Item at specified slot does not match!', slot = -1 }
            end
            
            targetSlot = slotNumber
        else
            -- No slot number provided, find the first item matching the name
            targetSlot = self:findItemSlot(itemName)
            if not targetSlot then
                return { status = false, message = 'Item not found in inventory!', slot = -1 }
            end
        end
        
        -- Get the item at the target slot
        local item = self.items[targetSlot]
        if not item then
            return { status = false, message = 'Item not found at slot!', slot = -1 }
        end
        
        -- Verify the item matches (double-check for safety)
        if item.name:lower() ~= itemName:lower() then
            return { status = false, message = 'Item at slot does not match!', slot = -1 }
        end
        
        -- Check if there's enough amount to remove
        if item.amount < amount then
            return { status = false, message = 'Not enough items to remove!', slot = -1 }
        end
        
        -- Calculate remaining amount
        local remainingAmount = item.amount - amount
        -- Tell player that item is remove from inventory
        TriggerClientEvent(self.player.playerController, 'TPN:inventory:sync', 'remove', amount, itemName)
        -- Trigger mission action
        self.player.missionManager:triggerAction('remove_item', {
            name = itemName,
            amount = amount,
        })
        -- If remaining amount is 0 or less, remove the item entirely from the slot
        if remainingAmount <= 0 then
            self.items[targetSlot] = nil
            return { status = true, message = 'Item removed from inventory!', slot = targetSlot }
        else
            -- Update the item amount
            self.items[targetSlot].amount = remainingAmount
            return { status = true, message = 'Item amount reduced!', slot = targetSlot }
        end
    end

    ---Check if inventory has item with the specified amount
    ---@param itemName string item name
    ---@param amount number | nil item amount (optional, defaults to 1 if not provided)
    ---@return {status:boolean, message:string, totalAmount:number} result of checking item
    function self:hasItem(itemName, amount)
        -- Validate inputs
        if not itemName or type(itemName) ~= 'string' then
            return { status = false, message = 'Invalid item name!', totalAmount = 0 }
        end
        
        -- Default amount to 1 if not provided
        if not amount then
            amount = 1
        elseif type(amount) ~= 'number' or amount <= 0 then
            return { status = false, message = 'Invalid item amount!', totalAmount = 0 }
        end
        
        -- Convert item name to lowercase for case-insensitive comparison
        local searchName = itemName:lower()
        
        -- Calculate total amount of matching items in inventory
        local totalAmount = 0
        
        -- Iterate through all items in the inventory
        for _, item in pairs(self.items) do
            if item.name and item.name:lower() == searchName then
                -- Found matching item, add its amount to total
                totalAmount = totalAmount + (item.amount or 0)
            end
        end
        
        -- Check if total amount meets the required amount
        if totalAmount >= amount then
            return { 
                status = true, 
                message = string.format('Item found in inventory! (Has: %d, Required: %d)', totalAmount, amount), 
                totalAmount = totalAmount 
            }
        else
            return { 
                status = false, 
                message = string.format('Not enough items in inventory! (Has: %d, Required: %d)', totalAmount, amount), 
                totalAmount = totalAmount 
            }
        end
    end

    _contructor()
    ---- END ----
    return self
end

return SInventory
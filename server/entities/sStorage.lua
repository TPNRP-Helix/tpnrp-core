---@class SStorage
---@field items table<number, SInventoryItemType>
---@field maxSlot number
---@field maxWeight number
SStorage = {}
SStorage.__index = SStorage

---@return SStorage
function SStorage:new()
    local self = setmetatable({}, SStorage)
    self.items = {}
    return self
end

---Calculate total inventory weight
---@return number total inventory weight in Grams
function SStorage:calculateTotalWeight()
    local totalWeight = 0
    for _, item in pairs(self.items) do
        local itemData = SHARED.items[item.name:lower()]
        if itemData then
            totalWeight = totalWeight + (itemData.weight * item.amount)
        end
    end
    return totalWeight
end

---Get max weight
---@return number
function SStorage:getMaxWeight()
    return self.maxWeight
end

---Get max slots
---@return number
function SStorage:getMaxSlots()
    return self.maxSlot
end

---Check if item can be added to inventory
---@param itemName string item name
---@param amount number item amount
---@return { status: boolean; message: string; } result is this item can add to inventory or not
function SStorage:canAddItem(itemName, amount)
    -- Get item data
    local itemData = SHARED.items[itemName:lower()]
    if not itemData then
        print(('[ERROR] SStorage:canAddItem: Item %s not found!'):format(itemName))
        return { status = false, message = 'Item not found!' }
    end
    -- Total item weight
    local itemWeight = itemData.weight * amount
    local containerWeight = self:calculateTotalWeight()
    local totalWeight = containerWeight + itemWeight

    -- Check if item weight is greater than weight limit
    if totalWeight > self:getMaxWeight() then
        return { status = false, message = SHARED.t('error.inventoryWeightLimitReached') }
    end
    
    -- Determine if item is unique (cannot stack)
    local isUnique = itemData.unique or false
    
    -- Check if item already exists in inventory and can be stacked
    local existingItemSlot = self:findItemSlot(itemName)
    local needsNewSlot = true
    
    if existingItemSlot and not isUnique then
        -- Item exists and can stack, no new slot needed
        needsNewSlot = false
    end
    
    -- Check if item slots is greater than slots limit
    if needsNewSlot then
        -- Count only non-nil items (filter out nil slots)
        local totalUsedSlots = 0
        for _, item in pairs(self.items) do
            if item ~= nil then
                totalUsedSlots = totalUsedSlots + 1
            end
        end
        local totalNewUsedSlots = totalUsedSlots + 1
        print('[SERVER] [DEBUG] SStorage:canAddItem: totalNewUsedSlots: ' .. totalNewUsedSlots .. ' maxSlots: ' .. self:getMaxSlots())
        if totalNewUsedSlots > self:getMaxSlots() then
            return { status = false, message = SHARED.t('error.inventoryFull') }
        end
    end

    return { status = true, message = SHARED.t('inventory.canAddItem') }
end

---Find an empty slot in the inventory
---@return number | nil number slot number, or nil if no empty slot found
function SStorage:getEmptySlot()
    -- Create a set of used slots for quick lookup
    local usedSlots = {}
    for _, item in pairs(self.items) do
        usedSlots[item.slot] = true
    end
    
    -- Find first empty slot
    local maxSlots = self:getMaxSlots()
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
function SStorage:findItemSlot(itemName)
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

---Get an item by slot number
---@param slotNumber number slot number
---@return SInventoryItemType | nil item data, or nil if item not found
---@return number index of item in array
function SStorage:getItemBySlot(slotNumber)
    if not slotNumber then
        return nil, -1
    end
    for index, value in ipairs(self.items) do
        if value.slot == slotNumber then
            return value, index
        end
    end
    return nil, -1
end

---Add item to inventory
---@param itemName string item name
---@param amount number item amount
---@param slotNumber number | nil slot number (optional)
---@param info table | nil item info (optional)
---@return {status:boolean, message:string, slot:number} result of adding item
function SStorage:addItem(itemName, amount, slotNumber, info)
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
        local existingItem = self:getItemBySlot(slotNumber)
        
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
    -- Stack new item if it is not unique
    -- Add or update item in inventory
    local targetSlotItem = self:getItemBySlot(targetSlot)
    if targetSlotItem and not isUnique then
        -- Stack item (non-unique items can stack)
        targetSlotItem.amount = targetSlotItem.amount + amount
        -- Update info if provided
        if info then
            -- Merge info tables if both exist
            if targetSlotItem.info and type(targetSlotItem.info) == 'table' then
                for k, v in pairs(info) do
                    targetSlotItem.info[k] = v
                end
            else
                targetSlotItem.info = info
            end
        end
    else
        -- Create new item entry
        self:push({
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
        })
    end

    return { status = true, message = SHARED.t('inventory.added'), slot = targetSlot }
end

---Remove item from inventory
---@param itemName string item name
---@param amount number item amount
---@param slotNumber number | nil slot number (optional)
---@return {status:boolean, message:string, slot:number} result of removing item
function SStorage:removeItem(itemName, amount, slotNumber)
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
        local item = self:getItemBySlot(slotNumber)
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
    local item = self:getItemBySlot(targetSlot)
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
    
    -- If remaining amount is 0 or less, remove the item entirely from the slot
    if remainingAmount <= 0 then
        self:pop(targetSlot)
        return { status = true, message = SHARED.t('inventory.removed', { count = amount, item = item.name }), slot = targetSlot }
    else
        -- Update the item amount
        local targetSlotItem = self:getItemBySlot(targetSlot)
        if targetSlotItem then
            targetSlotItem.amount = remainingAmount
            self:updateItem(targetSlotItem, targetSlot)
        end

        return { status = true, message = 'Item amount reduced!', slot = targetSlot }
    end
end

---Check if inventory has item with the specified amount
---@param itemName string item name
---@param amount number | nil item amount (optional, defaults to 1 if not provided)
---@return {status:boolean, message:string, totalAmount:number} result of checking item
function SStorage:hasItem(itemName, amount)
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

---Move item to slot (From same container)
---@param item SInventoryItemType item data
---@param targetSlot number target slot number
---@return {status:boolean, message:string, slot:number} result of moving item
function SStorage:moveItem(item, targetSlot)
    -- Validate inputs
    if not item or not targetSlot then
        return { status = false, message = 'Invalid parameters!', slot = -1 }
    end
    local targetItem = self:getItemBySlot(targetSlot)
    if targetItem ~= nil then
        -- Target slot have item
        -- Check if same item and not unique => stack together
        local isSameItem = item.name:lower() == targetItem.name:lower()
        if isSameItem then
            -- Get item definition to check if it's unique
            local itemData = SHARED.items[item.name:lower()]
            if itemData and not itemData.unique then
                -- Same item and not unique => stack together
                local sourceSlot = item.slot
                -- Add source amount to target
                targetItem.amount = targetItem.amount + item.amount
                -- Remove source item
                self:pop(sourceSlot)
                return { status = true, message = 'Items stacked successfully!', slot = targetSlot }
            end
        end
        -- Different item or same item but unique => swap items
        local sourceSlot = item.slot
        local targetItemToSwap, targetIndex = self:getItemBySlot(targetSlot)
        local sourceItem, sourceIndex = self:getItemBySlot(sourceSlot)
        
        if not targetItemToSwap or not sourceItem then
            return { status = false, message = 'Failed to find items for swap!', slot = -1 }
        end
        
        -- Swap items directly in the items table using indices
        self.items[targetIndex] = sourceItem
        self.items[sourceIndex] = targetItemToSwap
        
        -- Update slot properties after swapping in table
        sourceItem.slot = targetSlot
        targetItemToSwap.slot = sourceSlot
    else
        -- Target slot is empty; keep existing reference and just update slot
        item.slot = targetSlot
    end

    return { status = true, message = 'Item moved to slot!', slot = targetSlot }
end

---Split item
---@param slot number slot number
function SStorage:splitItem(slot)
    -- Validate inputs
    if not slot or type(slot) ~= 'number' then
        return { status = false, message = 'Invalid slot number!', slot = -1 }
    end
    -- Get item at slot
    local item = self:getItemBySlot(slot)
    if not item then
        return { status = false, message = SHARED.t('inventory.itemNotFound'), slot = -1 }
    end

    -- Find empty slot
    local emptySlot = self:getEmptySlot()
    if not emptySlot then
        return { status = false, message = SHARED.t('error.noEmptySlotAvailable'), slot = -1 }
    end

    local splittedAmount = math.floor(item.amount / 2)
    local itemBySlot = self:getItemBySlot(slot)
    itemBySlot.amount = item.amount - splittedAmount
    -- Create new item in empty slot
    -- Deep copy info if it exists
    local newItemInfo = item.info and JSON.parse(JSON.stringify(item.info)) or {}

    self:push({
        name = item.name,
        label = item.label,
        weight = item.weight,
        type = item.type,
        image = item.image,
        unique = item.unique,
        useable = item.useable,
        shouldClose = item.shouldClose,
        description = item.description,
        amount = splittedAmount,
        slot = emptySlot,
        info = newItemInfo
    })

    return { status = true, message = 'Item split successfully!', slot = emptySlot }
end

---Check if storage is empty
---@return boolean isEmpty true if storage is empty, false otherwise
function SStorage:isEmpty()
  local totalItems = 0
  for _, item in pairs(self.items) do
      if item ~= nil then
          totalItems = totalItems + 1
      end
  end
  return totalItems == 0
end

---Push an item into an array
---@param item SInventoryItemType item data
function SStorage:push(item)
    -- push an item into an array
    self.items[#self.items + 1] = item
end

---Pop an item from an array by item slot
---@param slot number item slot
---@return boolean result of popping item
function SStorage:pop(slot)
    -- pop an item from an array by item slot
    for index, value in ipairs(self.items) do
        if value.slot == slot then
            table.remove(self.items, index)
            return true
        end
    end

    return false
end

---Update an item in an array by item slot
---@param item SInventoryItemType item data
---@param slot number item slot
---@return boolean result of updating item
function SStorage:updateItem(item, slot)
    for index, value in ipairs(self.items) do
        if value.slot == slot then
            self.items[index] = item
            return true
        end
    end

    return false
end

return SStorage

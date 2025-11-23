---@class SContainer
---@field core TPNRPServer
---@field citizenId string Citizen ID
---@field items table<number, SInventoryItemType>
---@field maxSlot number Max slot count
---@field maxWeight number Max weight in grams
SContainer = {}
SContainer.__index = SContainer

---@param core TPNRPServer Core
---@param containerId string Container ID
---@param citizenId string Citizen ID
---@return SContainer
function SContainer.new(core, containerId, citizenId)
    ---@class SContainer
    local self = setmetatable({}, SContainer)

    -- Core
    self.core = core
    self.citizenId = citizenId -- Citizen ID of the player who owns this container
    self.containerId = containerId
    self.isDestroyOnEmpty = false
    -- items
    self.items = {}

    -- Max slot count of this container
    self.maxSlot = SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
    -- Max weight in grams
    self.maxWeight = SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
    end

    ---Init entity data
    ---@param data {entityId:string; entity:unknown; items:table<number, SInventoryItemType>; maxSlot:number; maxWeight:number; isDestroyOnEmpty:boolean} data
    function self:initEntity(data)
        self.entityId = data.entityId
        self.entity = data.entity
        self.items = data.items
        self.maxSlot = data.maxSlot
        self.maxWeight = data.maxWeight
        self.isDestroyOnEmpty = data.isDestroyOnEmpty or false
    end

    ---/********************************/
    ---/*           Functions          */
    ---/********************************/

    ---Save container
    ---@return boolean status success status
    function self:save()
        local result = DAO.container.save(self, self.citizenId)
        if result then
            return true
        end
        return false
    end

    --- Manually load container if require
    ---@return boolean status success status
    function self:load()
        local container = DAO.container.get(self.containerId)
        if container then
            self.items = container.items
            self.maxSlot = container.maxSlot
            self.maxWeight = container.maxWeight
            return true
        end
        return false
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
    ---@return { status: boolean; message: string; } result is this item can add to inventory or not
    function self:canAddItem(itemName, amount)
        -- Get item data
        local itemData = SHARED.items[itemName:lower()]
        if not itemData then
            print(('[ERROR] SContainer.canAddItem: Item %s not found!'):format(itemName))
            return { status = false, message = 'Item not found!' }
        end
        -- Total item weight
        local itemWeight = itemData.weight * amount
        local containerWeight = self:calculateTotalWeight()
        local totalWeight = containerWeight + itemWeight

        -- Check if item weight is greater than backpack weight limit
        if totalWeight > self.maxWeight then
            return { status = false, message = SHARED.t('error.inventoryWeightLimitReached') }
        end
        
        -- Determine if item is unique (cannot stack)
        local isUnique = itemData.unique or false
        
        -- Check if item already exists in inventory and can be stacked
        local existingItemSlot = self:findItemSlotByName(itemName)
        local needsNewSlot = true
        
        if existingItemSlot and not isUnique then
            -- Item exists and can stack, no new slot needed
            needsNewSlot = false
        end
        
        -- Check if item slots is greater than backpack slots limit
        if needsNewSlot then
            -- Count only non-nil items (filter out nil slots)
            local totalUsedSlots = 0
            for _, item in pairs(self.items) do
                if item ~= nil then
                    totalUsedSlots = totalUsedSlots + 1
                end
            end
            local totalNewUsedSlots = totalUsedSlots + 1
            if totalNewUsedSlots > self.maxSlot then
                return { status = false, message = SHARED.t('error.inventoryFull') }
            end
        end

        return { status = true, message = SHARED.t('inventory.canAddItem') }
    end

    ---Find an empty slot in the inventory
    ---@return number | nil number slot number, or nil if no empty slot found
    function self:getEmptySlot()
        -- Create a set of used slots for quick lookup
        local usedSlots = {}
        for _, item in pairs(self.items) do
            usedSlots[item.slot] = true
        end
        
        -- Find first empty slot
        for slot = 1, self.maxSlot do
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
    function self:findItemSlotByName(itemName)
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
    ---@return {status:boolean, message:string, slot:number} result of adding item
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
                targetSlot = self:findItemSlotByName(itemName)
                
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

        return { status = true, message = SHARED.t('inventory.added'), slot = targetSlot }
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
            targetSlot = self:findItemSlotByName(itemName)
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
        
        -- If remaining amount is 0 or less, remove the item entirely from the slot
        if remainingAmount <= 0 then
            self.items[targetSlot] = nil
            return { status = true, message = SHARED.t('inventory.removed'), slot = targetSlot }
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

    ---Open container
    function self:openContainer()
        local inventory = nil
        -- Filter out nil values from inventory and convert to array
        inventory = {}
        for _, item in pairs(self.items) do
            if item ~= nil then
                table.insert(inventory, item)
            end
        end

        return {
            status = true,
            message = 'Container opened!',
            inventory = inventory,
            capacity = {
                weight = self.maxWeight,
                slots = self.maxSlot,
            }
        }
    end
    
    ---Move item to slot (From same container)
    ---@param item SInventoryItemType item data
    ---@param targetSlot number target slot number
    ---@return {status:boolean, message:string, slot:number} result of moving item
    function self:moveItem(item, targetSlot)
        -- Validate inputs
        if not item or not targetSlot then
            return { status = false, message = 'Invalid parameters!', slot = -1 }
        end
        local targetItem = self:findItemBySlot(targetSlot)
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
                    self.items[sourceSlot] = nil
                    return { status = true, message = 'Items stacked successfully!', slot = targetSlot }
                end
            end
            -- Different item or same item but unique => swap items
            local sourceSlot = item.slot
            local targetItemToSwap = self.items[targetSlot]
            targetItemToSwap.slot = item.slot
            -- Change slot of item
            item.slot = targetSlot
            self.items[targetSlot] = item
            -- Assign item to new slot
            targetItemToSwap.slot = sourceSlot
            self.items[sourceSlot] = targetItemToSwap
        else
            -- Target slot is empty
            -- Remove current item at source slot
            self.items[item.slot] = nil
            -- Assign new slot to item
            item.slot = targetSlot
            -- Assign item to new slot
            self.items[targetSlot] = item
        end

        return { status = true, message = 'Item moved to slot!', slot = targetSlot }
    end

    ---Destroy container
    ---@return {status:boolean, message:string} result of destroying container
    function self:destroy()
        return self.core.gameManager:destroyEntity(self.containerId)
    end

    ---Check if container is empty
    ---@return boolean isEmpty true if container is empty, false otherwise
    function self:isEmpty()
        local totalItems = 0
        for _, item in pairs(self.items) do
            if item ~= nil then
                totalItems = totalItems + 1
            end
        end
        return totalItems == 0
    end

    _contructor()
    ---- END ----
    return self
end

return SContainer
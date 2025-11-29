---@class SEquipment
---@field player SPlayer
---@field items table<EEquipmentClothType, SEquipmentItemType>
---@field type 'player' | 'stack' | ''
SEquipment = {}
SEquipment.__index = SEquipment

---@param player SPlayer player entity
---@return SEquipment
function SEquipment.new(player)
    ---@class SEquipment
    local self = setmetatable({}, SEquipment)

    -- Public
    self.player = player
    self.core = player.core
    self.items = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- Load player's equipment for this player
        local equipment = DAO.equipment.get(self.player.playerData.citizenId)
        if equipment then
            self.items = equipment
            local bagItem = self:getItemByClothType(EEquipmentClothType.Bag)
            if bagItem then
                -- Load backpack's container
                self.core.inventoryManager:initContainer(bagItem.info.containerId, self.player.playerData.citizenId)
                print('[SERVER] Init backpack container ' .. bagItem.info.containerId)
            end
        end
    end

    ---/********************************/
    ---/*           Functions          */
    ---/********************************/

    function self:sync()
        TriggerClientEvent(self.player.playerController, 'TPN:equipment:sync', self.items)
    end

    ---Save equipment
    ---@return boolean status
    function self:save()
        local isSavedBackpack = false
        local backpackContainer = self.player.inventory:getBackpackContainer()
        if backpackContainer then
            isSavedBackpack = backpackContainer:save()
        end
        local isSavedEquipment = DAO.equipment.save(self)

        return isSavedBackpack and isSavedEquipment
    end

    ---Get backpack capacity
    ---@return SEquipmentBackpackCapacityResultType {status=boolean, slots=number, weightLimit=number}
    function self:getBackpackCapacity()
        -- Access backpack capacity via equipment cloth type "Bag", fallback to index 1 if necessary
        local bagItem = self:getItemByClothType(EEquipmentClothType.Bag)
        if not bagItem then
            return {
                status = false,
                slots = 0,
                weightLimit = 0
            }
        end
        -- Return backpack capacity
        return {
            status = true,
            slots = bagItem.info.slotCount or 0,
            weightLimit = bagItem.info.weightLimit or 0
        }
    end

    ---Equip item to slot
    ---@param itemName string item name
    ---@param slotNumber number slot number of current itemName that player want to equip
    ---@return {status:boolean, message:string} success Status when equip item
    function self:equipItem(itemName, slotNumber)
        -- Get item data
        local itemData = SHARED.items[itemName:lower()]
        if not itemData then
            return { status = false, message = 'Item not found!' }
        end
        local item = nil
        local container = nil
        local actualSlotNumber = slotNumber
        if slotNumber <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            -- Inventory
            container = self.player.inventory
            
        else 
            -- Backpack - convert global slot to backpack-local slot
            local backpackContainer = self.player.inventory:getBackpackContainer()
            if backpackContainer then
                container = backpackContainer
                actualSlotNumber = slotNumber - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
            end
        end
        if not container then
            print('[SERVER] [ERROR] sEquipment.equipItem: Container not found!')
            return { status = false, message = 'Container not found!' }
        end

        item = container:getItemBySlot(actualSlotNumber)
        if not item then
            -- [CHEAT] possible event cheat
            self.core.cheatDetector:logCheater({
                action = 'equipItem',
                player = self.player or nil,
                citizenId = self.player.playerData.citizenId or '',
                license = self.player.playerData.license or '',
                name = self.player.playerData.name or '',
                content = ('[ERROR] sEquipment.equipItem: Item %s not found in inventory!'):format(itemName)
            })
            return { status = false, message = 'Item not found in inventory!' }
        end
        -- Verify that the item in the slot matches the provided itemName
        local clothItemType = SHARED.getClothItemTypeByName(itemName)
        if not clothItemType then
            return { status = false, message = SHARED.t('error.itemNotCloth') }
        end
        -- Check if there's already an item equipped in this clothType slot
        local existingItem = self:getItemByClothType(clothItemType)
        if existingItem then
            -- Unequip the existing item first
            local unequipResult = self:unequipItem(clothItemType)
            if not unequipResult.status then
                print(('[ERROR] sEquipment.equipItem: Failed to unequip existing item %s from slot %s!'):format(existingItem.name, clothItemType))
                return { status = false, message = 'Failed to unequip existing item: ' .. unequipResult.message }
            end
        end
        -- Remove item from container (inventory for slot <= 5, backpack for slot > 5)
        -- Use actualSlotNumber for removal to ensure correct slot is used
        local removeResult = container:removeItem(itemName, 1, actualSlotNumber)
        if not removeResult.status then
            print(('[ERROR] sEquipment.equipItem: Failed to remove item %s from inventory!'):format(itemName))
            -- [CHEAT] possible event cheat
            self.core.cheatDetector:logCheater({
                action = 'equipItem',
                player = self.player or nil,
                citizenId = self.player.playerData.citizenId or '',
                license = self.player.playerData.license or '',
                name = self.player.playerData.name or '',
                content = ('[ERROR] sEquipment.equipItem: Item %s is not a cloth item!'):format(itemName)
            })
            return { status = false, message = removeResult.message }
        end
        -- Assign slot to item
        item.slot = clothItemType
        -- Equip item to slot
        ---@cast item SEquipmentItemType
        self:push(item)
        -- On equip backpack it should init container for use
        if clothItemType == EEquipmentClothType.Bag then
            local containerId = item.info.containerId
            -- Init container
            self.core.inventoryManager:initContainer(containerId, self.player.playerData.citizenId)
        end
        -- call client for sync (This mean equip cloth success)
        self:sync() -- Sync equipment
        self.player.inventory:sync() -- Sync inventory
        return { status = true, message = SHARED.t('equipment.equipped') .. ' ' .. item.name }
    end

    ---Unequip item from slot
    ---@param clothItemType EEquipmentClothType cloth item type
    ---@param toSlotNumber number | nil slot number to add item to (optional)
    ---@return {status:boolean, message:string} success Status when unequip item
    function self:unequipItem(clothItemType, toSlotNumber)
        -- Get item data
        local item = self:getItemByClothType(clothItemType)
        if not item then
            print(('[ERROR] sEquipment.unequipItem: Failed to unequip item from slot!'))
            -- [CHEAT] possible event cheat
            -- Player trying to un-equip an clothType that not equipped
            self.core.cheatDetector:logCheater({
                action = 'unequipItem',
                player = self.player or nil,
                citizenId = self.player.playerData.citizenId or '',
                license = self.player.playerData.license or '',
                name = self.player.playerData.name or '',
                content = ('[ERROR] sEquipment.unequipItem: Item %s not found in equipment!'):format(clothItemType)
            })
            return { status = false, message = 'Item not found in equipment!' }
        end
        
        -- If unequipping a bag, save the container before removing it from equipment
        if clothItemType == EEquipmentClothType.Bag then
            local backpackContainer = self.player.inventory:getBackpackContainer()
            if backpackContainer then
                backpackContainer:save()
            end
        end
        
        -- Find container and slot BEFORE removing item from equipment to prevent item loss
        local container = nil
        local emptySlotNumber = nil
        if not toSlotNumber then
            -- Don't have toSlotNumber find emptySlot from inventory then backpack
            local getContainerResult = self.player.inventory:getContainerWithEmptySlot()
            if getContainerResult.status then
                container = getContainerResult.container
                emptySlotNumber = getContainerResult.slotNumber
            end
        else
            -- Have toSlotNumber then find container by toSlotNumber
            container = self.player.inventory:getContainerBySlotNumber(toSlotNumber)
            emptySlotNumber = toSlotNumber
        end
        if not container or not emptySlotNumber then
            return { status = false, message = SHARED.t('inventory.full') }
        end
        
        -- Unequip item from slot (only after confirming we have space)
        self:pop(clothItemType)

        item.slot = emptySlotNumber
        local addResult = container:addItem(item.name, 1, item.slot, item.info)

        if not addResult.status then
            print(('[ERROR] sEquipment.unequipItem: Failed to add item %s to inventory!'):format(item.name))
            -- Restore item to equipment since we failed to add it anywhere
            self:updateItem(item, clothItemType)
            return { status = false, message = addResult.message or SHARED.t('inventory.full') }
        end
        
        -- call client for sync (This mean unequip cloth success)
        self:sync() -- Sync equipment
        self.player.inventory:sync() -- Sync inventory
        return { status = true, message = SHARED.t('equipment.unequipped', { item = item.name }) }
    end

    ---Find item by cloth type
    ---@param clothType EEquipmentClothType cloth type
    ---@return SEquipmentItemType | nil item data, or nil if item not found
    function self:getItemByClothType(clothType)
        for _, value in ipairs(self.items) do
            if value then
                local itemClothType = SHARED.getClothItemTypeByName(value.name)
                if itemClothType == clothType then
                    return value
                end
            end
        end
        return nil
    end

    ---Get equipment
    ---@return table<EEquipmentClothType, SEquipmentItemType> equipment
    function self:getEquipment()
        return self.items
    end

    ---Push an item into an array
    ---@param item SEquipmentItemType item data
    function self:push(item)
        -- push an item into an array
        self.items[#self.items + 1] = item
    end

    ---Pop an item from an array by item slot
    ---@param slot number item slot
    ---@return boolean result of popping item
    function self:pop(slot)
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
    ---@param item SEquipmentItemType item data
    ---@param slot number item slot
    ---@return boolean result of updating item
    function self:updateItem(item, slot)
        for index, value in ipairs(self.items) do
            if value.slot == slot then
                self.items[index] = item
                return true
            end
        end

        return false
    end

    _contructor()
    ---- END ----
    return self
end

return SEquipment
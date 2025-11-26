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
            print('[SERVER] equipment '.. JSON.stringify(equipment))
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
        return DAO.equipment.save(self)
    end

    ---Get backpack capacity
    ---@return SEquipmentBackpackCapacityResultType {status=boolean, slots=number, weightLimit=number}
    function self:getBackpackCapacity()
        -- Access backpack capacity via equipment cloth type "Bag", fallback to index 1 if necessary
        local bagItem = self.items[EEquipmentClothType.Bag] or nil
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
    ---@param slotNumber number slot number
    ---@return {status:boolean, message:string} success Status when equip item
    function self:equipItem(itemName, slotNumber)
        -- Get item data
        local itemData = SHARED.items[itemName:lower()]
        if not itemData then
            return { status = false, message = 'Item not found!' }
        end
        local item = self.player.inventory:findItemBySlot(slotNumber)
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
        local existingItem = self.items[clothItemType]
        if existingItem then
            -- Unequip the existing item first
            local unequipResult = self:unequipItem(clothItemType, '', nil)
            if not unequipResult.status then
                print(('[ERROR] sEquipment.equipItem: Failed to unequip existing item %s from slot %s!'):format(existingItem.name, clothItemType))
                return { status = false, message = 'Failed to unequip existing item: ' .. unequipResult.message }
            end
        end
        
        -- Remove item from inventory
        local removeResult = { status = false, message = 'Container not found!' }
        if slotNumber <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            removeResult = self.player.inventory:removeItem(itemName, 1, item.slot)
        else
            local backpack = self.player.inventory:getBackpackContainer()
            if backpack then
                removeResult = backpack:removeItem(itemName, 1, item.slot)
            end
        end

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

        -- Equip item to slot
        ---@cast item SEquipmentItemType
        self.items[clothItemType] = item
        -- On equip backpack it should init container for use
        if clothItemType == EEquipmentClothType.Bag then
            local containerId = item.info.containerId
            -- Init container
            self.core.inventoryManager:initContainer(containerId, self.player.playerData.citizenId)
        end
        -- call client for sync (This mean equip cloth success)
        self:sync() -- Sync equipment
        self.player.inventory:sync() -- Sync inventory
        return { status = true, message = SHARED.t('equipment.equipped', { item = itemName }) }
    end

    ---Unequip item from slot
    ---@param clothItemType EEquipmentClothType cloth item type
    ---@param containerType 'inventory' | 'backpack' | '' container type
    ---@param toSlotNumber number | nil slot number to add item to (optional)
    ---@return {status:boolean, message:string} success Status when unequip item
    function self:unequipItem(clothItemType, containerType, toSlotNumber)
        -- Get item data
        local item = self.items[clothItemType]
        print('[SERVER] unequipItem ' .. clothItemType)
        if not item then
            print(('[ERROR] sEquipment.unequipItem: Failed to unequip item from slot!'))
            -- [CHEAT] possible event cheat
            return { status = false, message = 'Item not found in equipment!' }
        end
        -- Unequip item from slot
        self.items[clothItemType] = nil
        
        -- Helper function to try adding item to a container
        local function tryAddToContainer(container, slot)
            if not container then return { status = false } end
            
            local targetSlot = slot
            if not targetSlot then
                targetSlot = container:getEmptySlot()
            end
            
            if not targetSlot then
                return { status = false, message = SHARED.t('inventory.full') }
            end
            
            -- Check if specific slot is occupied if provided
            if slot then
                local slotItem = container:findItemBySlot(slot)
                if slotItem then
                    local newEmptySlot = container:getEmptySlot()
                    if not newEmptySlot then
                        return { status = false, message = SHARED.t('inventory.full') }
                    end
                    targetSlot = newEmptySlot
                end
            end
            
            local addResult = container:addItem(item.name, 1, targetSlot)
            return addResult
        end

        local addResult = { status = false, message = SHARED.t('inventory.full') }
        
        -- Fallback logic
        if containerType == 'backpack' then
            -- Priority: Backpack -> Inventory
            local backpack = self.player.inventory:getBackpackContainer()
            if backpack then
                addResult = tryAddToContainer(backpack, toSlotNumber)
            end
            
            if not addResult.status then
                -- Fallback to inventory
                addResult = tryAddToContainer(self.player.inventory, nil) -- Don't use toSlotNumber for fallback
            end
        else
            -- Priority: Inventory -> Backpack
            addResult = tryAddToContainer(self.player.inventory, toSlotNumber)
            
            if not addResult.status then
                -- Fallback to backpack
                local backpack = self.player.inventory:getBackpackContainer()
                if backpack then
                    addResult = tryAddToContainer(backpack, nil) -- Don't use toSlotNumber for fallback
                end
            end
        end

        if not addResult.status then
            print(('[ERROR] sEquipment.unequipItem: Failed to add item %s to inventory!'):format(item.name))
            -- Restore item to equipment since we failed to add it anywhere
            self.items[clothItemType] = item
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
    function self:findItemByClothType(clothType)
        return self.items[clothType] or nil
    end

    ---Get equipment
    ---@return table<EEquipmentClothType, SEquipmentItemType> equipment
    function self:getEquipment()
        return self.items
    end

    function self:swapEquipItem(sourceItemClothType, containerType, targetSlot)
        local sourceItem = self.items[sourceItemClothType]
        if not sourceItem then
            print(('[ERROR] sEquipment.swapEquipItem: Failed to find source item %s!'):format(sourceItemClothType))
            return { status = false, message = 'Source item not found!' }
        end
        local container = nil
        if containerType == 'backpack' then
            container = self.player.inventory:getBackpackContainer()
        else
            container = self.player.inventory
        end
        if not container then
            print(('[ERROR] sEquipment.swapEquipItem: Failed to find container %s!'):format(containerType))
            return { status = false, message = 'Container not found!' }
        end

        local targetItem = container:findItemBySlot(targetSlot)
        if not targetItem then
            print(('[ERROR] sEquipment.swapEquipItem: Failed to find target item %s!'):format(targetSlot))
            return { status = false, message = 'Target item not found!' }
        end
        local targetItemClothType = SHARED.getItemClothType(targetItem.name)
        if not targetItemClothType then
            print(('[ERROR] sEquipment.swapEquipItem: Failed to find target item cloth type %s!'):format(targetItem.name))
            return { status = false, message = 'Target item is not cloth type!' }
        end
        if sourceItemClothType ~= targetItemClothType then
            print(('[ERROR] sEquipment.swapEquipItem: Source item and target item are not the same cloth type %s!'):format(sourceItemClothType))
            return { status = false, message = 'Source item and target item are not the same cloth type!' }
        end
        local sourceItem = self.items[sourceItemClothType]
        -- 1. Empty equipment slot
        self.items[sourceItemClothType] = nil
        -- 2. Equip targetItem
        self:equipItem(sourceItemClothType, targetSlot)

        
        return { status = true, message = 'Item swapped successfully!' }
    end

    _contructor()
    ---- END ----
    return self
end

return SEquipment
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
        if slotNumber <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            -- Inventory
            container = self.player.inventory
            
        else 
            -- Backpack
            local backpackContainer = self.player.inventory:getBackpackContainer()
            if backpackContainer then
                container = backpackContainer
            end
        end
        if not container then
            print('[SERVER] [ERROR] sEquipment.equipItem: Container not found!')
            return { status = false, message = 'Container not found!' }
        end

        item = container:findItemBySlot(slotNumber)

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
            local unequipResult = self:unequipItem(clothItemType)
            if not unequipResult.status then
                print(('[ERROR] sEquipment.equipItem: Failed to unequip existing item %s from slot %s!'):format(existingItem.name, clothItemType))
                return { status = false, message = 'Failed to unequip existing item: ' .. unequipResult.message }
            end
        end
        
        -- Remove item from container (inventory for slot <= 5, backpack for slot > 5)
        local removeResult = container:removeItem(itemName, 1, item.slot)

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
    ---@param toSlotNumber number | nil slot number to add item to (optional)
    ---@return {status:boolean, message:string} success Status when unequip item
    function self:unequipItem(clothItemType, toSlotNumber)
        -- Get item data
        local item = self.items[clothItemType]
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
        -- Unequip item from slot
        self.items[clothItemType] = nil
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

        item.slot = emptySlotNumber
        local addResult = container:addItem(item.name, 1, item.slot, item.info)

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

    _contructor()
    ---- END ----
    return self
end

return SEquipment
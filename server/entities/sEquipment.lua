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
            weightLimit = bagItem.info.WeightLimit or 0
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
        -- Remove item from inventory
        local removeResult = self.player.inventory:removeItem(itemName, 1, item.slot)
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
            print(('[ERROR] sEquipment.unequipItem: Failed to unequip item %s from slot %s!'):format(clothItemType, item.name))
            -- [CHEAT] possible event cheat
            return { status = false, message = 'Item not found in equipment!' }
        end
        -- Unequip item from slot
        self.items[clothItemType] = nil
        -- Find empty slot
        if not toSlotNumber then
            toSlotNumber = self.player.inventory:getEmptySlot()
            if not toSlotNumber then
                return { status = false, message = SHARED.t('inventory.full') }
            end
        else
            -- Have toSlotNumber
            -- Check if slot have item or not
            local slotItem = self.player.inventory:findItemBySlot(toSlotNumber)
            if slotItem then
                -- Slot have item
                local newEmptySlot = self.player.inventory:getEmptySlot()
                if not newEmptySlot then
                    return { status = false, message = SHARED.t('inventory.full') }
                end
                -- Assign new slot into toSlotNumber
                toSlotNumber = newEmptySlot
            end
        end
        -- Add item to inventory
        local addResult = self.player.inventory:addItem(item.name, 1, toSlotNumber)
        if not addResult.status then
            print(('[ERROR] sEquipment.unequipItem: Failed to add item %s to inventory!'):format(item.name))
            return { status = false, message = addResult.message }
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
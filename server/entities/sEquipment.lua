---@class sEquipment
---@field player SPlayer
---@field items table<EEquipmentClothType, SEquipmentItemType>
---@field type 'player' | 'stack' | ''
sEquipment = {}
sEquipment.__index = sEquipment

---@return sEquipment
function sEquipment.new(player)
    ---@class sEquipment
    local self = setmetatable({}, sEquipment)

    -- Public
    self.player = player
    self.items = {}

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- Load player's equipment for this player
        local equipment = DAO.equipment.get(self.player.playerData.citizen_id)
        if equipment then
            self.items = equipment
        end
    end

    /********************************/
    /*           Functions          */
    /********************************/

    ---Save equipment
    ---@return boolean success
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
            print(('[ERROR] sEquipment.equipItem: Item %s not found in inventory!'):format(itemName))
            -- [CHEAT] possible event cheat
            return { status = false, message = 'Item not found in inventory!' }
        end
        local clothItemType = SHARED.getClothItemTypeByName(itemName)
        if not clothItemType then
            print(('[ERROR] sEquipment.equipItem: Item %s is not a cloth item!'):format(itemName))
            -- [CHEAT] possible event cheat
            return { status = false, message = 'Item is not a cloth item!' }
        end
        -- Remove item from inventory
        local removeResult = self.player.inventory:removeItem(itemName, 1, slotNumber)
        if not removeResult.status then
            print(('[ERROR] sEquipment.equipItem: Failed to remove item %s from inventory!'):format(itemName))
            -- [CHEAT] possible event cheat
            return { status = false, message = removeResult.message }
        end

        -- Equip item to slot
        ---@cast item SEquipmentItemType
        self.items[clothItemType] = item
        -- call client for sync (This mean equip cloth success)
        TriggerClientEvent('TPN:equipment:sync', self.player.playerSource, clothItemType, itemName)
        return { status = true, message = 'Item equipped to slot!' }
    end

    _contructor()
    ---- END ----
    return self
end

return sEquipment
---@class sEquipment
---@field player SPlayer
---@field items table<EEquipmentClothType, sEquipmentItemType>
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
    ---@return sEquipmentBackpackCapacityResultType {status=boolean, slots=number, weightLimit=number}
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

    _contructor()
    ---- END ----
    return self
end

return sEquipment
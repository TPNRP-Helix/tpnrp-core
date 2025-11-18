---@class CEquipment
---@field player CPlayer player entity
---@field items table<EEquipmentClothType, SEquipmentItemType>
CEquipment = {}
CEquipment.__index = CEquipment

---@param player CPlayer player entity
---@return CEquipment
function CEquipment.new(player)
    ---@class CEquipment
    local self = setmetatable({}, CEquipment)

    self.core = player.core
    self.player = player
    ---@type table<EEquipmentClothType, SEquipmentItemType>
    self.items = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        RegisterClientEvent('TPN:equipment:sync', function(items)
            self:onSyncEquipment(items)
        end)
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    function self:onSyncEquipment(items)
        self.items = items
        -- Update UI for items changes
        self.core.webUI:sendEvent('doSyncEquipment', {
            type = 'sync',
            items = items
        })
    end

    _contructor()
    ---- END ----
    return self
end

return CEquipment
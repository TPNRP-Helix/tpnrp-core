local SStorage = require('server/entities/sStorage')

---@class SInventory : SStorage
---@field core TPNRPServer
---@field player SPlayer
---@field items table<number, SInventoryItemType>
---@field type 'player' | 'stack' | ''
SInventory = {}
SInventory.__index = SInventory
setmetatable(SInventory, { __index = SStorage })

---@param player SPlayer player entity
---@param inventoryType 'player' | 'stack' | ''
---@return SInventory
function SInventory.new(player, inventoryType)
    ---@class SInventory
    local self = setmetatable({}, SInventory)

    -- Core
    self.core = player.core
    -- Player's entity
    self.player = player
    self.type = inventoryType
    self.items = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- type is player then load it
        if inventoryType == 'player' then
            self:load('player')
        end
    end

    ---/********************************/
    ---/*           Functions          */
    ---/********************************/

    ---Sync inventory
    function self:sync()
        TriggerClientEvent(self.player.playerController, 'TPN:inventory:sync', self.items)
    end

    ---Save inventory
    ---@return boolean status success status
    function self:save()
        return DAO.inventory.save(self)
    end

    ---Load inventory
    ---@param inventoryType 'player' | 'stack' | ''
    ---@return boolean status success status
    function self:load(inventoryType)
        -- Type is empty then don't load inventory
        if inventoryType == '' then
            return false
        end
        -- Assign type
        self.type = inventoryType
        -- Get inventory items
        local inventories = DAO.inventory.get(self.player.playerData.citizenId, self.type)
        if inventories then
            self.items = inventories
        end

        return true
    end

    ---Get max weight
    ---@return number
    function self:getMaxWeight()
        local inventoryCapacity = { status = false, slots = 0, weightLimit = 0 }
        if self.type == 'player' then
            inventoryCapacity = self.player.equipment:getBackpackCapacity()
        end
        return SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT + inventoryCapacity.weightLimit
    end

    ---Get max slots
    ---@return number
    function self:getMaxSlots()
        local inventoryCapacity = { status = false, slots = 0, weightLimit = 0 }
        if self.type == 'player' then
            inventoryCapacity = self.player.equipment:getBackpackCapacity()
        end
        return SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS + inventoryCapacity.slots
    end

    ---Add item to inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@param slotNumber number | nil slot number (optional)
    ---@param info table | nil item info (optional)
    ---@return SInventoryAddItemResultType {status=boolean, message=string, slot=number} result of adding item
    function self:addItem(itemName, amount, slotNumber, info)
        local result = SStorage.addItem(self, itemName, amount, slotNumber, info)
        
        if result.status then
             -- Tell player that item is added to inventory
            TriggerClientEvent(self.player.playerController, 'TPN:inventory:sync', 'add', amount, itemName)
            -- Trigger mission action
            self.player.missionManager:triggerAction('add_item', {
                name = itemName,
                amount = amount,
                info = info or {}
            })
            -- Sync inventory to client
            self:sync()
        end
        
        return result
    end

    ---Remove item from inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@param slotNumber number | nil slot number (optional)
    ---@return {status:boolean, message:string, slot:number} result of removing item
    function self:removeItem(itemName, amount, slotNumber)
        local result = SStorage.removeItem(self, itemName, amount, slotNumber)
        
        if result.status then
            -- Tell player that item is remove from inventory
            TriggerClientEvent(self.player.playerController, 'TPN:inventory:sync', 'remove', amount, itemName)
            -- Trigger mission action
            self.player.missionManager:triggerAction('remove_item', {
                name = itemName,
                amount = amount,
            })
            -- Sync inventory to client
            self:sync()
        end
        
        return result
    end

    ---Open inventory of current player
    ---@return TInventoryOpenInventoryResultType result
    function self:openInventory()
        local inventory = nil
        -- Filter out nil values from inventory and convert to array
        inventory = {}
        for _, item in pairs(self.items) do
            if item ~= nil then
                table.insert(inventory, item)
            end
        end
        local backpackCapacity = self.player.equipment:getBackpackCapacity()
        local equipment = self.player.equipment:getEquipment()

        return {
            status = true,
            message = 'Inventory opened!',
            inventory = inventory,
            equipment = equipment,
            capacity = {
                weight = SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT + backpackCapacity.weightLimit,
                slots = SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS + backpackCapacity.slots,
            }
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SInventory

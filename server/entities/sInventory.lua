local SStorage = require('server/entities/sStorage')
local SContainer = require('server/entities/sContainer')

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
        local backpack = self:getBackpackContainer()
        local backpackItems = {}
        local isHaveBackpack = false
        local slotCount = 0
        local maxWeight = 0
        if backpack then
            isHaveBackpack = true
            backpackItems = backpack.items
            slotCount = SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS + backpack:getMaxSlots()
            maxWeight = SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT + backpack:getMaxWeight()
        end

        TriggerClientEvent(self.player.playerController, 'clientSyncInventory', self.items, {
            isHaveBackpack = isHaveBackpack,
            slotCount = slotCount,
            maxWeight = maxWeight,
            items = backpackItems
        })
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
        local inventories = DAO.inventory.get(self.player.playerData.citizenId)
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

    ---Get backpack container
    ---@return SContainer | nil
    function self:getBackpackContainer()
        local backpack = self.player.equipment:getItemByClothType(EEquipmentClothType.Bag)
        if backpack and backpack.info and backpack.info.containerId then
            local containerId = backpack.info.containerId
            local containerResult = self.core.inventoryManager:openContainerId(containerId)
            if not containerResult.status then
                print('[SERVER] Failed to open container ' .. containerId)
            end
            return containerResult.container
        end
    end

    ---Add item to inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@param slotNumber number | nil slot number (optional)
    ---@param info table | nil item info (optional)
    ---@param isSync boolean | nil is sync inventory to client (optional, default is true)
    ---@return SInventoryAddItemResultType {status=boolean, message=string, slot=number} result of adding item
    function self:addItem(itemName, amount, slotNumber, info, isSync)
        if isSync == nil then
            isSync = true
        end
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
            if isSync then
                -- Sync inventory to client
                self:sync()
            end
        end
        
        return result
    end

    ---Remove item from inventory
    ---@param itemName string item name
    ---@param amount number item amount
    ---@param slotNumber number | nil slot number (optional)
    ---@param isSync boolean | nil is sync inventory to client (optional, default is true)
    ---@return {status:boolean, message:string, slot:number} result of removing item
    function self:removeItem(itemName, amount, slotNumber, isSync)
        if isSync == nil then
            isSync = true
        end
        local result = SStorage.removeItem(self, itemName, amount, slotNumber)
        if result.status then
            -- Tell player that item is remove from inventory
            TriggerClientEvent(self.player.playerController, 'TPN:inventory:sync', 'remove', amount, itemName)
            -- Trigger mission action
            self.player.missionManager:triggerAction('remove_item', {
                name = itemName,
                amount = amount,
            })
            if isSync then
            -- Sync inventory to client
                self:sync()
            end
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
        local backpack = self:getBackpackContainer()
        local bacpackItems = {}
        if backpack then
            bacpackItems = backpack.items
        end

        return {
            status = true,
            message = 'Inventory opened!',
            inventory = inventory,
            equipment = equipment,
            backpack = bacpackItems,
            capacity = {
                weight = SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT + backpackCapacity.weightLimit,
                slots = SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS + backpackCapacity.slots,
            }
        }
    end

    ---Get container by slot number
    ---@param slotNumber number slot number
    ---@return SContainer|SInventory|nil container
    function self:getContainerBySlotNumber(slotNumber)
        if slotNumber <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            return self
        else
            return self:getBackpackContainer()
        end
    end

    ---Get container with empty slot
    ---@return {status: boolean; container: SContainer|SInventory|nil; slotNumber: number} response
    function self:getContainerWithEmptySlot()
        -- Looking empty slot from inventory first
        local emptySlot = self:getEmptySlot()
        if emptySlot then
            return {
                status = true,
                container = self,
                slotNumber = emptySlot,
            }
        end
        -- Looking empty slot from 
        local backpack = self:getBackpackContainer()
        if not backpack then
            -- Don't have backpack and inventory is full
            return {
                status = false,
                message = 'Don\'t have backpack and inventory is full',
            }
        end
        emptySlot = backpack:getEmptySlot()
        if emptySlot then
            return {
                status = true,
                container = backpack,
                slotNumber = emptySlot,
            }
        end
        -- Backpack and inventory is full
        return {
            status = false,
            message = 'Backpack and inventory is full',
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SInventory

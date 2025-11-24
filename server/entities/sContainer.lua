local SStorage = require('server/entities/sStorage')

---@class SContainer : SStorage
---@field core TPNRPServer
---@field citizenId string Citizen ID
---@field items table<number, SInventoryItemType>
---@field maxSlot number Max slot count
---@field maxWeight number Max weight in grams
SContainer = {}
SContainer.__index = SContainer
setmetatable(SContainer, { __index = SStorage })

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
    self.interactableEntity = nil
    -- items
    self.items = {}

    self.position = nil
    self.rotation = nil

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
    ---@param data InitContainer data
    function self:initEntity(data)
        self.entityId = data.entityId
        self.entity = data.entity
        self.interactableEntity = data.interactableEntity
        self.items = data.items
        self.maxSlot = data.maxSlot
        self.maxWeight = data.maxWeight
        self.isDestroyOnEmpty = data.isDestroyOnEmpty or false
        self.position = data.position
        self.rotation = data.rotation
    end

    ---/********************************/
    ---/*           Functions          */
    ---/********************************/

    ---Save container
    ---@return boolean status success status
    function self:save()
        local result = DAO.container.save(self)
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
            self.isDestroyOnEmpty = container.isDestroyOnEmpty
            self.position = container.position
            self.rotation = container.rotation
            return true
        end
        return false
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
    
    ---Destroy container
    ---@return {status:boolean, message:string} result of destroying container
    function self:destroy()
        if self.interactableEntity then
            DeleteEntity(self.interactableEntity)
        end
        if self.entity then
            DeleteEntity(self.entity)
        end
        return { status = true, message = 'Container destroyed successfully!' }
    end

    _contructor()
    ---- END ----
    return self
end

return SContainer
---@class SInventoryType
---@field id string
---@field citizen_id string
---@field inventories table<number, SInventoryItemType>
---@field type 'player' | 'stack'

---@class SInventoryItemType
---@field amount number
---@field info table
---@field slot number
---@field name string           -- [DB]
---@field label string          -- [DB]
---@field weight number         -- [DB]
---@field type string           -- [DB] 'item' | 'weapon' | 'ammo' | 'tool' | 'material' | 'other'
---@field image string          -- [DB]
---@field unique boolean        -- [DB] this item is unique for slot. Meaning 1 slot can only have 1 of this item
---@field useable boolean       -- [DB]
---@field shouldClose boolean   -- [DB]
---@field description string    -- [DB]

---@class SInventoryCanAddItemResultType
---@field status boolean
---@field message string

---@class SInventoryAddItemResultType
---@field status boolean
---@field message string
---@field slot number

---@class TContainer
---@field id string -- Id of container
---@field items table<number, SInventoryItemType> -- list items in container
---@field entityId string -- Id of entity
---@field entity unknown -- Entity of container
---@field maxSlot number -- Max slot count
---@field maxWeight number -- Max weight in grams

---@class TInventoryOpenInventoryResultType -- Response object when called open inventory
---@field status boolean -- Status of response
---@field message string -- message
---@field inventory table<number, SInventoryItemType> -- player's inventory
---@field equipment table<EEquipmentClothType, SEquipmentItemType> -- player's equipment
---@field container {id: string; items: table<number, SInventoryItemType>}|nil -- container's inventory

---@class TResponseCreateDropItem
---@field status boolean -- Status of response
---@field message string -- message
---@field itemData { itemName: string; amount: number; fromSlot: number }


---@class TWorldItem
---@field path string   - Path to origin resource
---@field scale Vector3 - Scale of this entity in world
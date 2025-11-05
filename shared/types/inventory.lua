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
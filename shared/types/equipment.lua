---@class SEquipmentItemInfoType
---@field slotCount number
---@field weightLimit number

---@class SEquipmentItemType: SInventoryItemType
---@field slot number
---@field info SEquipmentItemInfoType
---@field name string           -- [DB]
---@field label string          -- [DB]
---@field weight number         -- [DB]
---@field type string           -- [DB] 'item' | 'weapon' | 'ammo' | 'tool' | 'material' | 'other'
---@field image string          -- [DB]
---@field unique boolean        -- [DB] this item is unique for slot. Meaning 1 slot can only have 1 of this item
---@field useable boolean       -- [DB]
---@field shouldClose boolean   -- [DB]
---@field description string    -- [DB]


---@class SEquipmentBackpackCapacityResultType
---@field status boolean
---@field slots number
---@field weightLimit number
---@enum EEquipmentClothType
EEquipmentClothType = {
    Head = "head",
    Mask = "mask",
    HairStyle = "hairstyle",
    Torso = "torso",
    Leg = "leg",
    Bag = "bag",
    Shoes = "shoes",
    Accessories = "accessories",
    Undershirts = "undershirts",
    Armor = "armor",
    Decal = "decal",
    Top = "top",
    Hat = "hat",
    Glasses = "glasses",
    Ears = "ears",
    Null1 = "null1",
    Null2 = "null2",
    Null3 = "null3",
    Watch = "watch",
    Bracelets = "bracelets"
}

---@class SEquipmentItemInfoType
---@field slotCount number
---@field WeightLimit number

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
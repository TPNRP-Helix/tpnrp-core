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

---@class sEquipmentItemInfoType
---@field slotCount number
---@field WeightLimit number

---@class sEquipmentItemType
---@field slot number
---@field info sEquipmentItemInfoType
---@field name string           -- [DB]
---@field label string          -- [DB]
---@field weight number         -- [DB]
---@field type string           -- [DB] 'item' | 'weapon' | 'ammo' | 'tool' | 'material' | 'other'
---@field image string          -- [DB]
---@field unique boolean        -- [DB] this item is unique for slot. Meaning 1 slot can only have 1 of this item
---@field useable boolean       -- [DB]
---@field shouldClose boolean   -- [DB]
---@field description string    -- [DB]


---@class sEquipmentBackpackCapacityResultType
---@field status boolean
---@field slots number
---@field weightLimit number
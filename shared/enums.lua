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

---@enum EWebUIInputMode
EWebUIInputMode = {
    None = 0,   -- Focus on game world
    UI = 1,     -- Focus on UI only
    Both = 2    -- Focus on game world and UI
}

---@enum ECollisionType
ECollisionType = {
    Normal = CollisionType.Normal, -- Standard collision based on channel settings
    StaticOnly = CollisionType.StaticOnly, -- Only collides with static objects
    NoCollision = CollisionType.NoCollision, -- Ignores all collisions
    IgnoreOnlyPawn = CollisionType.IgnoreOnlyPawn, -- Ignores player and NPCs, but collides with everything else
    Auto = CollisionType.Auto, -- Chooses the best setting automatically
}

---@enum EMobilityType
EMobilityType = {
    Static = EComponentMobility.Static,
    Movable = EComponentMobility.Movable,
    Stationary = EComponentMobility.Stationary
}
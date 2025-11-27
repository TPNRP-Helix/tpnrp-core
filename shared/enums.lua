---@enum EEquipmentClothType
EEquipmentClothType = {
    Hat = 1,
    Glasses = 2,
    Ears = 3,
    Top = 4,
    Undershirts = 5,
    Leg = 6,
    Shoes = 7,
    Bag = 8,
    Bracelets = 9,
    Watch = 10,
    Mask = 11,
    Accessories = 12,
    Torso = 13, -- Torso is Gloves
    Armor = 14,
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
    Static = UE.EComponentMobility.Static,
    Movable = UE.EComponentMobility.Movable,
    Stationary = UE.EComponentMobility.Stationary
}
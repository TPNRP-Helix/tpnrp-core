export const EEquipmentSlot = {
    Head: 1,
    Mask: 2,
    HairStyle: 3,
    Torso: 4,
    Leg: 5,
    Bag: 6,
    Shoes: 7,
    Accessories: 8,
    Undershirts: 9,
    Armor: 10,
    Decal: 11,
} as const

export type EEquipmentSlot = typeof EEquipmentSlot[keyof typeof EEquipmentSlot]
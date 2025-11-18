/**
    Glasses: 2,
    Ears: 3,
    Top: 4,
    Undershirts: 5,
    
    Bag: 8,
    Bracelets: 9,
    Watch: 10,
    Mask: 11,
    Accessories: 12
 */

export const EEquipmentSlot = {
    Hat: 1,
    Glasses: 2,
    Ears: 3,
    Top: 4,
    Undershirts: 5,
    Leg: 6,
    Shoes: 7,
    Bag: 8,
    Bracelets: 9,
    Watch: 10,
    Mask: 11,
    Accessories: 12,
    Gloves: 13,
    Armor: 14
} as const

export type EEquipmentSlot = typeof EEquipmentSlot[keyof typeof EEquipmentSlot]
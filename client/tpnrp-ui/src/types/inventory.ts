export type TInventoryItem = {
    amount: number
    name: string
    label: string
    weight: number // Weight in gram
    slot: number // slot number of this item
    description?: string // Description of this item
    useable?: boolean // Whether this item is useable
    info?: {
        rare?: number // From 1 to 5
        durability?: number // From 0 to 100
        maxWeight?: number // In gram
        slot?: number // slot count of this item (This field is for backpack)
    }
}

export type TInventoryGroup = 'equipment' | 'inventory' | 'other'

export type TInventoryItemProps = {
    item?: TInventoryItem
    slot?: number
    group?: TInventoryGroup
    isShowHotbarNumber?: boolean
}

export type TCraftingRecipe = {
    
}
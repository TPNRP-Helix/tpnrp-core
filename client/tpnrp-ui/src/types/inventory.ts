export type TInventoryItem = {
    amount: number
    name: string
    label: string
    weight: number // Weight in gram
    slot: number // slot number of this item
    description?: string // Description of this item
    useable?: boolean // Whether this item is useable
    unique?: boolean // Whether this item is unique (cannot stack)
    info?: {
        rare?: number // From 1 to 5
        durability?: number // From 0 to 100
        maxWeight?: number // In gram
        slot?: number // slot count of this item (This field is for backpack)
    }
}

export type TInventoryGroup = 'equipment' | 'inventory' | 'container' | 'devLibrary'

export type TInventoryItemProps = {
    item?: TInventoryItem
    slot?: number
    group?: TInventoryGroup
    isShowHotbarNumber?: boolean
    isDragDropDisabled?: boolean
}

export type TCraftingRecipe = {
    
}

export type TInventoryOpenInventoryResultType = {
    status: boolean
    message: string
    inventory: TInventoryItem[]
    container: {
        id: string
        items: TInventoryItem[]
    } | null
}

export type TResponseCreateDropItem = {
    status: boolean
    message: string
    itemData: {
        itemName: string
        amount: number
        fromSlot: number
    }
}

export type TResponseSplitItem = {
    status: boolean
    message: string
}
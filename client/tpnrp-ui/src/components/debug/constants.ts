import type { TInventoryItem } from "@/types/inventory";

export const FAKE_INVENTORY_ITEMS: TInventoryItem[] = [
    {
        amount: 1,
        name: 'id_card',
        label: 'ID Card',
        weight: 20,
        slot: 1
    },
    {
        amount: 10,
        name: 'wood_log',
        label: 'Wood Log',
        weight: 100,
        slot: 3
    },
    {
        amount: 1,
        name: 'phone',
        label: 'Mobile Phone',
        weight: 500,
        slot: 4
    }
]

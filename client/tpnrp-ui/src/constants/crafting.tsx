import { Apple, Boxes, BrickWall, CircleDot, Diamond, Package, Sword, Syringe, Wrench } from "lucide-react";
export type TCraftingCategory = {
    name: string
    value: string
    icon: React.ReactNode
}

export const CRAFTING_CATEGORIES: TCraftingCategory[] = [
    {
        name: 'crafting.category.all',
        value: 'all',
        icon: <Boxes className="size-4" />
    },
    {
        name: 'crafting.category.weapon',
        value: 'weapon',
        icon: <Sword className="size-4" />
    },
    {
        name: 'crafting.category.ammo',
        value: 'ammo',
        icon: <CircleDot className="size-4" />
    },
    {
        name: 'crafting.category.tool',
        value: 'tool',
        icon: <Wrench className="size-4" />
    },
    {
        name: 'crafting.category.food',
        value: 'food',
        icon: <Apple className="size-4" />
    },
    {
        name: 'crafting.category.medicine',
        value: 'medicine',
        icon: <Syringe className="size-4" />
    },
    {
        name: 'crafting.category.material',
        value: 'material',
        icon: <Diamond className="size-4" />
    },
    {
        name: 'crafting.category.building',
        value: 'building',
        icon: <BrickWall className="size-4" />
    },
    {
        name: 'crafting.category.other',
        value: 'other',
        icon: <Package className="size-4" />
    },
]
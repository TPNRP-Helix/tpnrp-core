import { EEquipmentSlot } from "@/constants/enum";
import type { TInventoryItem } from "@/types/inventory";
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export const getEquipmentSlotName = (value: number) => {
    return Object.keys(EEquipmentSlot).find(key => 
        EEquipmentSlot[key as keyof typeof EEquipmentSlot] === value
    )
}

export const isInBrowser = () => {
  return typeof window !== 'undefined' && !window.hEvent;
}

/**
 * Parse any container items array or object to array of items 
 * Due communication between lua and javascript that empty array being treat as object
 * 
 * @param items any container items array or object
 * @returns array of items
 */
export const parseArrayItems = (items: TInventoryItem[]): TInventoryItem[] => {
    if (Array.isArray(items)) {
        // It's an array
        return items
    } else if (items && typeof items === 'object') {
        // It's an object (not an array)
        const parsedItems: TInventoryItem[] = Object.values(items).filter(item => item !== null) as TInventoryItem[]
        return parsedItems
    }

    return []
}
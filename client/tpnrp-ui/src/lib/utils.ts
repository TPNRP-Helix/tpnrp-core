import { EEquipmentSlot } from "@/constants/enum";
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export const getEquipmentSlotName = (value: number) => {
    return Object.keys(EEquipmentSlot).find(key => 
        EEquipmentSlot[key as keyof typeof EEquipmentSlot] === value
    );
}

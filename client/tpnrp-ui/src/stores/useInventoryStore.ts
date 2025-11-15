import { create } from "zustand"

type InventoryState = {
  isOpenInventory: boolean
  isHaveOtherItems: boolean
  setOpenInventory: (value: boolean) => void
  setIsHaveOtherItems: (value: boolean) => void
}

export const useInventoryStore = create<InventoryState>((set) => ({
  isOpenInventory: false,
  isHaveOtherItems: false,
  setOpenInventory: (value: boolean) => set({ isOpenInventory: value }),
  setIsHaveOtherItems: (value: boolean) => set({ isHaveOtherItems: value }),
}))


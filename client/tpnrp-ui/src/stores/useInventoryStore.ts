import { EEquipmentSlot } from "@/constants/enum"
import type { TInventoryItem } from "@/types/inventory"
import { create } from "zustand"

type InventoryState = {
  isOpenInventory: boolean
  isHaveOtherItems: boolean
  otherItems: TInventoryItem[]
  otherItemsType: 'ground' | 'player' | 'stack'
  otherItemsSlotCount: number
  isOpenAmountDialog: boolean
  amountDialogType: 'give' | 'drop'
  dialogItem: TInventoryItem | null
  inventoryItems: TInventoryItem[]
  slotCount: number
  equipmentItems: TInventoryItem[]
  setEquipmentItems: (items: TInventoryItem[]) => void
  setSlotCount: (value: number) => void
  setInventoryItems: (items: TInventoryItem[]) => void
  setOpenInventory: (value: boolean) => void
  setIsHaveOtherItems: (value: boolean) => void
  setIsOpenAmountDialog: (value: boolean) => void
  setAmountDialogType: (value: 'give' | 'drop') => void
  resetAmountDialog: () => void
  setDialogItem: (item: TInventoryItem) => void
  setOtherItems: (items: TInventoryItem[]) => void
  setOtherItemsType: (value: 'ground' | 'player' | 'stack') => void
  setOtherItemsSlotCount: (value: number) => void
  getEquipmentItem: (equipSlot: EEquipmentSlot) => TInventoryItem | undefined
}

export const useInventoryStore = create<InventoryState>((set, get) => ({
  isOpenInventory: false,
  isHaveOtherItems: false,
  isOpenAmountDialog: false,
  amountDialogType: 'drop',
  dialogItem: null,
  inventoryItems: [],
  slotCount: 6,
  otherItems: [],
  otherItemsType: 'ground',
  otherItemsSlotCount: 0,
  equipmentItems: [],
  setEquipmentItems: (items: TInventoryItem[]) => set({ equipmentItems: items }),
  setSlotCount: (value: number) => set({ slotCount: value }),
  setOpenInventory: (value: boolean) => set({ isOpenInventory: value }),
  setIsHaveOtherItems: (value: boolean) => set({ isHaveOtherItems: value }),
  setIsOpenAmountDialog: (value: boolean) => set({ isOpenAmountDialog: value }),
  setAmountDialogType: (value: 'give' | 'drop') => set({ amountDialogType: value }),
  resetAmountDialog: () => set({ isOpenAmountDialog: false, amountDialogType: 'drop' }),
  setDialogItem: (item: TInventoryItem) => set({ dialogItem: item }),
  setInventoryItems: (items: TInventoryItem[]) => set({ inventoryItems: items }),
  setOtherItems: (items: TInventoryItem[]) => set({ otherItems: items }),
  setOtherItemsType: (value: 'ground' | 'player' | 'stack') => set({ otherItemsType: value }),
  setOtherItemsSlotCount: (value: number) => set({ otherItemsSlotCount: value }),
  getEquipmentItem: (equipSlot: EEquipmentSlot) => get().equipmentItems.find((item: TInventoryItem) => item.slot === equipSlot),
}))


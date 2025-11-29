import { EEquipmentSlot } from "@/constants/enum"
import type { TInventoryItem, TItemData } from "@/types/inventory"
import { create } from "zustand"

export type TContainer = {
  items: TInventoryItem[]
  id: string
  capacity: {
    weight: number
    slots: number
  }
}

type SplitItemOptions = {
  onSuccess?: () => void
  onFail?: (reason: string) => void
}

type InventoryState = {
  isOpenInventory: boolean
  otherItems: TInventoryItem[]
  otherItemsType: 'ground' | 'player' | 'stack' | 'container' | ''
  otherItemsSlotCount: number
  otherItemsId: string
  isOpenAmountDialog: boolean
  amountDialogType: 'give' | 'drop'
  dialogItem: TInventoryItem | null
  inventoryItems: TInventoryItem[]
  backpackItems: TInventoryItem[]
  slotCount: number
  totalWeight: number // Total weight of inventory in grams
  inventoryWeight: number
  equipmentItems: TInventoryItem[]
  selectOtherTab: 'ground' | 'crafting' | 'missions' | ''
  learnedCraftingRecipes: string[]
  selectCharacterTab: 'equipment' | 'skills' | 'stats'
  temporaryDroppedItems: TInventoryItem[]
  setBackpackItems: (backpackItems: TInventoryItem[]) => void
  setTemporaryDroppedItem: (items: TInventoryItem) => void
  removeTemporaryDroppedItem: (item: TItemData) => void
  rollbackTemporaryDroppedItem: (item: TItemData) => void
  setLearnedCraftingRecipes: (recipes: string[]) => void
  setSelectOtherTab: (value: 'ground' | 'crafting' | 'missions') => void
  // Equipment
  setEquipmentItems: (items: TInventoryItem[]) => void
  equipItem: (item: TInventoryItem) => void
  unequipItem: (item: TInventoryItem) => void
  setSlotCount: (value: number) => void
  setTotalWeight: (value: number) => void
  setInventoryItems: (items: TInventoryItem[]) => void
  setOpenInventory: (value: boolean) => void
  setIsOpenAmountDialog: (value: boolean) => void
  setAmountDialogType: (value: 'give' | 'drop') => void
  resetAmountDialog: () => void
  setDialogItem: (item: TInventoryItem) => void
  setOtherItems: (items: TInventoryItem[]) => void
  setOtherItemsType: (value: 'ground' | 'player' | 'stack' | 'container') => void
  setOtherItemsSlotCount: (value: number) => void
  getEquipmentItem: (equipSlot: EEquipmentSlot) => TInventoryItem | undefined
  isHaveOtherItems: () => boolean
  getTotalLimitWeight: () => number
  getTotalWeight: () => number
  setSelectCharacterTab: (value: 'equipment' | 'skills' | 'stats') => void
  setOtherItemsId: (value: string) => void
  // Items
  splitItem: (itemSlot: number, options?: SplitItemOptions) => void
  onCloseInventory: () => void
}

const calculateInventoryWeight = (items: TInventoryItem[]) =>
  items.reduce((acc, item) => acc + item.weight * item.amount, 0)

export const useInventoryStore = create<InventoryState>((set, get) => ({
  isOpenInventory: false,
  isOpenAmountDialog: false,
  amountDialogType: 'drop',
  dialogItem: null,
  inventoryItems: [],
  backpackItems: [],
  slotCount: 0,
  totalWeight: 15000, // 15kg
  inventoryWeight: 0,
  otherItems: [],
  otherItemsType: 'ground',
  otherItemsSlotCount: 0,
  otherItemsId: '',
  equipmentItems: [],
  selectOtherTab: 'crafting',
  learnedCraftingRecipes: [],
  selectCharacterTab: 'equipment',
  temporaryDroppedItems: [],
  setBackpackItems: (backpackItems: TInventoryItem[]) => {
    set(() => {
      return { backpackItems: backpackItems }
    })
  },
  setTemporaryDroppedItem: (item: TInventoryItem) => {
    set((state) => {
      const matchedItem = state.inventoryItems.find(
        (inventoryItem) => inventoryItem.slot === item.slot && inventoryItem.name === item.name
      )

      if (!matchedItem) {
        return {}
      }

      const removeAmount = Math.min(item.amount, matchedItem.amount)

      if (removeAmount <= 0) {
        return {}
      }

      const nextInventoryItems = state.inventoryItems.reduce<TInventoryItem[]>((acc, inventoryItem) => {
        if (inventoryItem.slot !== matchedItem.slot || inventoryItem.name !== matchedItem.name) {
          acc.push(inventoryItem)
          return acc
        }

        const remainingAmount = inventoryItem.amount - removeAmount

        if (remainingAmount > 0) {
          acc.push({ ...inventoryItem, amount: remainingAmount })
        }

        return acc
      }, [])

      const nextInventoryWeight = calculateInventoryWeight(nextInventoryItems)
      const nextTemporaryDroppedItems = [...state.temporaryDroppedItems]
      const tempIndex = nextTemporaryDroppedItems.findIndex(
        (tempItem) => tempItem.slot === item.slot && tempItem.name === item.name
      )

      if (tempIndex !== -1) {
        const tempItem = nextTemporaryDroppedItems[tempIndex]
        nextTemporaryDroppedItems[tempIndex] = {
          ...tempItem,
          amount: tempItem.amount + removeAmount,
        }
      } else {
        nextTemporaryDroppedItems.push({ ...item, amount: removeAmount })
      }

      return {
        inventoryItems: nextInventoryItems,
        inventoryWeight: nextInventoryWeight,
        temporaryDroppedItems: nextTemporaryDroppedItems,
      }
    })
  },
  removeTemporaryDroppedItem: (item: TItemData) => {
    set((state) => {
      const temporaryDroppedItems = [...state.temporaryDroppedItems]
      const tempIndex = temporaryDroppedItems.findIndex((tempItem) => tempItem.slot === item.fromSlot)
      if (tempIndex !== -1) {
        // Found temporary item, decrease it amount
        temporaryDroppedItems[tempIndex].amount -= item.amount
        // If amount is less than 0, remove the item
        if (temporaryDroppedItems[tempIndex].amount <= 0) {
          temporaryDroppedItems.splice(tempIndex, 1)
        }
      }
      return { temporaryDroppedItems }
    })
  },
  rollbackTemporaryDroppedItem: (item: TItemData) => {
    set((state) => {
      const temporaryDroppedItems = [...state.temporaryDroppedItems]
      const tempIndex = temporaryDroppedItems.findIndex(
        (tempItem) => tempItem.slot === item.fromSlot && tempItem.name === item.itemName
      )
      // Not found temporary item, return
      if (tempIndex === -1) {
        return {}
      }

      const tempItem = temporaryDroppedItems[tempIndex]
      const rollbackAmount = item.amount
      // If rollback amount is less than 0, return
      if (rollbackAmount <= 0) {
        return {}
      }

      // Found item in inventory, increase it amount
      const inventoryItems = [...state.inventoryItems]
      const inventoryIndex = inventoryItems.findIndex(
        (inventoryItem) => inventoryItem.slot === tempItem.slot && inventoryItem.name === tempItem.name
      )

      // If not found item in inventory, add it to inventory
      if (inventoryIndex !== -1) {
        inventoryItems[inventoryIndex] = {
          ...inventoryItems[inventoryIndex],
          amount: inventoryItems[inventoryIndex].amount + rollbackAmount,
        }
      } else {
        inventoryItems.push({
          ...tempItem,
          amount: rollbackAmount,
        })
      }

      // If rollback amount is greater than temporary item amount, remove the temporary item
      if (rollbackAmount >= tempItem.amount) {
        temporaryDroppedItems.splice(tempIndex, 1)
      } else {
        temporaryDroppedItems[tempIndex] = {
          ...tempItem,
          amount: tempItem.amount - rollbackAmount,
        }
      }

      return {
        inventoryItems,
        inventoryWeight: calculateInventoryWeight(inventoryItems),
        temporaryDroppedItems,
      }
      return {
        inventoryItems,
        inventoryWeight: calculateInventoryWeight(inventoryItems),
        temporaryDroppedItems,
      }
    })
  },
  setLearnedCraftingRecipes: (recipes: string[]) => set({ learnedCraftingRecipes: recipes }),
  setSelectOtherTab: (value: 'ground' | 'crafting' | 'missions') => set({ selectOtherTab: value }),
  setEquipmentItems: (items: TInventoryItem[]) => set({ equipmentItems: items }),
  equipItem: (item: TInventoryItem) => {
    set((state) => {
      const equipmentItems = [...state.equipmentItems]
      const equipmentIndex = equipmentItems.findIndex((equipmentItem) => equipmentItem.slot === item.slot)
      
      if (equipmentIndex !== -1) {
        // Have item with same type (Just replace it)
        equipmentItems[equipmentIndex] = item
      } else {
        // Don't have item with same type (Add it to equipment)
        equipmentItems.push(item)
      }

      return { equipmentItems }
    })
  },
  unequipItem: (item: TInventoryItem) => {
    set((state) => {
      const equipmentItems = [...state.equipmentItems]
      const equipmentIndex = equipmentItems.findIndex(
        (equipmentItem) => equipmentItem.slot === item.slot && equipmentItem.name === item.name
      )
      if (equipmentIndex !== -1) {
        equipmentItems[equipmentIndex] = {
          ...equipmentItems[equipmentIndex],
          amount: equipmentItems[equipmentIndex].amount - item.amount,
        }
      } else {
        equipmentItems.push({ ...item, amount: item.amount })
      }
      return { equipmentItems }
    })
  },
  setSlotCount: (value: number) => set({ slotCount: value }),
  setTotalWeight: (value: number) => set({ totalWeight: value }),
  setOpenInventory: (value: boolean) => {
    let isHaveOtherItems = get().isHaveOtherItems()
    set({ isOpenInventory: value, selectOtherTab: isHaveOtherItems ? 'ground' : 'crafting' })
  },
  setIsOpenAmountDialog: (value: boolean) => set({ isOpenAmountDialog: value }),
  setAmountDialogType: (value: 'give' | 'drop') => set({ amountDialogType: value }),
  resetAmountDialog: () => set({ isOpenAmountDialog: false, amountDialogType: 'drop' }),
  setDialogItem: (item: TInventoryItem) => set({ dialogItem: item }),
  setInventoryItems: (items: TInventoryItem[]) =>
    set({
      inventoryItems: items,
      inventoryWeight: calculateInventoryWeight(items),
    }),
  setOtherItems: (items: TInventoryItem[]) => set({ otherItems: items }),
  setOtherItemsType: (value: 'ground' | 'player' | 'stack' | 'container') => set({ otherItemsType: value }),
  setOtherItemsSlotCount: (value: number) => set({ otherItemsSlotCount: value }),
  getEquipmentItem: (equipSlot: EEquipmentSlot) => get().equipmentItems.find((item: TInventoryItem) => item?.slot === equipSlot),
  isHaveOtherItems: () => {
    return get().otherItems.length > 0 && get().otherItemsType !== '' && get().otherItemsSlotCount > 0
  },
  getTotalLimitWeight: () => {
    const totalWeight = get().totalWeight
    const bagItem = get().getEquipmentItem(EEquipmentSlot.Bag)
    if (!bagItem) {
      return totalWeight
    }
    return totalWeight + (bagItem.info?.maxWeight ?? 0)
  },
  getTotalWeight: () => get().inventoryWeight,
  setSelectCharacterTab: (value: 'equipment' | 'skills' | 'stats') => set({ selectCharacterTab: value }),
  setOtherItemsId: (value: string) => set({ otherItemsId: value }),
  splitItem: (itemSlot: number, options?: SplitItemOptions) => {
    // TODO: Implement split item by slot
    set((state) => {
      const inventoryItems = [...state.inventoryItems]
      const itemIndex = inventoryItems.findIndex((item) => item.slot === itemSlot)

      if (itemIndex === -1) {
        options?.onFail?.('inventory.itemNotFound')
        return {}
      }

      const item = inventoryItems[itemIndex]

      if (item.amount <= 1) {
        options?.onFail?.('inventory.itemAmountLessThanOne')
        return {}
      }

      // Find first available slot
      // We need to check slots from 1 to slotCount
      // Exclude slots that are already taken
      const takenSlots = new Set(inventoryItems.map((i) => i.slot))
      let freeSlot = -1

      // Assuming slots start from 1. 
      // Let's check all slots up to slotCount
      for (let i = 1; i <= state.slotCount; i++) {
        if (!takenSlots.has(i)) {
          freeSlot = i
          break
        }
      }

      if (freeSlot === -1) {
        // No free slot
        options?.onFail?.('inventory.noFreeSlot')
        return {}
      }

      const splitAmount = Math.floor(item.amount / 2)
      const remainingAmount = item.amount - splitAmount

      // Update original item
      inventoryItems[itemIndex] = {
        ...item,
        amount: remainingAmount,
      }

      // Create new item
      inventoryItems.push({
        ...item,
        amount: splitAmount,
        slot: freeSlot,
      })

      options?.onSuccess?.()

      return {
        inventoryItems,
        inventoryWeight: calculateInventoryWeight(inventoryItems),
      }
    })
  },
  onCloseInventory: () => {
    set({
      otherItems: [],
      otherItemsType: 'ground',
      otherItemsSlotCount: 0,
      otherItemsId: ''
    })
  }
}))

import type { TInventoryItem } from "@/types/inventory"
import { create } from "zustand"

type DevModeState = {
  isEnableDevMode: boolean
  permission: string
  isDevModeOpen: boolean
  isUIPreviewOpen: boolean
  isShowLibrary: boolean
  libraryTab: 'general' | 'library'
  itemLibrary: TInventoryItem[]
  setItemLibrary: (items: TInventoryItem[]) => void
  setLibraryTab: (value: 'general' | 'library') => void
  setEnableDevMode: (value: boolean) => void
  setDevModeOpen: (value: boolean) => void
  toggleDevMode: () => void
  setPermission: (value: string) => void
  setUIPreviewOpen: (value: boolean) => void
  setShowLibrary: (value: boolean) => void
}

export const useDevModeStore = create<DevModeState>((set) => ({
  isEnableDevMode: false,
  permission: 'player',
  isDevModeOpen: false,
  isUIPreviewOpen: false,
  isShowLibrary: false,
  libraryTab: 'general',
  itemLibrary: [],
  setItemLibrary: (items: TInventoryItem[]) => set({ itemLibrary: items }),
  setLibraryTab: (value: 'general' | 'library') => set({ libraryTab: value }),
  setEnableDevMode: (value: boolean) => set({ isEnableDevMode: value }),
  setUIPreviewOpen: (value: boolean) => set({ isUIPreviewOpen: value }),
  setDevModeOpen: (value) => set({ isDevModeOpen: value }),
  toggleDevMode: () =>
    set((state) => ({
      isDevModeOpen: !state.isDevModeOpen,
    })),
  setPermission: (value) => set({ permission: value }),
  setShowLibrary: (value) => set({ isShowLibrary: value }),
}))


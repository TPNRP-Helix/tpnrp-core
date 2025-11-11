import { create } from "zustand"

type GameSettingState = {
  isSettingsOpen: boolean
  language: string
  /* Toast config */
  toastConfig: {
    visibleToasts: number
    isExpand: boolean
  }
  /* Basic needs HUD config */
  basicNeedHUDConfig: {
    health: number    // Will show badge if value smaller than this
    armor: number     // Will show badge if value smaller than this
    hunger: number    // Will show badge if value smaller than this
    thirst: number    // Will show badge if value smaller than this
    stamina: number   // Will show badge if value smaller than this
    
  }
  setLanguage: (value: string) => void
  setToastConfig: (value: { visibleToasts: number, isExpand: boolean }) => void
  setBasicNeedHUDConfig: (value: { health?: number, armor?: number, hunger?: number, thirst?: number, stamina?: number }) => void
  setSettingsOpen: (value: boolean) => void
  toggleSettings: () => void
}

export const useGameSettingStore = create<GameSettingState>((set) => ({
  isSettingsOpen: false,
  toastConfig: {
    visibleToasts: 5,
    isExpand: true,
  },
  basicNeedHUDConfig: {
    health: 100,
    armor: 100,
    hunger: 100,
    thirst: 100,
    stamina: 100,
  },
  language: typeof window !== 'undefined' ? (localStorage.getItem('tpnrp_language') || 'en') : 'en',
  setLanguage: (value: string) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('tpnrp_language', value)
    }
    set({ language: value })
  },
  setToastConfig: (value: { visibleToasts: number, isExpand: boolean }) => set({ toastConfig: value }),
  setBasicNeedHUDConfig: (value: { health?: number, armor?: number, hunger?: number, thirst?: number, stamina?: number }) => set((state) => ({ basicNeedHUDConfig: { ...state.basicNeedHUDConfig, ...value } })),
  setSettingsOpen: (value) => set({ isSettingsOpen: value }),
  toggleSettings: () => set((state) => ({ isSettingsOpen: !state.isSettingsOpen })),
}))


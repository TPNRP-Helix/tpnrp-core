import { create } from "zustand"

type GameSettingState = {
  isSettingsOpen: boolean
  showHealthBadgeWhenSmallerThan: number
  showArmorBadgeWhenSmallerThan: number
  showHungerBadgeWhenSmallerThan: number
  showThirstBadgeWhenSmallerThan: number
  showStaminaBadgeWhenSmallerThan: number
  setShowHealthBadgeWhenSmallerThan: (value: number) => void
  setShowArmorBadgeWhenSmallerThan: (value: number) => void
  setShowHungerBadgeWhenSmallerThan: (value: number) => void
  setShowThirstBadgeWhenSmallerThan: (value: number) => void
  setShowStaminaBadgeWhenSmallerThan: (value: number) => void
  setSettingsOpen: (value: boolean) => void
  toggleSettings: () => void
}

export const useGameSettingStore = create<GameSettingState>((set) => ({
  isSettingsOpen: false,
  showHealthBadgeWhenSmallerThan: 100,
  showArmorBadgeWhenSmallerThan: 100,
  showHungerBadgeWhenSmallerThan: 100,
  showThirstBadgeWhenSmallerThan: 100,
  showStaminaBadgeWhenSmallerThan: 100,
  setShowHealthBadgeWhenSmallerThan: (value) => set({ showHealthBadgeWhenSmallerThan: value }),
  setShowArmorBadgeWhenSmallerThan: (value) => set({ showArmorBadgeWhenSmallerThan: value }),
  setShowHungerBadgeWhenSmallerThan: (value) => set({ showHungerBadgeWhenSmallerThan: value }),
  setShowThirstBadgeWhenSmallerThan: (value) => set({ showThirstBadgeWhenSmallerThan: value }),
  setShowStaminaBadgeWhenSmallerThan: (value) => set({ showStaminaBadgeWhenSmallerThan: value }),
  setSettingsOpen: (value) => set({ isSettingsOpen: value }),
  toggleSettings: () => set((state) => ({ isSettingsOpen: !state.isSettingsOpen })),
}))


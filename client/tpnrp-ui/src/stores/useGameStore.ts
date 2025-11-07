import { create } from "zustand"

type GameState = {
  isHudVisible: boolean
  health: number
  armor: number
  hunger: number
  thirst: number
  stamina: number
  setHudVisible: (value: boolean) => void
  toggleHud: () => void
  setHealth: (value: number) => void
  setArmor: (value: number) => void
  setHunger: (value: number) => void
  setThirst: (value: number) => void
  setStamina: (value: number) => void
}

export const useGameStore = create<GameState>((set) => ({
  isHudVisible: false,
  health: 90,
  armor: 90,
  hunger: 90,
  thirst: 90,
  stamina: 90,
  
  setHudVisible: (value) => set({ isHudVisible: value }),
  toggleHud: () =>
    set((state) => ({
      isHudVisible: !state.isHudVisible,
    })),
  setHealth: (value: number) => set({ health: value }),
  setArmor: (value: number) => set({ armor: value }),
  setHunger: (value: number) => set({ hunger: value }),
  setThirst: (value: number) => set({ thirst: value }),
  setStamina: (value: number) => set({ stamina: value }),
}))


import { create } from "zustand"

type GameState = {
  isHudVisible: boolean
  basicNeeds: {
    health: number
    armor: number
    hunger: number
    thirst: number
    stamina: number
  }
  setHudVisible: (value: boolean) => void
  toggleHud: () => void
  setBasicNeeds: (value: { health?: number, armor?: number, hunger?: number, thirst?: number, stamina?: number }) => void
}

export const useGameStore = create<GameState>((set) => ({
  isHudVisible: false,
  basicNeeds: {
    health: 18,
    armor: 90,
    hunger: 90,
    thirst: 90,
    stamina: 90,
  },
  setBasicNeeds: (value: { health?: number, armor?: number, hunger?: number, thirst?: number, stamina?: number }) => set((state) => ({ basicNeeds: { ...state.basicNeeds, ...value } })),
  setHudVisible: (value) => set({ isHudVisible: value }),
  toggleHud: () =>
    set((state) => ({
      isHudVisible: !state.isHudVisible,
    })),
}))


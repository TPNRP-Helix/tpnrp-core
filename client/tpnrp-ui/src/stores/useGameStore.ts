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
    health: 100,
    armor: 0,
    hunger: 100,
    thirst: 100,
    stamina: 100,
  },
  setBasicNeeds: (value: { health?: number, armor?: number, hunger?: number, thirst?: number, stamina?: number }) => set((state) => ({ basicNeeds: { ...state.basicNeeds, ...value } })),
  setHudVisible: (value) => set({ isHudVisible: value }),
  toggleHud: () =>
    set((state) => ({
      isHudVisible: !state.isHudVisible,
    })),
}))


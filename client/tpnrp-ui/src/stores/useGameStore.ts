import type { TPlayer } from "@/types/game"
import type { TCraftingRecipe } from "@/types/inventory"
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
  isShowLoading: boolean
  loadingText: string
  isInGame: boolean
  craftingRecipes: TCraftingRecipe[]
  playersNearBy: TPlayer[]
  setPlayersNearBy: (players: TPlayer[]) => void
  setCraftingRecipes: (recipes: TCraftingRecipe[]) => void
  setIsInGame: (value: boolean) => void
  setShowLoading: (value: boolean) => void
  setLoadingText: (value: string) => void
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
  isShowLoading: true,
  loadingText: 'Loading...',
  isInGame: false,
  craftingRecipes: [],
  playersNearBy: [],
  setPlayersNearBy: (players: TPlayer[]) => set({ playersNearBy: players }),
  setCraftingRecipes: (recipes: TCraftingRecipe[]) => set({ craftingRecipes: recipes }),
  setIsInGame: (value: boolean) => set({ isInGame: value }),
  setShowLoading: (value: boolean) => set({ isShowLoading: value }),
  setLoadingText: (value: string) => set({ loadingText: value }),
  setBasicNeeds: (value: { health?: number, armor?: number, hunger?: number, thirst?: number, stamina?: number }) => set((state) => ({ basicNeeds: { ...state.basicNeeds, ...value } })),
  setHudVisible: (value) => set({ isHudVisible: value }),
  toggleHud: () =>
    set((state) => ({
      isHudVisible: !state.isHudVisible,
    })),
}))


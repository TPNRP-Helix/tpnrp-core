import { create } from "zustand"

type CharacterInfoState = {
  citizenId: string
  level: number
  setCitizenId: (value: string) => void
  setLevel: (value: number) => void
}

export const useCharacterInfoStore = create<CharacterInfoState>((set) => ({
  citizenId: '',
  level: 1,
  setCitizenId: (value: string) => set({ citizenId: value }),
  setLevel: (value: number) => set({ level: value }),
}))


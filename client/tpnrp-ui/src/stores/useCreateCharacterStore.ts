import { create } from "zustand"

type CreateCharacterState = {
    isShowSelectCharacter: boolean
    isShowCreateCharacter: boolean
    setShowSelectCharacter: (value: boolean) => void
    setShowCreateCharacter: (value: boolean) => void
    toggleSelectCharacter: () => void
    toggleCreateCharacter: () => void
}

export const useCreateCharacterStore = create<CreateCharacterState>((set) => ({
    isShowSelectCharacter: false,
    isShowCreateCharacter: false,
    setShowSelectCharacter: (value) => set({ isShowSelectCharacter: value }),
    setShowCreateCharacter: (value) => set({ isShowCreateCharacter: value }),
    toggleSelectCharacter: () => set((state) => ({ isShowSelectCharacter: !state.isShowSelectCharacter })),
    toggleCreateCharacter: () => set((state) => ({ isShowCreateCharacter: !state.isShowCreateCharacter })),
}))

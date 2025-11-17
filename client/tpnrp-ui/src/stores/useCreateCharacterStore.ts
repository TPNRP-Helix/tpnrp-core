import type { TCharacter } from "@/types/game"
import { create } from "zustand"

type CreateCharacterState = {
    isShowSelectCharacter: boolean
    isShowCreateCharacter: boolean
    maxCharacters: number
    isOpenCalendar: boolean
    /* Form */
    firstName: string
    lastName: string
    dateOfBirth: Date | undefined
    gender: 'male' | 'female'
    playerCharacters: TCharacter[]
    setPlayerCharacters: (value: TCharacter[]) => void
    setFirstName: (value: string) => void
    setLastName: (value: string) => void
    setDateOfBirth: (value: Date | undefined) => void
    setGender: (value: 'male' | 'female') => void
    setIsOpenCalendar: (value: boolean) => void
    setMaxCharacters: (value: number) => void
    setShowSelectCharacter: (value: boolean) => void
    setShowCreateCharacter: (value: boolean) => void
    toggleSelectCharacter: () => void
    toggleCreateCharacter: () => void
}

export const useCreateCharacterStore = create<CreateCharacterState>((set) => ({
    isShowSelectCharacter: false,
    isShowCreateCharacter: false,
    maxCharacters: 0,
    isOpenCalendar: false,
    firstName: '',
    lastName: '',
    dateOfBirth: undefined,
    gender: 'male',
    playerCharacters: [],
    setPlayerCharacters: (value: TCharacter[]) => set({ playerCharacters: value }),
    setFirstName: (value: string) => set({ firstName: value }),
    setLastName: (value: string) => set({ lastName: value }),
    setDateOfBirth: (value: Date | undefined) => set({ dateOfBirth: value }),
    setGender: (value: 'male' | 'female') => set({ gender: value }),
    setIsOpenCalendar: (value: boolean) => set({ isOpenCalendar: value }),
    setMaxCharacters: (value: number) => set({ maxCharacters: value }),
    setShowSelectCharacter: (value) => set({ isShowSelectCharacter: value }),
    setShowCreateCharacter: (value) => set({ isShowCreateCharacter: value }),
    toggleSelectCharacter: () => set((state) => ({ isShowSelectCharacter: !state.isShowSelectCharacter })),
    toggleCreateCharacter: () => set((state) => ({ isShowCreateCharacter: !state.isShowCreateCharacter })),
}))

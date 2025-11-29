import { useWebUIMessage } from "@/hooks/use-hevent"
import { useGameStore } from "@/stores/useGameStore"
import { useCreateCharacterStore } from "@/stores/useCreateCharacterStore"
import type { TCharacter } from "@/types/game"

export const CreateCharacterEventListener = () => {
    const {
        setShowSelectCharacter,
        setMaxCharacters,
        setPlayerCharacters,
    } = useCreateCharacterStore()
    
    const { setIsInGame, setShowLoading } = useGameStore()

    useWebUIMessage<[number, unknown[]]>('setPlayerCharacters', ([maxCharacters, characters]) => {
        // Set max characters
        setMaxCharacters(maxCharacters)
        // Format characters
        const formattedCharacters: TCharacter[] = Object.entries(characters).map(([_, value]: [string, any]) => {
            return {
                name: value.name,
                citizenId: value.citizenId,
                level: parseInt(value.level) ?? 1,
                money: parseInt(value.money) ?? 0,
                gender: value.gender,
            }
        })
        setPlayerCharacters(formattedCharacters)
        // Show Select Character Sheet
        setShowSelectCharacter(true)
        setShowLoading(false)
        setIsInGame(true)
    })

    return null
}
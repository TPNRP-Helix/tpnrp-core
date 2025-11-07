import { useWebUIMessage } from "@/hooks/use-hevent"

export const CreateCharacter = () => {

    useWebUIMessage('setPlayerCharacters', (characters) => {
        console.log(characters)
    })
    
    return (
        <div>
            <h1>Create Character</h1>
        </div>
    )
}

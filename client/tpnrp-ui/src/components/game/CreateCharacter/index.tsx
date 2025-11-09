import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useCreateCharacterStore } from "@/stores/useCreateCharacterStore"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import { useState } from "react"
import {
    Item,
    ItemActions,
    ItemContent,
    ItemDescription,
    ItemTitle,
} from "@/components/ui/item"
import { Badge } from "@/components/ui/badge"
import { Mars, Venus } from "lucide-react"

type TCharacter = {
    name: string
    citizenId: string
    level: number
    money: number
    gender: 'male' | 'female'
}

export const CreateCharacter = () => {
    const { appendConsoleMessage } = useDevModeStore()
    const { isShowCreateCharacter, isShowSelectCharacter, setShowCreateCharacter, setShowSelectCharacter } = useCreateCharacterStore()
    const [maxCharacters, setMaxCharacters] = useState<number>(0)
    const [playerCharacters, setPlayerCharacters] = useState<TCharacter[]>([])

    useWebUIMessage<[{ maxCharacters: number, characters: unknown[] }]>('setPlayerCharacters', ([{ maxCharacters, characters }]) => {
        // TPN Log
        appendConsoleMessage({ message: `Max char: ${maxCharacters} - characters ${JSON.stringify(characters)}`, index: 0 })

        // Set max characters
        setMaxCharacters(maxCharacters)
        // Format characters
        const formattedCharacters: TCharacter[] = Object.entries(characters).map(([_, value]: [string, any]) => {
            return {
                name: value.name,
                citizenId: value.citizenId,
                level: parseInt(value.level) ?? 1,
                money: parseInt(value.money) ?? 0,
                gender: value.gender === 1 ? 'male' : 'female',
            }
        })
        setPlayerCharacters(formattedCharacters)
        // Show Select Character Sheet
        setShowSelectCharacter(true)
    })
    
    return (
        <>
            <Sheet open={isShowSelectCharacter} onOpenChange={setShowSelectCharacter}>
                <SheetContent
                    onInteractOutside={(e) => e.preventDefault()}
                    isShowOverlay={false}
                    side="left"
                    isShowCloseButton={false}
                >
                    <SheetHeader>
                        <SheetTitle>Select Character</SheetTitle>
                    </SheetHeader>
                    <div className="grid gap-4 p-4">
                        {Array.from({ length: maxCharacters }).map((_, index) => {
                            const character = playerCharacters[index] ?? null

                            return (
                                <Item variant='muted' key={`character-${index}`}>
                                    <ItemContent>
                                        <ItemTitle>
                                            {character ? (
                                                <>
                                                    {character.name}
                                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums">Lv.{character.level}</Badge>
                                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums bg-blue-500">
                                                        {character.gender === 'male' ? <Mars className="size-4" /> : <Venus className="size-4" />}
                                                    </Badge>
                                                    
                                                </>
                                            ) : (
                                                <>{`Empty slot ${index + 1}`}</>
                                            )}
                                        </ItemTitle>
                                        <ItemDescription>
                                            {character ? (
                                                <ul>
                                                    <li>Citizen ID: {character.citizenId}</li>
                                                    <li>Money: ${character.money}</li>
                                                </ul>
                                            ) : <>Create new character</>}
                                        </ItemDescription>
                                    </ItemContent>
                                    <ItemActions className="opacity-0 group-hover/item:opacity-100 transition-opacity">
                                        {character ? (
                                            <Button variant="default" size="sm">
                                                Join
                                            </Button>
                                        ) : (
                                            <Button variant="default" size="sm">
                                                Create
                                            </Button>
                                        )}
                                    </ItemActions>
                                </Item>
                            )
                        })}
                    </div>
                </SheetContent>
            </Sheet>
            {/* Create Character Dialog */}
            <Dialog open={isShowCreateCharacter} onOpenChange={setShowCreateCharacter}>
                <form>
                    <DialogContent className="sm:max-w-[425px] ">
                        <DialogHeader>
                            <DialogTitle>Edit profile</DialogTitle>
                            <DialogDescription>
                                Make changes to your profile here. Click save when you&apos;re
                                done.
                            </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 p-4">
                            <div className="grid gap-3">
                                <Label htmlFor="name-1">Name</Label>
                                <Input id="name-1" name="name" defaultValue="Pedro Duarte" />
                            </div>
                            <div className="grid gap-3">
                                <Label htmlFor="username-1">Username</Label>
                                <Input id="username-1" name="username" defaultValue="@peduarte" />
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="secondary" type="reset">Reset</Button>
                            <Button type="submit">Create</Button>
                        </DialogFooter>
                    </DialogContent>
                </form>
            </Dialog>
        </>
    )
}

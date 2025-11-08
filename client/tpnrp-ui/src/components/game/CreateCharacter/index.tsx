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

export const CreateCharacter = () => {
    const { appendConsoleMessage } = useDevModeStore()
    const { isShowCreateCharacter, isShowSelectCharacter, setShowCreateCharacter, setShowSelectCharacter } = useCreateCharacterStore()
    const [testCharacters, setTestCharacters] = useState<string>('')

    useWebUIMessage('setPlayerCharacters', (characters) => {
        console.log(characters)
        appendConsoleMessage({ message: JSON.stringify(characters), index: 0 })
        setTestCharacters(JSON.stringify(characters))
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
                        <Item variant='muted'>
                            <ItemContent>
                                <ItemTitle>
                                    Character name
                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums">Lv.1</Badge>
                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums bg-blue-500">
                                        <Mars className="size-4" />
                                    </Badge>
                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums bg-pink-500">
                                        <Venus className="size-4" />
                                    </Badge>
                                </ItemTitle>
                                <ItemDescription>
                                    <ul>
                                        <li>Citizen ID: ABC12345</li>
                                        <li>Money: $1000</li>
                                    </ul>
                                </ItemDescription>
                            </ItemContent>
                            <ItemActions className="opacity-0 group-hover/item:opacity-100 transition-opacity">
                                <Button variant="default" size="sm">
                                    Join
                                </Button>
                            </ItemActions>
                        </Item>
                        <pre>{testCharacters}</pre>
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

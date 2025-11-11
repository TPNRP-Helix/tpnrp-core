import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useEffect, useState } from "react"
import helixBgImage from "@/assets/devmode/helix-bg.png"
import { Console } from "./Console"
import { Kbd } from "@/components/ui/kbd"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { useGameStore } from "@/stores/useGameStore"
import { useGameSettingStore } from "@/stores/useGameSetting"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useCreateCharacterStore } from "@/stores/useCreateCharacterStore"
const IS_SHOW_BG = false

export const DevMode = () => {
    const [enableDevMode, setEnableDevMode] = useState(true)
    const { isDevModeOpen, setDevModeOpen, isConsoleOpen, setConsoleOpen, setPermission, permission } = useDevModeStore()
    const { toggleHud } = useGameStore()
    const { toggleSettings } = useGameSettingStore()
    const { toggleSelectCharacter, toggleCreateCharacter, setMaxCharacters } = useCreateCharacterStore()

    useWebUIMessage<[boolean]>('setConsoleOpen', ([isOpenConsole]) => {
        setConsoleOpen(isOpenConsole)
    })
    useWebUIMessage<[boolean]>('setDevModeOpen', ([isOpenDevMode]) => {
        setDevModeOpen(isOpenDevMode)
    })

    useWebUIMessage<[string]>('setPermission', ([permission]) => {
        setPermission(permission)
    })

    useEffect(() => {
        const isInBrowser = window.location.href.includes("http://localhost:")
        if (isInBrowser) {
            setEnableDevMode(true)
            setPermission('admin')
        }
    }, [])
    
    // Don't render the dev mode tools if not in browser
    if (!enableDevMode || permission !== 'admin') return null

    return (
        <>
        {IS_SHOW_BG && (
            <div className="fixed top-0 left-0 w-full h-full -z-10">
                <img src={helixBgImage} alt="DevMode" className="w-full h-full object-cover" />
            </div>
        )}
        <Sheet open={isDevModeOpen} onOpenChange={(open) => {
            setDevModeOpen(open)
            if (!open) {
                window.hEvent("doOutFocus")
            }
        }}>
            <SheetTrigger asChild>
                <Button className="relative top-1 left-1">
                    <Kbd>F7</Kbd>
                    Dev Mode Tools
                </Button>
            </SheetTrigger>
            <SheetContent side="left">
                <SheetHeader>
                    <SheetTitle>Dev Mode Tools</SheetTitle>
                </SheetHeader>
                <div className="grid gap-4 p-4">
                    <SheetDescription>
                        DevMode Tools support for testing inventory features
                    </SheetDescription>
                    <Button onClick={() => toggleHud()}>Toggle Basic needs HUD</Button>
                    <Button onClick={() => toggleSettings()}>Toggle Settings</Button>
                    <Tabs defaultValue="inventory" className="w-full">
                        <TabsList className="grid w-full grid-cols-2">
                            <TabsTrigger value="inventory">Inventory</TabsTrigger>
                            <TabsTrigger value="menu">Menu</TabsTrigger>
                        </TabsList>
                        <TabsContent value="inventory">
                            inventory
                        </TabsContent>
                        <TabsContent value="menu" className="grid gap-2">
                            <Button onClick={() => {
                                setDevModeOpen(false)
                                toggleSelectCharacter()
                                setMaxCharacters(5)
                            }}>Select Character</Button>
                            <Button onClick={() => toggleCreateCharacter()}>Create Character</Button>
                        </TabsContent>
                    </Tabs>
                </div>
            </SheetContent>
        </Sheet>
        <Sheet open={isConsoleOpen} onOpenChange={(open) => {
            setConsoleOpen(open)
            if (!open) {
                window.hEvent("doOutFocus")
            }
        }}>
            <SheetTrigger asChild>
                <Button className="relative top-1 left-1 ml-2 bg-primary! text-primary-foreground!">
                    <Kbd>F8</Kbd>
                    Console
                </Button>
            </SheetTrigger>
            <SheetContent className="w-[800px] sm:max-w-[800px]">
                <SheetHeader>
                    <SheetTitle>Console</SheetTitle>
                </SheetHeader>
                <div className="grid gap-4 p-4">
                    <Console />
                </div>
            </SheetContent>
        </Sheet>
    </>
    )
}
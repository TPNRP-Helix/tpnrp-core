import { Dialog, DialogContent } from "@/components/ui/dialog"
import { useDevModeStore } from "@/stores/useDevModeStore"
import {
    Menubar,
    MenubarSeparator,
    MenubarItem,
    MenubarContent,
    MenubarMenu,
    MenubarTrigger,
    MenubarRadioGroup,
    MenubarRadioItem
} from "@/components/ui/menubar"
import { useCreateCharacterStore } from "@/stores/useCreateCharacterStore"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { useCallback, useState } from "react"
import { FAKE_INVENTORY_ITEMS } from "../constants"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { toast } from "sonner"
import { useGameStore } from "@/stores/useGameStore"
import { useGameSettingStore } from "@/stores/useGameSettingStore"
import { Input } from "@/components/ui/input"
import { InventoryItem } from "@/components/game/Inventory/Item"

export const Library = () => {
    const {
        isDevModeOpen, setDevModeOpen,
        libraryTab, setLibraryTab,
        isEnableDevMode, permission,
        itemLibrary,
        setUIPreviewOpen
    } = useDevModeStore()
    const { toggleSelectCharacter, setMaxCharacters, setPlayerCharacters, toggleCreateCharacter } = useCreateCharacterStore()
    const {
        otherItems, setOpenInventory,
        setOtherItemsType, setOtherItems, setOtherItemsSlotCount,
        setSlotCount
     } = useInventoryStore()
    const { toggleHud } = useGameStore()
    const { toggleSettings } = useGameSettingStore()

    const [animationName, setAnimationName] = useState('')

    const onClickSetGroundItems = useCallback(() => {
        setOtherItemsType('ground')
        setOtherItems([...otherItems, ...FAKE_INVENTORY_ITEMS])
        setOtherItemsSlotCount(42)
    }, [otherItems])


    const playAnimation = useCallback(() => {
        window.hEvent("playAnimation", { animationName })
    }, [animationName])

    return (
        <Dialog open={isDevModeOpen} onOpenChange={(open) => {
            setDevModeOpen(open)
            if (!open) {
                window.hEvent("doOutFocus")
            }
        }}>
            <DialogContent
                className="w-[90%] h-[80vh] max-h-[80vh] select-none"
                contentClassName=""
                isHaveBackdropFilter
                title="DevMode Tools"
                onContextMenu={(e) => e.preventDefault()}
                aria-describedby={undefined}
            >
                <div>
                    <Menubar className="rounded-none">
                        <MenubarMenu>
                            <MenubarTrigger>Screen</MenubarTrigger>
                            <MenubarContent>
                                <MenubarRadioGroup value={libraryTab} onValueChange={(value) => setLibraryTab(value as 'general' | 'library')}>
                                    <MenubarRadioItem value="general">General</MenubarRadioItem>
                                    <MenubarRadioItem value="library">Item Library</MenubarRadioItem>
                                </MenubarRadioGroup>
                            </MenubarContent>
                        </MenubarMenu>
                        <MenubarMenu>
                            <MenubarTrigger>Inventory</MenubarTrigger>
                            <MenubarContent>
                                <MenubarItem
                                    onClick={() => {
                                        setOpenInventory(true)
                                        setDevModeOpen(false)
                                    }}
                                >Open</MenubarItem>
                                <MenubarSeparator />
                                <MenubarItem
                                    onClick={() => {
                                        onClickSetGroundItems()
                                        setOpenInventory(true)
                                        setDevModeOpen(false)
                                    }}
                                >Add other items</MenubarItem>
                                <MenubarItem
                                    onClick={() => {
                                        setSlotCount(42)
                                        setOpenInventory(true)
                                        setDevModeOpen(false)
                                    }}
                                >Open with backpack</MenubarItem>
                            </MenubarContent>
                        </MenubarMenu>
                        <MenubarMenu>
                            <MenubarTrigger>View</MenubarTrigger>
                            <MenubarContent>
                                <MenubarItem onClick={() => {
                                    setDevModeOpen(false)
                                    toggleSelectCharacter()
                                    setMaxCharacters(5)
                                    setPlayerCharacters([{
                                        name: 'Test Character',
                                        citizenId: 'TPN123456',
                                        level: 1,
                                        money: 1000,
                                        gender: 'male',
                                    }])
                                }} inset>Select character</MenubarItem>
                                <MenubarSeparator />
                                <MenubarItem onClick={() => {
                                    setDevModeOpen(false)
                                    toggleCreateCharacter()
                                }} inset>Create character</MenubarItem>
                            </MenubarContent>
                        </MenubarMenu>
                    </Menubar>
                    <div className="p-4">
                        <div className={cn("grid grid-cols-[120px_1fr] w-full h-full", {
                            'hidden': libraryTab !== 'general'
                        })}>
                            <div className="h-full overflow-hidden p-2">
                                General
                                <div>
                                    {isEnableDevMode ? 'DevMode is enabled' : 'DevMode is disabled'}
                                </div>
                                <div>
                                    Permission: {permission}
                                </div>
                            </div>
                            <div className="h-full overflow-hidden">
                                <div className="grid grid-cols-3 gap-2">
                                    <div className="col-span-2">
                                        <Input type="text" placeholder="Animation name" value={animationName} onChange={(e) => setAnimationName(e.target.value)} />
                                    </div>
                                    <div className="col-span-1">
                                        <Button onClick={() => playAnimation()}>Play</Button>
                                    </div>
                                </div>
                                <div className="flex flex-row gap-2">
                                    <Button onClick={() => toast.success('Test toast', {
                                            description: 'Test toast description',
                                            duration: 3000
                                        })}>Test toast</Button>
                                    <Button onClick={() => toggleHud()}>Toggle Basic needs HUD</Button>
                                    <Button onClick={() => {
                                        toggleSettings()
                                        setDevModeOpen(false)
                                    }}>Toggle Settings</Button>
                                </div>
                            </div>
                        </div>
                        <div className={cn("grid grid-cols-[120px_1fr] w-full h-full", {
                            'hidden': libraryTab !== 'library'
                        })}>
                            <div className="h-full overflow-hidden p-2">
                                Library
                            </div>
                            <div className="h-full overflow-hidden">
                                {itemLibrary.map((item, index) => (
                                    <InventoryItem
                                        key={`${item.name}-${index}`}
                                        item={item}
                                        isDragDropDisabled={true}
                                        group="dev-library"
                                    />
                                ))}
                            </div>
                        </div>
                    </div>
                </div>
                
            </DialogContent>
        </Dialog>
    )
}
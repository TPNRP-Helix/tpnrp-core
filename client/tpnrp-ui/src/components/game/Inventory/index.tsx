import { Dialog, DialogContent } from "@/components/ui/dialog"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { useI18n } from "@/i18n"
import { InventoryItem } from "./Item"
import { ScrollArea } from "@/components/ui/scroll-area"
import { SheetTitle } from "@/components/ui/sheet"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useEffect } from "react"
import { useWebUIMessage } from "@/hooks/use-hevent"

export const Inventory = () => {
    const { isOpenInventory, setOpenInventory } = useInventoryStore()
    const { t } = useI18n()

    useWebUIMessage<[]>('openInventory', () => setOpenInventory(true))
    useWebUIMessage<[]>('closeInventory', () => setOpenInventory(false))
    
    useEffect(() => {
        // Only disable when menu is open
        if (!open) return
    
        const prevent = (e: MouseEvent) => e.preventDefault()
    
        document.addEventListener("contextmenu", prevent)
    
        return () => {
          document.removeEventListener("contextmenu", prevent)
        }
    }, [open])

    return (
        <Dialog open={isOpenInventory} onOpenChange={(open) => {
            setOpenInventory(open)
            if (!open) {
                window.hEvent("onCloseInventory")
            }
        }}>
            <DialogContent
                className="w-11/12 sm:max-w-11/12 h-4/5! sm:max-h-4/5 select-none"
                isHaveBackdropFilter
                title={t("inventory.title")}
                onContextMenu={(e) => e.preventDefault()}
            >
                <div className="grid grid-cols-8 gap-6 p-4 h-4/5! sm:max-h-4/5">
                    <div className="col-span-2">
                        Character info
                    </div>
                    <div className="col-span-3">
                        <div className="flex flex-col">
                            <div className="relative">
                                <SheetTitle>{t("inventory.title")}</SheetTitle>
                                <div className="absolute top-2 right-0 text-right text-xs text-muted-foreground">Weight: 100/100</div>
                                <Separator className="relative mb-4 -top-[1px]" />
                                <div className="grid grid-cols-6 gap-4">
                                    <InventoryItem />
                                    <InventoryItem />
                                    <InventoryItem />
                                    <InventoryItem />
                                    <InventoryItem />
                                    <InventoryItem />
                                </div>
                            </div>
                            <div className="relative mt-4">
                                <SheetTitle>{t("inventory.backpack.title")}</SheetTitle>
                                <div className="absolute top-2 right-0 text-right text-xs text-muted-foreground">Slot: 32</div>
                                <Separator className="relative mb-4 -top-[1px]" />
                                <ScrollArea className="h-122">
                                    <div className="grid grid-cols-6 gap-4 grid-wrap">
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                    </div>
                                </ScrollArea>
                            </div>
                        </div>
                    </div>
                    <div className="col-span-3">
                        <Tabs defaultValue="ground" className="w-full">
                            <TabsList className="">
                                <TabsTrigger value="ground">Ground</TabsTrigger>
                                <TabsTrigger value="crafting">Crafting</TabsTrigger>
                                <TabsTrigger value="missions">Missions</TabsTrigger>
                            </TabsList>
                            {/* <Separator className="relative mb-4 -top-[1px]" /> */}
                            <TabsContent value="ground">
                                <ScrollArea className="h-167">
                                    <div className="grid grid-cols-6 gap-4 grid-wrap">
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                        <InventoryItem />
                                    </div>
                                </ScrollArea>
                            </TabsContent>
                            <TabsContent value="crafting">
                                
                            </TabsContent>
                            <TabsContent value="missions">
                                
                            </TabsContent>
                        </Tabs>
                        
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
}
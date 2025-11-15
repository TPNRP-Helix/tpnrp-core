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
import { AmountDialog } from "./AmountDialog"
import { Empty, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty"
import { PackageOpen } from "lucide-react"

export const Inventory = () => {
    const {
        isOpenInventory,
        setOpenInventory,
        inventoryItems,
        slotCount,
        isHaveOtherItems,
        otherItemsType,
        otherItemsSlotCount
    } = useInventoryStore()
    const { t } = useI18n()
    
    // Filter items with slot indices from 1 to 6
    const hotbarItems = inventoryItems.filter(item => item.slot >= 1 && item.slot <= 6).sort((a, b) => a.slot - b.slot)
    const backpackItems = inventoryItems.filter(item => item.slot >= 7).sort((a, b) => a.slot - b.slot)

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
        <>
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
                                        {Array.from({ length: 6 }, (_, i) => {
                                            const slot = i + 1
                                            const item = hotbarItems.find(item => item.slot === slot)
                                                
                                            return <InventoryItem key={`${item?.name}-${slot}`} item={item} slot={slot} />
                                        })}
                                    </div>
                                </div>
                                <div className="relative mt-4">
                                    <SheetTitle>{t("inventory.backpack.title")}</SheetTitle>
                                    <div className="absolute top-2 right-0 text-right text-xs text-muted-foreground">{t('inventory.backpack.slotCount')}: {slotCount}</div>
                                    <Separator className="relative mb-4 -top-[1px]" />
                                    <ScrollArea className="h-122">
                                        {slotCount > 0 ? (
                                            <div className="grid grid-cols-6 gap-4 grid-wrap">
                                                {Array.from({ length: slotCount }, (_, i) => {
                                                    const slot = i + 7
                                                    const item = backpackItems.find(item => item.slot === slot)
                                                    return <InventoryItem key={slot} item={item} slot={slot} />
                                                })}
                                            </div>
                                        ) : (
                                            <>
                                            <Empty className="h-full w-full bg-accent rounded">
                                                <EmptyHeader>
                                                    <EmptyMedia variant="icon">
                                                        <PackageOpen className="w-6 h-6 text-muted-foreground" />
                                                    </EmptyMedia>
                                                    <EmptyTitle>{t('inventory.backpack.empty')}</EmptyTitle>
                                                    <EmptyDescription>{t('inventory.backpack.emptyDescription')}</EmptyDescription>
                                                </EmptyHeader>
                                            </Empty>
                                            </>
                                        )}
                                    </ScrollArea>
                                </div>
                            </div>
                        </div>
                        <div className="col-span-3">
                            <Tabs defaultValue="crafting" className="w-full">
                                <TabsList className="">
                                    {isHaveOtherItems && (
                                        <TabsTrigger value={otherItemsType}>{t(`inventory.other.${otherItemsType}`)}</TabsTrigger>
                                    )}
                                    <TabsTrigger value="crafting">Crafting</TabsTrigger>
                                    <TabsTrigger value="missions">Missions</TabsTrigger>
                                </TabsList>
                                {/* <Separator className="relative mb-4 -top-[1px]" /> */}
                                <TabsContent value="ground">
                                    <ScrollArea className="h-167">
                                        <div className="grid grid-cols-6 gap-4 grid-wrap">
                                            {Array.from({ length: otherItemsSlotCount }, (_, i) => {
                                                const slot = i + 7
                                                const item = backpackItems.find(item => item.slot === slot)
                                                return <InventoryItem key={slot} item={item} slot={slot} />
                                            })}
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
            <AmountDialog />
        </>
    )
}
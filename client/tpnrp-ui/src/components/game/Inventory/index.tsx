import { Dialog, DialogContent } from "@/components/ui/dialog"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { useI18n } from "@/i18n"
import { InventoryItem } from "./Item"
import { ScrollArea } from "@/components/ui/scroll-area"
import { SheetTitle } from "@/components/ui/sheet"
import { Separator } from "@/components/ui/separator"
import { useCallback, useEffect, useState } from "react"
import { DndContext, DragOverlay, PointerSensor, useSensor, useSensors } from "@dnd-kit/core"
import type { DragEndEvent, DragStartEvent } from "@dnd-kit/core"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { AmountDialog } from "./AmountDialog"
import { Empty, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty"
import { PackageOpen } from "lucide-react"
import { OtherInventory } from "./OtherInventory"
import { formatWeight } from "@/lib/inventory"
import { CharacterInfo } from "./CharacterInfo"
import type { TInventoryGroup, TInventoryItem, TResponseCreateDropItem } from "@/types/inventory"
import { toast } from "sonner"
import { FALLBACK_DEFAULT_IMAGE_PATH } from "@/constants"
import { Image } from "@/components/ui/image"

const DEFAULT_SLOT_COUNT = 5

type TOpenInventoryResult = {
    status: boolean
    message: string
    inventory: TInventoryItem[]
    equipment: TInventoryItem[]
    container?: {
        items: TInventoryItem[]
        id: string
        capacity: {
            weight: number
            slots: number
        }
    } | null
    capacity: {
        weight: number
        slots: number
    }
}

export const Inventory = () => {
    const {
        isOpenInventory,
        setOpenInventory,
        inventoryItems, setInventoryItems,
        setEquipmentItems,
        slotCount, setSlotCount,
        getTotalWeight, setTotalWeight,
        setOtherItems,
        setOtherItemsId,
        setOtherItemsType,
        setOtherItemsSlotCount,
        getTotalLimitWeight,
        moveInventoryItem,
        removeTemporaryDroppedItem,
        rollbackTemporaryDroppedItem
    } = useInventoryStore()
    const { t } = useI18n()
    const [activeDragItem, setActiveDragItem] = useState<{
        item: TInventoryItem | null
        slot: number | null
        group: TInventoryGroup | null
    } | null>(null)
    const sensors = useSensors(
        useSensor(PointerSensor, {
            activationConstraint: {
                distance: 5
            }
        })
    )
    
    const handleDragStart = useCallback((event: DragStartEvent) => {
        const currentSlot = typeof event.active.data.current?.slot === "number" ? event.active.data.current?.slot : null
        const potentialGroup = event.active.data.current?.group
        const currentGroup: TInventoryGroup | null =
            potentialGroup === "inventory" || potentialGroup === "equipment" || potentialGroup === "other"
                ? potentialGroup
                : null
        const currentItem = event.active.data.current?.item ?? null
        setActiveDragItem({
            item: currentItem ?? null,
            slot: currentSlot,
            group: currentGroup
        })
    }, [])

    const handleDragEnd = useCallback((event: DragEndEvent) => {
        const { active, over } = event
        const sourceSlot = active.data.current?.slot
        const targetSlot = over?.data.current?.slot
        const activeGroup = active.data.current?.group
        const targetGroup = over?.data.current?.group
        const targetGroupId = over?.data.current?.groupId
        const activeGroupId = active.data.current?.groupId
        const item: TInventoryItem = active.data.current?.item

        const isGroup = (value: unknown): value is TInventoryGroup =>
            value === "inventory" || value === "equipment" || value === "container"
        
        console.log('[UI] handleDragEnd - activeGroup: ', activeGroup)
        console.log('[UI] handleDragEnd - targetGroup: ', targetGroup)
        console.log('[UI] handleDragEnd - targetGroupId: ', targetGroupId)
        console.log('[UI] handleDragEnd - activeGroupId: ', activeGroupId)
        console.log('[UI] handleDragEnd - item: ', JSON.stringify(item))
        
        const isClothItem = item.name.startsWith('cloth_')
        // If item is not a cloth item and target group is equipment, don't allow to move
        if (!isClothItem && targetGroup === 'equipment') {
            toast.error(t('inventory.equipment.notCloth'), {
                duration: 3000
            })
            setActiveDragItem(null)
            return
        }
        // Make sure all input values are valid
        if (
            typeof sourceSlot === "number" &&
            typeof targetSlot === "number" &&
            isGroup(activeGroup) &&
            isGroup(targetGroup)
        ) {
            moveInventoryItem({
                sourceSlot,
                targetSlot,
                sourceGroup: activeGroup,
                targetGroup
            }, {
                onSuccess: () => {
                    console.log(`Moved inventory item from slot ${sourceSlot} to slot ${targetSlot}, group: ${activeGroup} to group: ${targetGroup} item: ${JSON.stringify(item)}`)
                    window.hEvent("onMoveInventoryItem", { sourceSlot, targetSlot, sourceGroup: activeGroup, targetGroup, sourceGroupId: activeGroupId ?? '', targetGroupId: targetGroupId ?? '' })
                },
                onFail: () => {
                    console.log(`Failed to move inventory item from slot ${sourceSlot} to slot ${targetSlot} item: ${JSON.stringify(item)}`)
                }
            })
        }
        setActiveDragItem(null)
    }, [moveInventoryItem])

    const handleDragCancel = useCallback(() => {
        setActiveDragItem(null)
    }, [])
    
    // Filter items with slot indices from 1 to 6
    const hotbarItems = inventoryItems.filter(item => item.slot >= 1 && item.slot <= 6).sort((a, b) => a.slot - b.slot)
    const backpackItems = inventoryItems.filter(item => item.slot >= 7).sort((a, b) => a.slot - b.slot)

    useWebUIMessage<[TOpenInventoryResult]>('openInventory', ([result]) => {
        ///////////////////////////////////////////////////////////////////////////
        // Check if result.inventory is an array or object
        if (Array.isArray(result.inventory)) {
            // It's an array
            setInventoryItems(result.inventory)
        } else if (result.inventory && typeof result.inventory === 'object') {
            // It's an object (not an array)
            const inventoryItems: TInventoryItem[] = Object.values(result.inventory).filter(item => item !== null) as TInventoryItem[]
            setInventoryItems(inventoryItems)
        }
        ///////////////////////////////////////////////////////////////////////////
        console.log(`openInventory: ${JSON.stringify(result.equipment)}`)
        // Check if result.equipment is an array or object
        if (Array.isArray(result.equipment)) {
            // It's an array
            setEquipmentItems(result.equipment)
        } else if (result.equipment && typeof result.equipment === 'object') {
            // It's an object (not an array)
            const equipmentItems: TInventoryItem[] = Object.values(result.equipment).filter(item => item !== null) as TInventoryItem[]
            setEquipmentItems(equipmentItems)
        }
        ///////////////////////////////////////////////////////////////////////////
        if (result.container) {
            // Check if result.container is an array or object
            if (Array.isArray(result.container.items)) {
                // It's an array
                setOtherItems(result.container.items)
            } else if (result.container && typeof result.container === 'object') {
                // It's an object (not an array)
                const containerItems: TInventoryItem[] = Object.values(result.container.items).filter(item => item !== null) as TInventoryItem[]
                setOtherItems(containerItems)
            }
            console.log('[UI] openInventory - container result: ', JSON.stringify(result.container))
            setOtherItemsId(result.container.id)
            setOtherItemsType('container')
            setOtherItemsSlotCount(result.container.capacity.slots)
        }
        setSlotCount(result.capacity.slots)
        setTotalWeight(result.capacity.weight)
        setOpenInventory(true)
    })
    useWebUIMessage<[]>('closeInventory', () => setOpenInventory(false))
    useWebUIMessage<[type: string, items: TInventoryItem[]]>('doSyncInventory', ([type, items]) => {
        if (type === 'sync') {
            setInventoryItems(items)
        }
    })

    useWebUIMessage<[TResponseCreateDropItem]>('onCreateDropResponse', ([result]) => {
        if (result.status) {
            // Remove temporary item from temporaryDroppedItems
            removeTemporaryDroppedItem(result.itemData)
        } else {
            // Rollback temporary item into inventory item
            rollbackTemporaryDroppedItem(result.itemData)
        }
    })
    
    useEffect(() => {
        // Only disable when menu is open
        if (!isOpenInventory) return
    
        const prevent = (e: MouseEvent) => e.preventDefault()
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === "Escape" && isOpenInventory) {
                setOpenInventory(false)
                window.hEvent("onCloseInventory")
            } else if (e.key === "Tab" && isOpenInventory) {
                setOpenInventory(false)
                window.hEvent("onCloseInventory")
            }
        }
    
        document.addEventListener("contextmenu", prevent)
        document.addEventListener("keydown", onKeyDown)
    
        return () => {
          document.removeEventListener("contextmenu", prevent)
          document.removeEventListener("keydown", onKeyDown)
        }
    }, [isOpenInventory])

    return (
        <DndContext sensors={sensors} onDragStart={handleDragStart} onDragEnd={handleDragEnd} onDragCancel={handleDragCancel}>
            <Dialog open={isOpenInventory} onOpenChange={(open) => {
                setOpenInventory(open)
                if (!open) {
                    window.hEvent("onCloseInventory")
                }
            }}>
                <DialogContent
                    className="w-[90%] h-[80vh] max-h-[80vh] select-none"
                    contentClassName=""
                    isHaveBackdropFilter
                    title={t("inventory.title")}
                    onContextMenu={(e) => e.preventDefault()}
                    aria-describedby={undefined}
                >
                    <div className="grid grid-cols-8 gap-6 p-4 flex-1 min-h-full overflow-hidden h-full">
                        <div className="col-span-2 h-full overflow-hidden p-2">
                            <CharacterInfo />
                        </div>
                        <div className="col-span-3 h-full overflow-hidden">
                            <div className="flex flex-col h-full">
                                <div className="relative shrink-0">
                                    <SheetTitle>{t("inventory.title")}</SheetTitle>
                                    <div className="absolute top-2 right-0 text-right text-xs text-muted-foreground">{t('inventory.weight')}: {formatWeight(getTotalWeight())}/{formatWeight(getTotalLimitWeight())}</div>
                                    <Separator className="relative mb-4 -top-px" />
                                    <div className="grid grid-cols-[repeat(5,96px)] gap-4 justify-center">
                                        {Array.from({ length: 5 }, (_, i) => {
                                            const slot = i + 1
                                            const item = hotbarItems.find(item => item.slot === slot)
                                                
                                            return <InventoryItem key={`${item?.name}-${slot}`} item={item} slot={slot} />
                                        })}
                                    </div>
                                </div>
                                <div className="relative mt-4 h-[calc(100%-154px)]">
                                    <SheetTitle>{t("inventory.backpack.title")}</SheetTitle>
                                    <div className="absolute top-2 right-0 text-right text-xs text-muted-foreground">{t('inventory.backpack.slotCount')}: {slotCount - DEFAULT_SLOT_COUNT}</div>
                                    <Separator className="relative mb-4 -top-px" />
                                    <ScrollArea className="h-[calc(100%-45px)] overflow-hidden" viewportClassName="[&>div]:h-full [&>div]:table-fixed">
                                        {(slotCount - DEFAULT_SLOT_COUNT) > 0 ? (
                                            <div className="grid grid-cols-[repeat(5,96px)] gap-4 grid-wrap justify-center">
                                                {Array.from({ length: (slotCount - DEFAULT_SLOT_COUNT) }, (_, i) => {
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
                        <div className="col-span-3 h-full overflow-hidden">
                            <OtherInventory />
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
            <AmountDialog />
            <DragOverlay dropAnimation={null}>
                {activeDragItem?.item ? (
                    <div className="pointer-events-none select-none">
                        <Image
                            src={`./assets/images/items/${activeDragItem.item.name}.png`}
                            alt={activeDragItem.item.label ?? activeDragItem.item.name}
                            className="w-16 h-16 object-contain drop-shadow-2xl"
                            draggable={false}
                            fallbackSrc={FALLBACK_DEFAULT_IMAGE_PATH}
                        />
                    </div>
                ) : null}
            </DragOverlay>
        </DndContext>
    )
}
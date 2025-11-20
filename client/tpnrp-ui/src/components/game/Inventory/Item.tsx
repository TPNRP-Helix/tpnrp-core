import { ContextMenu, ContextMenuTrigger, ContextMenuItem, ContextMenuContent, ContextMenuSeparator, ContextMenuSub, ContextMenuSubTrigger, ContextMenuSubContent } from "@/components/ui/context-menu"
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card"
import { ItemMedia } from "@/components/ui/item"
import { Item } from "@/components/ui/item"
import { Badge } from "@/components/ui/badge"
import type { TInventoryItemProps } from "@/types/inventory"
import { useCallback, useId, useMemo } from "react"
import { useI18n } from "@/i18n"
import { RARE_LEVELS } from "@/constants"
import { formatWeight } from "@/lib/inventory"
import { CircleEllipsis, ArrowDownCircle, Hand, HandHeart, Sparkles, Split, Star, StarHalf, Plus } from "lucide-react"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Progress } from "@/components/ui/progress"
import { useDraggable, useDroppable } from "@dnd-kit/core"
import { useDevModeStore } from "@/stores/useDevModeStore"

export const InventoryItem = (props: TInventoryItemProps) => {
    const {
        item = null,
        slot = null,
        isShowHotbarNumber = true,
        group = 'inventory',
        isDragDropDisabled = false
    } = props
    const { t } = useI18n()
    const {
        setIsOpenAmountDialog,
        setAmountDialogType,
        setDialogItem,
        setTemporaryDroppedItem
    } = useInventoryStore()

    const { permission } = useDevModeStore()

    const itemImage = useMemo(() => {
        if (item === null) {
            return null
        }
        return `./assets/images/items/${item.name}.png`
    }, [item])

    const itemLabel = useMemo(() => {
        if (item === null) {
            return ''
        }
        return t(`inventory.item.label.${item.name}`)
    }, [item])

    const rareLevel = useMemo(() => {
        if (item === null || item?.info?.rare === undefined) {
            return null
        }
        return RARE_LEVELS.find((rareItem) => rareItem.id === item?.info?.rare)
    }, [item])

    const onClickUse = useCallback(() => {
        console.log('onClickUse')
    }, [])

    const onClickSplit = useCallback(() => {
        console.log('onClickSplit')
    }, [])
    
    const onClickGive = useCallback((giveType: 'half' | 'one' | 'all') => {
        console.log('onClickGive', giveType)
    }, [])

    const onClickDrop = useCallback((dropType: 'half' | 'one' | 'all') => {
        if (item === null) {
            return
        }
        let amount = 1
        if (dropType === 'half') {
            amount = Math.floor(item.amount / 2)
        } else if (dropType === 'all') {
            amount = item.amount
        }
        setTemporaryDroppedItem({...item, amount})
        window.hEvent('createDropItem', {
            itemName: item.name,
            amount,
            fromSlot: item.slot
        })
    }, [])
    
    const onOpenAmountDialog = useCallback((dialogType: 'give' | 'drop') => {
        if (item === null) {
            return
        }
        setDialogItem(item)
        setAmountDialogType(dialogType)
        setIsOpenAmountDialog(true)
    }, [])

    const slotId = typeof slot === "number" ? slot : null
    const uniqueId = useId()
    const dndId = useMemo(() => {
        if (slotId !== null) {
            return `${group}-${slotId}`
        }
        return `${group}-${uniqueId}`
    }, [group, slotId, uniqueId])
    const hasItem = !!item
    const { attributes, listeners, setNodeRef: setDraggableNodeRef, isDragging } = useDraggable({
        id: dndId,
        disabled: !hasItem || slotId === null || isDragDropDisabled,
        data: {
            slot: slotId,
            group,
            item
        }
    })
    const { setNodeRef: setDroppableNodeRef, isOver } = useDroppable({
        id: dndId,
        disabled: isDragDropDisabled,
        data: {
            slot: slotId,
            group
        }
    })

    const setRefs = useCallback((node: HTMLDivElement | null) => {
        setDroppableNodeRef(node)
        setDraggableNodeRef(node)
    }, [setDroppableNodeRef, setDraggableNodeRef])

    const onClickAddItemToInventory = useCallback(() => {
        if (permission !== 'admin') {
            return
        }
        window.hEvent('devAddItem', {
            itemName: item?.name,
            amount: 1
        })
    }, [])

    const slotClasses = useMemo(() => {
        const base = ["w-24 h-24 bg-accent rounded transition-all duration-150 ease-out"]
        if (isOver) {
            base.push("ring-2 ring-primary/60 shadow-lg")
        }
        if (isDragging) {
            base.push("ring-2 ring-primary/60 opacity-60")
        }
        return base.join(" ")
    }, [isDragging, isOver])
    const cursorClass = isDragDropDisabled
        ? "cursor-default"
        : hasItem
            ? (isDragging ? "cursor-grabbing" : "cursor-grab")
            : "cursor-default"
    const draggableAttributes = isDragDropDisabled ? undefined : attributes
    const draggableListeners = isDragDropDisabled ? undefined : listeners

    return (
        <ContextMenu>
            <HoverCard>
                <ContextMenuTrigger asChild>
                    <HoverCardTrigger asChild>
                        <div ref={setRefs} className={`${slotClasses} ${cursorClass}`} {...(draggableAttributes ?? {})} {...(draggableListeners ?? {})}>
                            <Item className="relative gap-1 p-0 w-full h-full border-none">
                                {slot !== null && slot <= 5 && isShowHotbarNumber ? (
                                    <Badge className="absolute -top-1.5 -left-1.5 rounded [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!">
                                        {slot}
                                    </Badge>
                                ) : null}
                                {item !== null && (
                                    <>
                                        {item.amount > 1 && (
                                            <div className="absolute top-0 right-0 text-shadow-2xs text-xs p-1">
                                                x{item.amount}
                                            </div>
                                        )}
                                        <ItemMedia className="relative z-10 w-full object-cover p-4">
                                            <img src={itemImage ?? ''} alt="Item" className="w-11/12 h-11/12 object-cover select-none pointer-events-none" draggable={false} />
                                        </ItemMedia>
                                        {item.info?.durability && (
                                            <div className="absolute bottom-0 left-0 w-full">
                                                <Progress value={item?.info?.durability ?? 0} className="rounded h-1" />
                                            </div>
                                        )}
                                    </>
                                )}
                            </Item>
                        </div>
                    </HoverCardTrigger>
                </ContextMenuTrigger>
                {!!item && (
                    <HoverCardContent className="w-80 pointer-events-none select-none rounded [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!">
                        {/* Hover card more details */}
                        <div className="flex flex-col justify-between space-x-4">
                            <div className="flex flex-row justify-between space-x-4">
                                <div className='w-16 h-16'>
                                    <img
                                        src={itemImage ?? ''}
                                        alt={item?.label ?? item?.name}
                                        width={128}
                                        height={128}
                                        className="h-full w-full object-cover"
                                        // style={{
                                        //     filter: rareLevel?.color ? `drop-shadow(0 0 26px ${rareLevel?.color})` : 'none'
                                        // }}
                                    />
                                </div>
                                <div className='flex-1 px-2'>
                                    <div className='text-sm mb-2'>
                                        {itemLabel}
                                    </div>
                                    <div className='text-xs text-gray-500'>
                                        {t('inventory.amount')}: {item?.amount ?? 1}
                                    </div>
                                    {item?.info?.rare && (
                                        <div className='text-xs text-gray-500'>
                                            {t('inventory.rareLevel')}: <span className="font-bold text-shadow-md" style={{ color: rareLevel?.color ?? 'inherit' }}>{t(`inventory.${rareLevel?.name}`)}</span>
                                        </div>
                                    )}
                                    {item?.weight > 0 && (
                                        <>
                                            <div className='text-xs text-gray-500'>
                                                {t('inventory.weight')}: {formatWeight((item?.weight ?? 0) * item.amount)}
                                            </div>
                                            {item.amount > 1 && (
                                                <div className='text-xs text-gray-500'>
                                                    {t('inventory.weight')} ({t('inventory.weightPerUnit')}): {formatWeight(item?.weight ?? 0)}
                                                </div>
                                            )}
                                        </>
                                    )}
                                    {item?.info?.durability ? (
                                        <div className='text-xs text-gray-500'>
                                            {t('inventory.durability')}: {item?.info?.durability}%
                                        </div>
                                    ) : null}
                                    {item?.info?.slot ? (
                                        <div className='text-xs text-gray-500'>
                                            {t('inventory.slot')}: {item?.info?.slot}
                                        </div>
                                    ) : null}
                                    {item?.info?.maxWeight ? (
                                        <div className='text-xs text-gray-500'>
                                            {t('inventory.maxWeight')}: {formatWeight(item?.info?.maxWeight, { gram: 'gam', kg: 'kg', ton: 'ton' }, true)} ({t('inventory.canCarry')})
                                        </div>
                                    ) : null}
                                </div>
                            </div>
                            <div className='text-xs text-gray-400 mt-4'>
                                {item?.description ?? t('inventory.noDescription')}
                            </div>
                        </div>
                    </HoverCardContent>
                )}
            </HoverCard>
            {!!item && group === 'inventory' && (
                <ContextMenuContent>
                    {item.useable && (
                        <ContextMenuItem onClick={onClickUse}><Hand className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.use')}</ContextMenuItem>
                    )}
                    {item.amount > 1 && (
                        <ContextMenuItem onClick={onClickSplit}><Split className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.split')}</ContextMenuItem>
                    )}
                    {(item.useable || item.amount > 1) ? (
                        <ContextMenuSeparator />
                    ): null}
                    {item.amount > 1 ? (
                        <>
                            <ContextMenuSub>
                                <ContextMenuSubTrigger><HandHeart className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.give')}</ContextMenuSubTrigger>
                                <ContextMenuSubContent className="w-48">
                                    <ContextMenuItem onClick={() => onClickGive('half')}><StarHalf className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.half')}</ContextMenuItem>
                                    <ContextMenuItem onClick={() => onClickGive('one')}><Star className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.one')}</ContextMenuItem>
                                    <ContextMenuItem onClick={() => onClickGive('all')}><Sparkles className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.all')}</ContextMenuItem>
                                    <ContextMenuSeparator />
                                    <ContextMenuItem onClick={() => onOpenAmountDialog('give')}><CircleEllipsis className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.other')}</ContextMenuItem>
                                </ContextMenuSubContent>
                            </ContextMenuSub>
                            <ContextMenuSub>
                            <ContextMenuSubTrigger><ArrowDownCircle className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.drop')}</ContextMenuSubTrigger>
                            <ContextMenuSubContent className="w-48">
                                {item.amount > 1 && (
                                    <>
                                        <ContextMenuItem onClick={() => onClickDrop('half')}><StarHalf className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.half')}</ContextMenuItem>
                                    </>
                                )}
                                <ContextMenuItem onClick={() => onClickDrop('one')}><Star className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.one')}</ContextMenuItem>
                                <ContextMenuItem onClick={() => onClickDrop('all')}><Sparkles className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.all')}</ContextMenuItem>
                                {item.amount > 1 && (
                                    <>
                                        <ContextMenuSeparator />
                                        <ContextMenuItem onClick={() => onOpenAmountDialog('drop')}><CircleEllipsis className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.other')}</ContextMenuItem>
                                    </>
                                )}
                            </ContextMenuSubContent>
                        </ContextMenuSub>
                    </>
                    ) : (
                        <>
                            <ContextMenuItem onClick={() => onClickGive('one')}><HandHeart className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.give')}</ContextMenuItem>
                            <ContextMenuItem onClick={() => onClickDrop('one')}><ArrowDownCircle className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.drop')}</ContextMenuItem>
                        </>
                    )}
                    
                    {/* {item.name.includes('weapon_') && (
                        <>
                            <ContextMenuSeparator />
                            <ContextMenuItem onClick={onClickCopySerial}><Copy className="w-4 h-4 text-muted-foreground mr-2" /> Copy Serial</ContextMenuItem>
                            <ContextMenuItem onClick={onClickAttach}><Paperclip className="w-4 h-4 text-muted-foreground mr-2" /> Phụ kiện</ContextMenuItem>
                        </>
                    )} */}
                </ContextMenuContent>
            )}
            {!!item && group === 'dev-library' && (
                <ContextMenuContent>
                    <ContextMenuItem onClick={onClickAddItemToInventory}><Plus className="w-4 h-4 text-muted-foreground mr-2" /> {t('inventory.add')}</ContextMenuItem>
                </ContextMenuContent>
            )}
        </ContextMenu>
        
    )
}
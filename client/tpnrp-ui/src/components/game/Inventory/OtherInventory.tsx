import { Tabs, TabsContent, TabsListHelix, TabsTriggerHelix } from "@/components/ui/tabs"
import { useI18n } from "@/i18n"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { InventoryItem } from "./Item"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { PackageOpen } from "lucide-react"
import { CRAFTING_CATEGORIES } from "@/constants/crafting"
import { useState, useMemo, memo } from "react"
import { Empty, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty"
import { useShallow } from "zustand/react/shallow"

const OtherInventoryComponent = () => {
    const { t } = useI18n()
    const {
        otherItemsType,
        otherItemsSlotCount,
        otherItems,
        otherItemsId,
        isHaveOtherItems,
        selectOtherTab,
        setSelectOtherTab
    } = useInventoryStore(
        useShallow((state) => ({
            otherItemsType: state.otherItemsType,
            otherItemsSlotCount: state.otherItemsSlotCount,
            otherItems: state.otherItems,
            otherItemsId: state.otherItemsId,
            isHaveOtherItems: state.isHaveOtherItems,
            selectOtherTab: state.selectOtherTab,
            setSelectOtherTab: state.setSelectOtherTab
        }))
    )
    const [craftingCategory, setCraftingCategory] = useState<string>('all')

    // Create a map for faster item lookups by slot
    const otherItemsMap = useMemo(
        () => new Map(otherItems.map(item => [item.slot, item])),
        [otherItems]
    )
    
    return (
        <Tabs value={selectOtherTab} onValueChange={(value) => setSelectOtherTab(value as 'ground' | 'crafting' | 'missions')} className="relative w-full h-full flex flex-col">
            <TabsListHelix className="gap-px shrink-0 px-2">
                {isHaveOtherItems() && (
                    <TabsTriggerHelix value={otherItemsType}>{otherItemsId}</TabsTriggerHelix>
                )}
                <TabsTriggerHelix value="crafting">{t('inventory.other.crafting.title')}</TabsTriggerHelix>
                <TabsTriggerHelix value="missions">{t('inventory.other.missions.title')}</TabsTriggerHelix>
            </TabsListHelix>
            <Separator className="absolute mb-4 top-[calc(var(--spacing)*7-1px)] mx-2" />
            <TabsContent value="ground" className="h-full overflow-hidden">
                <ScrollArea className="h-full overflow-hidden mt-2" viewportClassName="[&>div]:h-full [&>div]:table-fixed p-2">
                    <div className="grid grid-cols-[repeat(5,96px)] gap-4 grid-wrap">
                        {Array.from({ length: otherItemsSlotCount }, (_, i) => {
                            const slot = i + 1
                            const item = otherItemsMap.get(slot) ?? null
                            return <InventoryItem key={`container-${slot}-${item?.name ?? ''}`} item={item} slot={slot} group="container" isShowHotbarNumber={false} />
                        })}
                    </div>
                </ScrollArea>
            </TabsContent>
            <TabsContent value="crafting" className="h-full overflow-hidden flex flex-col">
                <div className="flex items-center gap-4 bg-muted rounded p-2 shrink-0">
                    <Select value={craftingCategory} onValueChange={setCraftingCategory}>
                        <SelectTrigger className="w-[180px]">
                            <SelectValue placeholder={t('crafting.category.all')} />
                        </SelectTrigger>
                        <SelectContent>
                            {CRAFTING_CATEGORIES.map(category => (
                                <SelectItem key={category.value} value={category.value}> {category.icon} {t(`crafting.category.${category.value}`)}</SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                    <div className="w-full flex items-center gap-2">
                        <Input className="flex-1" placeholder={t('inventory.crafting.searchPlaceholder')} />
                    </div>
                </div>
                <ScrollArea className="flex-1 overflow-hidden mt-4" viewportClassName="[&>div]:h-full [&>div]:table-fixed">
                    <div className="grid grid-cols-[repeat(5,96px)] gap-4 grid-wrap">
                        {/* Crafting items will go here */}
                        
                    </div>
                    <Empty className="h-full w-full bg-accent rounded">
                        <EmptyHeader>
                            <EmptyMedia variant="icon">
                                <PackageOpen className="w-6 h-6 text-muted-foreground" />
                            </EmptyMedia>
                            <EmptyTitle>{t('crafting.empty')}</EmptyTitle>
                            <EmptyDescription>{t('crafting.emptyDescription')}</EmptyDescription>
                        </EmptyHeader>
                    </Empty>
                </ScrollArea>
            </TabsContent>
            <TabsContent value="missions" className="h-full overflow-hidden">
                <ScrollArea className="h-full overflow-hidden" viewportClassName="pt-1 px-1">
                    Missions
                </ScrollArea>
            </TabsContent>
        </Tabs>
    )
}

export const OtherInventory = memo(OtherInventoryComponent)
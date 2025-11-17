import { Tabs, TabsContent, TabsListHelix, TabsTriggerHelix } from "@/components/ui/tabs"
import { useI18n } from "@/i18n"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { InventoryItem } from "./Item"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { PackageOpen, Search } from "lucide-react"
import { CRAFTING_CATEGORIES } from "@/constants/crafting"
import { useState } from "react"
import { Empty, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty"

export const OtherInventory = () => {
    const { t } = useI18n()
    const {
        otherItemsType,
        otherItemsSlotCount,
        otherItems,
        isHaveOtherItems,
        selectOtherTab,
        setSelectOtherTab
    } = useInventoryStore()
    const [craftingCategory, setCraftingCategory] = useState<string>('all')
    
    return (
        <Tabs value={selectOtherTab} onValueChange={(value) => setSelectOtherTab(value as 'ground' | 'crafting' | 'missions')} className="relative w-full h-full flex flex-col">
            <TabsListHelix className="gap-[1px] shrink-0">
                {isHaveOtherItems() && (
                    <TabsTriggerHelix value={otherItemsType}>{t(`inventory.other.${otherItemsType}`)}</TabsTriggerHelix>
                )}
                <TabsTriggerHelix value="crafting">Crafting</TabsTriggerHelix>
                <TabsTriggerHelix value="missions">Missions</TabsTriggerHelix>
            </TabsListHelix>
            <Separator className="absolute mb-4 top-[calc(var(--spacing)*7-1px)]" />
            <TabsContent value="ground" className="h-full overflow-hidden">
                <ScrollArea className="h-full overflow-hidden mt-2">
                    <div className="grid grid-cols-6 gap-4 grid-wrap">
                        {Array.from({ length: otherItemsSlotCount }, (_, i) => {
                            const slot = i + 1
                            const item = otherItems.find(item => item.slot === slot)
                            return <InventoryItem key={slot} item={item} slot={slot} isShowHotbarNumber={false} />
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
                        <Button className="shrink-0"><Search className="size-4" /> {t('inventory.crafting.search')}</Button>
                    </div>
                </div>
                <ScrollArea className="flex-1 overflow-hidden mt-4">
                    <div className="grid grid-cols-6 gap-4 grid-wrap">
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
                <ScrollArea className="h-full overflow-hidden">
                    Missions
                </ScrollArea>
            </TabsContent>
        </Tabs>
    )
}
import { Tabs, TabsContent, TabsListHelix, TabsTriggerHelix } from "@/components/ui/tabs"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Separator } from "@/components/ui/separator"
import { InventoryItem } from "./Item"
import { useI18n } from "@/i18n"
import { EEquipmentSlot } from "@/constants/enum"

export const CharacterInfo = () => {
    const { selectCharacterTab, setSelectCharacterTab } = useInventoryStore()
    const { t } = useI18n()

    return (
        <Tabs value={selectCharacterTab} onValueChange={(value) => setSelectCharacterTab(value as 'equipment' | 'skills' | 'stats')} className="relative w-full! h-full flex flex-col">
            <TabsListHelix className="gap-[1px] shrink-0">
                <TabsTriggerHelix value="equipment">{t('inventory.equipment.title')}</TabsTriggerHelix>
                <TabsTriggerHelix value="skills" className="hidden">{t('inventory.skills.title')}</TabsTriggerHelix>
                <TabsTriggerHelix value="stats" className="hidden">{t('inventory.stats.title')}</TabsTriggerHelix>
            </TabsListHelix>
            <Separator className="absolute mb-4 top-[calc(var(--spacing)*7-1px)]" />
            <TabsContent value="equipment" className="h-full overflow-hidden">
                <div className="grid grid-cols-[96px_1fr_96px] h-full">
                    <div className="flex flex-col gap-2">
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Glasses} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Ears} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Gloves} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Armor} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Mask} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Watch} isShowHotbarNumber={false} />
                    </div>
                    <div></div>
                    <div className="flex flex-col gap-2">
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Hat} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Top} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Undershirts} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Leg} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Shoes} isShowHotbarNumber={false} />
                        <InventoryItem group="equipment" slot={EEquipmentSlot.Bag} isShowHotbarNumber={false} />
                    </div>
                </div>
            </TabsContent>
            <TabsContent value="skills" className="h-full overflow-hidden flex flex-col">
                skills
            </TabsContent>
            <TabsContent value="stats" className="h-full overflow-hidden">
                stats
            </TabsContent>
        </Tabs>
    )
}
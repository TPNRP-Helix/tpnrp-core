import { Tabs, TabsContent, TabsListHelix, TabsTriggerHelix } from "@/components/ui/tabs"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Separator } from "@/components/ui/separator"
import { InventoryItem } from "./Item"
import { useI18n } from "@/i18n"
import { EEquipmentSlot } from "@/constants/enum"
import { useMemo, memo } from "react"
import { useShallow } from "zustand/react/shallow"

const CharacterInfoComponent = () => {
    const {
        equipmentItems,
        selectCharacterTab,
        setSelectCharacterTab,
        getEquipmentItem
    } = useInventoryStore(
        useShallow((state) => ({
            selectCharacterTab: state.selectCharacterTab,
            equipmentItems: state.equipmentItems,
            setSelectCharacterTab: state.setSelectCharacterTab,
            getEquipmentItem: state.getEquipmentItem,
            setEquipmentItems: state.setEquipmentItems
        }))
    )
    
    const { t } = useI18n()

    const leftColumnItems = useMemo(() => [
        {
            slot: EEquipmentSlot.Glasses,
            item: getEquipmentItem(EEquipmentSlot.Glasses)
        },
        {
            slot: EEquipmentSlot.Ears,
            item: getEquipmentItem(EEquipmentSlot.Ears)
        },
        {
            slot: EEquipmentSlot.Gloves,
            item: getEquipmentItem(EEquipmentSlot.Gloves)
        },
        {
            slot: EEquipmentSlot.Armor,
            item: getEquipmentItem(EEquipmentSlot.Armor)
        },
        {
            slot: EEquipmentSlot.Mask,
            item: getEquipmentItem(EEquipmentSlot.Mask)
        },
        {
            slot: EEquipmentSlot.Watch,
            item: getEquipmentItem(EEquipmentSlot.Watch)
        }
    ], [equipmentItems, getEquipmentItem])

    const rightColumnItems = useMemo(() => [
        {
            slot: EEquipmentSlot.Hat,
            item: getEquipmentItem(EEquipmentSlot.Hat)
        },
        {
            slot: EEquipmentSlot.Top,
            item: getEquipmentItem(EEquipmentSlot.Top)
        },
        {
            slot: EEquipmentSlot.Undershirts,
            item: getEquipmentItem(EEquipmentSlot.Undershirts)
        },
        {
            slot: EEquipmentSlot.Leg,
            item: getEquipmentItem(EEquipmentSlot.Leg)
        },
        {
            slot: EEquipmentSlot.Shoes,
            item: getEquipmentItem(EEquipmentSlot.Shoes)
        },
        {
            slot: EEquipmentSlot.Bag,
            item: getEquipmentItem(EEquipmentSlot.Bag)
        }
    ], [equipmentItems, getEquipmentItem])

    return (
        <Tabs value={selectCharacterTab} onValueChange={(value) => setSelectCharacterTab(value as 'equipment' | 'skills' | 'stats')} className="relative w-full! h-full flex flex-col">
            <TabsListHelix className="gap-px shrink-0">
                <TabsTriggerHelix value="equipment">{t('inventory.equipment.title')}</TabsTriggerHelix>
                <TabsTriggerHelix value="skills" className="hidden">{t('inventory.skills.title')}</TabsTriggerHelix>
                <TabsTriggerHelix value="stats">{t('inventory.stats.title')}</TabsTriggerHelix>
            </TabsListHelix>
            <Separator className="absolute mb-4 top-[calc(var(--spacing)*7-1px)]" />
            <TabsContent value="equipment" className="h-full">
                <div className="grid grid-cols-[96px_1fr_96px] h-full">
                    <div className="flex flex-col gap-3">
                        {leftColumnItems.map((slotInfo) => (
                            <InventoryItem
                                group="equipment"
                                slot={slotInfo.slot}
                                item={slotInfo.item}
                                isShowHotbarNumber
                            />
                        ))}
                    </div>
                    <div></div>
                    <div className="flex flex-col gap-3">
                        {rightColumnItems.map((slotInfo) => (
                            <InventoryItem
                                group="equipment"
                                slot={slotInfo.slot}
                                item={slotInfo.item}
                                isShowHotbarNumber
                            />
                        ))}
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

export const CharacterInfo = memo(CharacterInfoComponent)
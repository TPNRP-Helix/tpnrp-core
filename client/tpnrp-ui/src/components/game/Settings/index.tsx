import { useGameSettingStore } from "@/stores/useGameSetting"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { UnitedStateFlag } from "@/components/svg/flags/UnitedStateFlag"
import { VietnamFlag } from "@/components/svg/flags/VietnamFlag"
import { useI18n } from "@/i18n"

export const Settings = () => {
    const {
        isSettingsOpen,
        setSettingsOpen,
        basicNeedHUDConfig,
        setBasicNeedHUDConfig,
        language,
        setLanguage,
    } = useGameSettingStore()
    const { t } = useI18n()

    return (
        <Sheet open={isSettingsOpen} onOpenChange={setSettingsOpen}>
            <SheetContent side="left" className="w-[800px] sm:max-w-[800px]">
                <SheetHeader>
                    <SheetTitle>{t("settings.title")}</SheetTitle>
                    <SheetDescription>
                        {t("settings.description")}
                    </SheetDescription>
                </SheetHeader>
                <div className="grid gap-4 p-4">
                    <div className="grid gap-2">
                        <Label>{t("selectCharacter.language.placeholder")}</Label>
                        <Select value={language} onValueChange={(val) => setLanguage(val)}>
                            <SelectTrigger className="w-[240px]">
                                <SelectValue placeholder={t("selectCharacter.language.placeholder")} />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectGroup>
                                    <SelectItem value="en"> <UnitedStateFlag /> English</SelectItem>
                                    <SelectItem value="vi"> <VietnamFlag /> Tiếng Việt</SelectItem>
                                </SelectGroup>
                            </SelectContent>
                        </Select>
                    </div>
                    <div className="grid gap-2">
                        <Label>{t("settings.showHealth")}</Label>
                        <Input type="number" value={basicNeedHUDConfig.health} onChange={(e) => setBasicNeedHUDConfig({ health: Number(e.target.value) })} />
                    </div>
                    <div className="grid gap-2">
                        <Label>{t("settings.showArmor")}</Label>
                        <Input type="number" value={basicNeedHUDConfig.armor} onChange={(e) => setBasicNeedHUDConfig({ armor: Number(e.target.value) })} />
                    </div>
                    <div className="grid gap-2">
                        <Label>{t("settings.showHunger")}</Label>
                        <Input type="number" value={basicNeedHUDConfig.hunger} onChange={(e) => setBasicNeedHUDConfig({ hunger: Number(e.target.value) })} />
                    </div>
                    <div className="grid gap-2">
                        <Label>{t("settings.showThirst")}</Label>
                        <Input type="number" value={basicNeedHUDConfig.thirst} onChange={(e) => setBasicNeedHUDConfig({ thirst: Number(e.target.value) })} />
                    </div>
                    <div className="grid gap-2">
                        <Label>{t("settings.showStamina")}</Label>
                        <Input type="number" value={basicNeedHUDConfig.stamina} onChange={(e) => setBasicNeedHUDConfig({ stamina: Number(e.target.value) })} />
                    </div>
                </div>
            </SheetContent>
        </Sheet>
    )
}
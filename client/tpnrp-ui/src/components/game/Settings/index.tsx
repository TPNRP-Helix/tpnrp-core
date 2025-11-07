import { useGameSettingStore } from "@/stores/useGameSetting"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
export const Settings = () => {
    const {
        isSettingsOpen,
        showHealthBadgeWhenSmallerThan,
        showArmorBadgeWhenSmallerThan,
        showHungerBadgeWhenSmallerThan,
        showThirstBadgeWhenSmallerThan,
        showStaminaBadgeWhenSmallerThan,
        setSettingsOpen,
        setShowHealthBadgeWhenSmallerThan,
        setShowArmorBadgeWhenSmallerThan,
        setShowHungerBadgeWhenSmallerThan,
        setShowThirstBadgeWhenSmallerThan,
        setShowStaminaBadgeWhenSmallerThan,
    } = useGameSettingStore()

    return (
        <Sheet open={isSettingsOpen} onOpenChange={setSettingsOpen}>
            <SheetContent side="left">
                <SheetHeader>
                    <SheetTitle>Settings</SheetTitle>
                    <SheetDescription>
                        Settings for the game
                    </SheetDescription>
                </SheetHeader>
                <div className="grid gap-4 p-4">
                    <div className="grid gap-2">
                        <Label>Show Health Badge When Smaller Than</Label>
                        <Input type="number" value={showHealthBadgeWhenSmallerThan} onChange={(e) => setShowHealthBadgeWhenSmallerThan(Number(e.target.value))} />
                    </div>
                    <div className="grid gap-2">
                        <Label>Show Armor Badge When Smaller Than</Label>
                        <Input type="number" value={showArmorBadgeWhenSmallerThan} onChange={(e) => setShowArmorBadgeWhenSmallerThan(Number(e.target.value))} />
                    </div>
                    <div className="grid gap-2">
                        <Label>Show Hunger Badge When Smaller Than</Label>
                        <Input type="number" value={showHungerBadgeWhenSmallerThan} onChange={(e) => setShowHungerBadgeWhenSmallerThan(Number(e.target.value))} />
                    </div>
                    <div className="grid gap-2">
                        <Label>Show Thirst Badge When Smaller Than</Label>
                        <Input type="number" value={showThirstBadgeWhenSmallerThan} onChange={(e) => setShowThirstBadgeWhenSmallerThan(Number(e.target.value))} />
                    </div>
                    <div className="grid gap-2">
                        <Label>Show Stamina Badge When Smaller Than</Label>
                        <Input type="number" value={showStaminaBadgeWhenSmallerThan} onChange={(e) => setShowStaminaBadgeWhenSmallerThan(Number(e.target.value))} />
                    </div>
                </div>
            </SheetContent>
        </Sheet>
    )
}
import { Dialog, DialogClose, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Button } from "@/components/ui/button"
import { useCallback, useState } from "react"
import { useI18n } from "@/i18n"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Label } from "@/components/ui/label"
import { useGameStore } from "@/stores/useGameStore"

export const GiveDialog = () => {
    const { isOpenGiveDialog, setIsOpenGiveDialog, dialogItem, dialogAmountItem } = useInventoryStore()
    const { playersNearBy } = useGameStore()
    const { t } = useI18n()
    const [selectedPlayer, setSelectedPlayer] = useState<string>(playersNearBy[0]?.citizenId ?? '')
    
    const onGiveAction = useCallback(() => {
        console.log('onGiveAction')
        if (dialogItem === null || selectedPlayer === '' || dialogAmountItem === 0 || dialogItem?.name === '') {
            return
        }
        window.hEvent('givePlayerItem', {
            citizenId: selectedPlayer,
            itemName: dialogItem.name,
            amount: dialogAmountItem,
            slot: dialogItem.slot
        }, (response: { status: boolean; message: string; }) => {
            console.log('[UI] givePlayerItem ', JSON.stringify(response))
        })
    }, [selectedPlayer, dialogItem, dialogAmountItem])

    return (
        <Dialog open={isOpenGiveDialog} onOpenChange={setIsOpenGiveDialog}>
            <DialogContent className="max-w-md">
                <DialogHeader>
                    <DialogTitle>{t('inventory.giveDialog.title', { item: dialogItem?.label ?? '' })}</DialogTitle>
                    <DialogDescription>
                        {t('inventory.giveDialog.description', { item: dialogItem?.label ?? '', amount: dialogAmountItem ?? 0 })}
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 p-4">
                    <RadioGroup defaultValue={selectedPlayer}>
                        {playersNearBy.map((player) => (
                            <div className="flex items-center space-x-2" key={player.citizenId}>
                                <RadioGroupItem value={player.citizenId} id={player.citizenId} onClick={() => setSelectedPlayer(player.citizenId)} />
                                <Label htmlFor={player.citizenId}>{player.name}</Label>
                            </div>
                        ))}
                    </RadioGroup>
                </div>
                <DialogFooter>
                    <DialogClose asChild>
                        <Button type="button" variant="secondary">
                        {t('inventory.amountDialog.cancel')}
                        </Button>
                    </DialogClose>
                    <Button type="button" onClick={onGiveAction}>
                        {t('inventory.giveDialog.give')}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
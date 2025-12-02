import { Dialog, DialogClose, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Button } from "@/components/ui/button"
import { useCallback } from "react"
import { useI18n } from "@/i18n"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Label } from "@/components/ui/label"
import { useWebUIMessage } from "@/hooks/use-hevent"

export const GiveDialog = () => {
    const { isOpenGiveDialog, setIsOpenGiveDialog, dialogItem, dialogAmountItem } = useInventoryStore()
    const { t } = useI18n()
    
    const onGiveAction = useCallback(() => {
        console.log('onGiveAction')
    }, [])

    useWebUIMessage<[string]>('setGivePlayerList', ([playerId]) => {
        console.log('setGivePlayerList', playerId)
    })

    return (
        <Dialog open={isOpenGiveDialog} onOpenChange={setIsOpenGiveDialog}>
            <DialogContent className="max-w-md">
                <DialogHeader>
                    <DialogTitle>{t('inventory.giveDialog.title', { item: dialogItem?.label ?? '' })}</DialogTitle>
                    <DialogDescription>
                        {t('inventory.giveDialog.description', { item: dialogItem?.label ?? '', amount: dialogAmountItem ?? 0 })}
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <RadioGroup defaultValue="option-one">
                        <div className="flex items-center space-x-2">
                            <RadioGroupItem value="option-one" id="option-one" />
                            <Label htmlFor="option-one">Option One</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                            <RadioGroupItem value="option-two" id="option-two" />
                            <Label htmlFor="option-two">Option Two</Label>
                        </div>
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
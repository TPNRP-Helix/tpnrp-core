import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert"
import { Dialog, DialogClose, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Label } from "@/components/ui/label"
import { AlertCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useCallback, useState } from "react"
import { useI18n } from "@/i18n"

export const AmountDialog = () => {
    const { isOpenAmountDialog, amountDialogType, setIsOpenAmountDialog, dialogItem } = useInventoryStore()
    const [quantity, setQuantity] = useState(1)
    const { t } = useI18n()
    
    const onAmountAction = useCallback(() => {
        console.log('onAmountAction', amountDialogType)
    }, [amountDialogType])

    return (
        <Dialog open={isOpenAmountDialog} onOpenChange={setIsOpenAmountDialog}>
            <DialogContent className="max-w-md">
                <DialogHeader>
                    <DialogTitle>{t('inventory.amountDialog.title', { type: amountDialogType === 'give' ? 'give' : 'drop', item: dialogItem?.label ?? '' })}</DialogTitle>
                    <DialogDescription>
                        {t('inventory.amountDialog.description', { amount: dialogItem?.amount ?? 0 })}
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <div className="grid grid-cols-3 items-center gap-4">
                        <Label htmlFor="amount_quantity" className="text-right">{t('inventory.amountDialog.quantity')}</Label>
                        <Input
                            id="amount_quantity"
                            type="number"
                            value={quantity}
                            onChange={(e) => {
                                const value = Number(e.target.value)
                                if (value > (dialogItem?.amount ?? 0)) {
                                    setQuantity(dialogItem?.amount ?? 0)
                                    return
                                }
                                if (value <= 0) {
                                    setQuantity(1)
                                    return
                                }
                                setQuantity(value)
                            }}
                            className="col-span-2"
                        />
                    </div>
                    {quantity > (dialogItem?.amount ?? 0) || quantity <= 0 && (
                        <Alert variant="destructive">
                            <AlertCircle className="h-4 w-4" />
                            <AlertTitle></AlertTitle>
                            <AlertDescription>{t('inventory.amountDialog.invalidQuantity')}</AlertDescription>
                        </Alert>
                    )}
                </div>
                <DialogFooter>
                    <DialogClose asChild>
                        <Button type="button" variant="secondary">
                        {t('inventory.amountDialog.cancel')}
                        </Button>
                    </DialogClose>
                    <Button type="button" onClick={onAmountAction} disabled={quantity <= 0 || quantity > (dialogItem?.amount ?? 0)}>
                        {amountDialogType === 'give' ? t('inventory.amountDialog.give') : t('inventory.amountDialog.drop')}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
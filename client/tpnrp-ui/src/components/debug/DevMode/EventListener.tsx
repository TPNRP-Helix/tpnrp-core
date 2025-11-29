import { useWebUIMessage } from "@/hooks/use-hevent"
import { useDevModeStore } from "@/stores/useDevModeStore"
import type { TInventoryItem } from "@/types/inventory"

export const DevModeEventListener = () => {
    const {
        setDevModeOpen,
        setPermission,
        setItemLibrary,
    } = useDevModeStore()
    
    useWebUIMessage<[boolean]>('setDevModeOpen', ([isOpenDevMode]) => {
        setDevModeOpen(isOpenDevMode)
    })

    useWebUIMessage<[string]>('setPermission', ([permission]) => {
        setPermission(permission)
    })

    useWebUIMessage<[TInventoryItem[]]>('syncItemsLibrary', ([items]) => {
        const devLibrary: TInventoryItem[] = []
        Object.entries(items).forEach(([_, value]) => {
            devLibrary.push({
                amount: value.amount,
                name: value.name,
                label: value.label,
                weight: value.weight,
                slot: value.slot
            })
        })
        setItemLibrary(devLibrary)
    })


    return null
}
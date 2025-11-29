import { useEffect } from "react"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Library } from "../Library"
import { FAKE_INVENTORY_ITEMS } from "../constants"
import type { TInventoryItem } from "@/types/inventory"
import { isInBrowser } from "@/lib/utils"

export const DevMode = () => {
    const {
        setDevModeOpen,
        permission, setPermission,
        setItemLibrary,
        setEnableDevMode
    } = useDevModeStore()
    const {
        inventoryItems, setInventoryItems
    } = useInventoryStore()

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

    useEffect(() => {
        if (!isInBrowser()) {
            return
        }
        setEnableDevMode(true)
        setPermission('admin')
        // Set some fake inventory item for debugging
        setInventoryItems([...inventoryItems, ...FAKE_INVENTORY_ITEMS])
        setItemLibrary(FAKE_INVENTORY_ITEMS)
    }, [])
    
    // Don't render the dev mode tools if not in browser
    // Or if the permission is not admin
    if (permission !== 'admin') return null

    return <Library />
}
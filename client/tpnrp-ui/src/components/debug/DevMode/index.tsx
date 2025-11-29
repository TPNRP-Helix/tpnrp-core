import { useEffect } from "react"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Library } from "../Library"
import { FAKE_INVENTORY_ITEMS } from "../constants"
import { isInBrowser } from "@/lib/utils"

export const DevMode = () => {
    const {
        permission, setPermission,
        setItemLibrary,
        setEnableDevMode
    } = useDevModeStore()
    const {
        inventoryItems, setInventoryItems
    } = useInventoryStore()

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
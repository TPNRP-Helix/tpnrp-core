import { Sheet, SheetContent } from "@/components/ui/sheet"
import { useEffect } from "react"
import { Console } from "./Console"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useInventoryStore } from "@/stores/useInventoryStore"
import { Library } from "../Library"
import { FAKE_INVENTORY_ITEMS } from "../constants"
import type { TInventoryItem } from "@/types/inventory"

export const DevMode = () => {
    const {
        setDevModeOpen,
        isConsoleOpen, setConsoleOpen,
        permission, setPermission,
        setItemLibrary,
        appendConsoleMessage,
        setEnableDevMode
    } = useDevModeStore()
    const {
        inventoryItems, setInventoryItems
    } = useInventoryStore()

    useWebUIMessage<[boolean]>('setConsoleOpen', ([isOpenConsole]) => {
        setConsoleOpen(isOpenConsole)
    })

    useWebUIMessage<[boolean]>('setDevModeOpen', ([isOpenDevMode]) => {
        setDevModeOpen(isOpenDevMode)
    })

    useWebUIMessage<[string]>('setPermission', ([permission]) => {
        appendConsoleMessage({ message: `setPermission: ${permission}`, index: 0 })
        setPermission(permission)
    })

    useWebUIMessage<[TInventoryItem[]]>('syncItemsLibrary', ([items]) => {
        appendConsoleMessage({ message: `syncItemsLibrary: ${JSON.stringify(items)}`, index: 0 })
        // setItemLibrary(items)
    })

    useEffect(() => {
        const isInBrowser = window.location.port === '5173'
        appendConsoleMessage({ message: `isInBrowser: ${isInBrowser.toString()}`, index: 0 })
        appendConsoleMessage({ message: `window.location.href: ${window.location.href}`, index: 0 })
        if (isInBrowser) {
            setEnableDevMode(true)
            setPermission('admin')
            // Set some fake inventory item for debugging
            setInventoryItems([...inventoryItems, ...FAKE_INVENTORY_ITEMS])
            setItemLibrary(FAKE_INVENTORY_ITEMS)
        }
    }, [])
    
    // Don't render the dev mode tools if not in browser
    // Or if the permission is not admin
    if (permission !== 'admin') return null

    return (
        <>
        <Sheet open={isConsoleOpen} onOpenChange={(open) => {
            setConsoleOpen(open)
            if (!open) {
                window.hEvent("doOutFocus")
            }
        }}>
            <SheetContent title="Console" className="w-[800px] sm:max-w-[800px]">
                <div className="flex flex-col gap-4 p-4 h-full">
                    <Console />
                </div>
            </SheetContent>
        </Sheet>
        <Library />
    </>
    )
}
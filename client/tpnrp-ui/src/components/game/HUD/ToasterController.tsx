import { Toaster } from "@/components/ui/sonner"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useGameSettingStore } from "@/stores/useGameSetting"
import type { TNotification } from "@/types/game"
import { toast, type ExternalToast } from "sonner"

export const ToasterController = () => {
    const { toastConfig, setToastConfig } = useGameSettingStore()

    useWebUIMessage<[number, boolean]>('setToastConfig', ([visibleToasts, isExpand]) => {
        setToastConfig({ visibleToasts, isExpand })
    })

    useWebUIMessage('toggleToastExpand', () => {
        setToastConfig({ ...toastConfig, isExpand: !toastConfig.isExpand })
    })

    useWebUIMessage<[TNotification]>('showNotification', ([notification]) => {
        const { title, message, duration = 3000, type = 'info' } = notification
        const options: ExternalToast = {
            duration
        }
        // Set message if exists
        if (message) {
            options.description = message
        }

        switch (type) {
            case 'success':
                toast.success(title, options)
                break
            case 'error':
                toast.error(title, options)
                break
            case 'warning':
                toast.warning(title, options)
                break
            case 'info':
                toast.info(title, options)
                break
            default:
                toast(title, options)
                break
        }
    })

    return (
        <Toaster
            position="top-right"
            visibleToasts={toastConfig.visibleToasts ?? 5}
            expand={toastConfig.isExpand ?? true}
            toastOptions={{
                classNames: {
                    toast: 'rounded! [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!',
                    description: 'text-accent-foreground/80!',
                }
            }}
        />
    )
}
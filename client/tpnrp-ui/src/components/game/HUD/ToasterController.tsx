import { Toaster } from "@/components/ui/sonner"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useGameSettingStore } from "@/stores/useGameSetting"

export const ToasterController = () => {
    const { toastConfig, setToastConfig } = useGameSettingStore()

    useWebUIMessage<[number, boolean]>('setToastConfig', ([visibleToasts, isExpand]) => {
        setToastConfig({ visibleToasts, isExpand })
    })

    useWebUIMessage('toggleToastExpand', () => {
        setToastConfig({ ...toastConfig, isExpand: !toastConfig.isExpand })
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
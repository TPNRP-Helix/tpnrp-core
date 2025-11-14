import { Button } from "@/components/ui/button";
import { Kbd } from "@/components/ui/kbd";
import { useWebUIMessage } from "@/hooks/use-hevent";
import { useI18n } from "@/i18n";
import { verticalStackAnim } from "@/lib/animation";
import { useDevModeStore } from "@/stores/useDevModeStore";
import { useGameSettingStore } from "@/stores/useGameSetting";
import { AnimatePresence, motion } from "motion/react"
import { useState } from "react"

interface HelperItem {
    id: string;
    label: string;
    shortcut: string;
    onClick?: () => void;
}

const MotionButton = motion(Button)
  
export const GuideHelper = () => {
    const { t } = useI18n()
    const [open, setOpen] = useState(false)
    const { permission, toggleDevMode, toggleConsole } = useDevModeStore()
    const { toastConfig, setToastConfig, uiConfig } = useGameSettingStore()
    
    const helperItems: HelperItem[] = [
        { id: 'focus', label: "helper.toggleFocus", shortcut: "F2", onClick: () => {} },
        { id: 'toast', label: "helper.toggleToastExpand", shortcut: "F3", onClick: () => setToastConfig({ ...toastConfig, isExpand: !toastConfig.isExpand }) },
    ]
    if (permission === 'admin') {
        helperItems.push({ id: 'devMode', label: "helper.toggleDevMode", shortcut: "F7", onClick: () => {
            toggleDevMode()
            setOpen(false)
        } })
        helperItems.push({ id: 'console', label: "helper.toggleConsole", shortcut: "F8", onClick: () => {
            toggleConsole()
            setOpen(false)
        } })
    }

    useWebUIMessage<[boolean]>('toggleGuideHelper', () => {
        setOpen((prev) => !prev)
    })

    return (
        <div className="fixed bottom-8 left-2 flex flex-col items-start">
            {/* Stack Animation */}
            <AnimatePresence>
                {open && helperItems.map((helperItem, index) => (
                    <MotionButton
                        key={`${index}-${helperItem.id}`}
                        initial={{ y: 0, rotate: 0, opacity: 0 }}
                        animate={verticalStackAnim({ index })}
                        exit={{ y: 0, rotate: 0, opacity: 0 }}
                        transition={{ type: "spring", stiffness: 250, damping: 18 }}
                        variant="secondary"
                        size="sm"
                        className="absolute flex items-center justify-center rounded p-1 [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]! transition-none"
                        style={{
                            zIndex: helperItems.length - index,
                            transformOrigin: "bottom center",
                        }}
                        onClick={helperItem.onClick}
                    >
                        <span className="text-sm pr-2">
                            <Kbd className="bg-muted-foreground text-muted-background mr-2">{helperItem.shortcut}</Kbd>
                            {t(helperItem.label)}
                        </span>
                    </MotionButton>
                ))}
            </AnimatePresence>

            {/* Main Dock Button */}
            {uiConfig.isShowGuideHelper && (
                <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => setOpen((prev) => !prev)}
                    className="relative z-50"
                >
                    <Kbd className="bg-muted-foreground text-muted-background">F1</Kbd> {t("helper.toggleGuideHelper")}
                </Button>
            )}
        </div>
    )
}
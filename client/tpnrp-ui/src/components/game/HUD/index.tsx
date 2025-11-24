import { motion, AnimatePresence } from "motion/react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { GlassWater, Ham, Heart, Loader2, Shield, Smartphone, Zap } from "lucide-react"
import { useGameStore } from "@/stores/useGameStore"
import { useGameSettingStore } from "@/stores/useGameSettingStore"
import defaultAvatar from "@/assets/images/default-avatar.png"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { usePhoneStore } from "@/stores/usePhoneStore"
import { heartbeatAnimation } from "@/lib/animation"
import { cn } from "@/lib/utils"
import { Dialog, DialogContent } from "@/components/ui/dialog"
import { useEffect } from "react"
import { useDevModeStore } from "@/stores/useDevModeStore"

const MotionHeart = motion(Heart)
const MotionShield = motion(Shield)
const MotionHam = motion(Ham)
const MotionGlassWater = motion(GlassWater)
const MotionZap = motion(Zap)
const MotionPhone = motion(Smartphone)

const LIMIT_DESTRUCTIVE_COLOR = 10 // Limit value to show destructive color

export const HUD = () => {
  const { isHudVisible, basicNeeds, setBasicNeeds, isShowLoading, loadingText, setShowLoading, setIsInGame } = useGameStore()
  const { basicNeedHUDConfig } = useGameSettingStore()
  const { notifications } = usePhoneStore()
  const { isEnableDevMode } = useDevModeStore()

  useWebUIMessage<[number]>('setHealth', ([health]) => {
    setBasicNeeds({ health })
  })

  useWebUIMessage<[number]>('setArmor', ([armor]) => {
    setBasicNeeds({ armor })
  })

  useWebUIMessage<[number, number]>('setBasicNeeds', ([hunger, thirst]) => {
    console.log('setBasicNeeds', hunger, thirst)
    setBasicNeeds({ hunger, thirst })
  })

  const hudVariants = {
    open: { opacity: 1, x: 0 },
    closed: { opacity: 0, x: 500 },
    exit: { opacity: 0, x: 500 },
  }

  const phoneUnreadNotifications = notifications.filter((notification) => !notification.isRead)

  const stats = [
    {
      key: "health",
      value: basicNeeds.health,
      Icon: MotionHeart,
      fillColor: '#dc2626',
      showBadge: basicNeeds.health < basicNeedHUDConfig.health,
      iconClassName: "h-12 outline-none!",
      isShowColorFill: true
    },
    {
      key: "armor",
      value: basicNeeds.armor,
      Icon: MotionShield,
      fillColor: '#2563eb',
      showBadge: basicNeeds.armor < basicNeedHUDConfig.armor,
      iconClassName: "h-12 outline-none!",
      isShowColorFill: true
    },
    {
      key: "hunger",
      value: basicNeeds.hunger,
      Icon: MotionHam,
      fillColor: '#ea580c',
      showBadge: basicNeeds.hunger < basicNeedHUDConfig.hunger,
      iconClassName: "h-12 outline-none!",
      isShowColorFill: true
    },
    {
      key: "thirst",
      value: basicNeeds.thirst,
      Icon: MotionGlassWater,
      fillColor: '#0891b2',
      showBadge: basicNeeds.thirst < basicNeedHUDConfig.thirst,
      iconClassName: "h-12 outline-none!",
      isShowColorFill: true
    },
    {
      key: "stamina",
      value: basicNeeds.stamina,
      Icon: MotionZap,
      fillColor: '#eab308',
      showBadge: basicNeeds.stamina < basicNeedHUDConfig.stamina,
      iconClassName: "h-12 outline-none!",
      isShowColorFill: true
    },
    {
      key: "phone",
      value: phoneUnreadNotifications.length, // Phone notifications count
      Icon: MotionPhone,
      fillColor: '#9333ea',
      showBadge: phoneUnreadNotifications.length > 0,
      iconClassName: "h-12 outline-none!",
      isShowColorFill: false // Phone only have notification then it shouldn't have fill color
    }
  ]

  useEffect(() => {
    if (isEnableDevMode) {
      setTimeout(() => {
        setShowLoading(false)
        setIsInGame(true)
      }, 1000)
    }
  }, [isEnableDevMode])

  return (
    <AnimatePresence>
      {isHudVisible && (
        <motion.div
          variants={hudVariants}
          initial="closed"
          animate="open"
          exit="exit"
          transition={{ duration: 0.5, ease: "backInOut" }}
          className="fixed flex bottom-5 right-5 z-10 rounded-full w-72 h-12 bg-secondary text-primary-foreground! p-0"
        >
          {stats.map(({ key, Icon, value, showBadge, iconClassName, fillColor, isShowColorFill }) => {
            
            return (
              <div
                key={key}
                className={`relative flex items-center justify-center w-12`.trim()}
              >
                {isShowColorFill && basicNeedHUDConfig.isShowColorFill && (
                  <div className="absolute w-6 h-6 top-0 left-0 right-0 bottom-0 mt-3 ml-2 z-0 overflow-hidden">
                    <Icon
                      className={cn(iconClassName, "w-full h-full")}
                      fill={fillColor}
                      stroke="none"
                      style={{
                        clipPath: `inset(${100 - value}% 0 0 0)`,
                      }}
                    />
                  </div>
                )}
                <Icon
                  className={cn(iconClassName, "z-10 relative")}
                  {...(showBadge && value > 0 && value <= LIMIT_DESTRUCTIVE_COLOR && basicNeedHUDConfig.isShowBeatAnimation ? heartbeatAnimation : { animate: { scale: 1 }, transition: { duration: 0.2 } })}
                />
                {showBadge && value > 0 && (
                  <Badge
                    className="text-xs! h-5 min-w-5 rounded-full px-1 font-mono tabular-nums absolute -top-1 -right-1"
                    variant={value <= LIMIT_DESTRUCTIVE_COLOR ? 'destructive' : 'secondary'}
                  >
                    {value}
                  </Badge>
                )}
              </div>
            )
          })}

          {/* TODO: Update avatar to use the player's avatar */}
          <div className="flex items-center justify-center w-12">
            <Avatar>
              <AvatarImage src={defaultAvatar} alt="@shadcn" />
              <AvatarFallback>LK</AvatarFallback>
            </Avatar>
          </div>
        </motion.div>
      )}
      <Dialog open={isShowLoading} onOpenChange={setShowLoading}>
        <DialogContent
          className="outline-none! w-[400px]"
          showCloseButton={false}
          title="Loading"
          onInteractOutside={(e) => e.preventDefault()}
          aria-describedby={undefined}
        >
          <div className="flex items-center justify-center py-8 px-4 gap-2">
            <Loader2 className="w-4 h-4 animate-spin" />
            <span className="text-sm text-primary-foreground!">{loadingText}</span>
          </div>
        </DialogContent>
      </Dialog>
    </AnimatePresence>
  )
}
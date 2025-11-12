import { motion, AnimatePresence } from "motion/react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { GlassWater, Ham, Heart, Shield, Smartphone, Zap } from "lucide-react"
import { useGameStore } from "@/stores/useGameStore"
import { useGameSettingStore } from "@/stores/useGameSetting"
import defaultAvatar from "@/assets/images/default-avatar.png"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { usePhoneStore } from "@/stores/usePhoneStore"
import { heartbeatAnimation } from "@/lib/animation"
import { cn } from "@/lib/utils"

const MotionHeart = motion(Heart)
const MotionShield = motion(Shield)
const MotionHam = motion(Ham)
const MotionGlassWater = motion(GlassWater)
const MotionZap = motion(Zap)
const MotionPhone = motion(Smartphone)

export const HUD = () => {
  const { isHudVisible, basicNeeds, setBasicNeeds } = useGameStore()
  const { basicNeedHUDConfig } = useGameSettingStore()
  const { notifications } = usePhoneStore()

  useWebUIMessage<[number]>('setHealth', ([health]) => {
    setBasicNeeds({ health })
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
                  <div className="absolute w-6 h-5 top-0 left-0 right-0 bottom-0 mt-3.5 ml-2 z-0 overflow-hidden">
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
                  {...(showBadge && value > 0 && value < 20 && basicNeedHUDConfig.isShowBeatAnimation ? heartbeatAnimation : { animate: { scale: 1 }, transition: { duration: 0.2 } })}
                />
                {showBadge && value > 0 && (
                  <Badge
                    className="text-xs! h-5 min-w-5 rounded-full px-1 font-mono tabular-nums absolute -top-1 -right-1"
                    variant={value < 20 ? 'destructive' : 'secondary'}
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
    </AnimatePresence>
  )
}
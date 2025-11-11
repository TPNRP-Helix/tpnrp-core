import { motion } from "motion/react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { GlassWater, Ham, Heart, Shield, Smartphone, Zap } from "lucide-react"
import { useGameStore } from "@/stores/useGameStore"
import { useGameSettingStore } from "@/stores/useGameSetting"
import defaultAvatar from "@/assets/images/default-avatar.png"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { usePhoneStore } from "@/stores/usePhoneStore"
import { heartbeatAnimation } from "@/lib/animation"

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
  }

  const stats = [
    {
      key: "health",
      value: basicNeeds.health,
      Icon: MotionHeart,
      showBadge: basicNeeds.health < basicNeedHUDConfig.health,
      iconClassName: "h-12 outline-none!",
      containerClassName: "flex-col",
    },
    {
      key: "armor",
      value: basicNeeds.armor,
      Icon: MotionShield,
      showBadge: basicNeeds.armor < basicNeedHUDConfig.armor,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "hunger",
      value: basicNeeds.hunger,
      Icon: MotionHam,
      showBadge: basicNeeds.hunger < basicNeedHUDConfig.hunger,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "thirst",
      value: basicNeeds.thirst,
      Icon: MotionGlassWater,
      showBadge: basicNeeds.thirst < basicNeedHUDConfig.thirst,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "stamina",
      value: basicNeeds.stamina,
      Icon: MotionZap,
      showBadge: basicNeeds.stamina < basicNeedHUDConfig.stamina,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "phone",
      value: notifications.filter((notification) => !notification.isRead).length, // Phone notifications count
      Icon: MotionPhone,
      showBadge: notifications.filter((notification) => !notification.isRead).length > 0,
      iconClassName: "h-12 outline-none!",
    }
  ]

  return (
    <motion.div
      variants={hudVariants}
      initial="closed"
      animate={isHudVisible ? "open" : "closed"}
      transition={{ duration: 0.5, ease: "backInOut" }}
      className="fixed flex bottom-5 right-5 z-10 rounded-full w-72 h-12 bg-secondary text-primary-foreground! p-0"
    >
      {stats.map(({ key, Icon, value, showBadge, iconClassName, containerClassName }) => (
        <div
          key={key}
          className={`relative flex items-center justify-center w-12 ${containerClassName ?? ""}`.trim()}
        >
          <Icon
            className={iconClassName}
            {...(showBadge && value > 0 && value < 20 ? heartbeatAnimation : { animate: { scale: 1 }, transition: { duration: 0.2 } })}
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
      ))}

      {/* TODO: Update avatar to use the player's avatar */}
      <div className="flex items-center justify-center w-12">
        <Avatar>
          <AvatarImage src={defaultAvatar} alt="@shadcn" />
          <AvatarFallback>LK</AvatarFallback>
        </Avatar>
      </div>
    </motion.div>
  )
}
import { motion } from "motion/react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { GlassWater, Ham, Heart, Shield, Zap } from "lucide-react"
import { useGameStore } from "@/stores/useGameStore"
import { useGameSettingStore } from "@/stores/useGameSetting"
import defaultAvatar from "@/assets/images/default-avatar.png"
import { useWebUIMessage } from "@/hooks/use-hevent"

const MotionHeart = motion(Heart)
const MotionShield = motion(Shield)
const MotionHam = motion(Ham)
const MotionGlassWater = motion(GlassWater)
const MotionZap = motion(Zap)

export const HUD = () => {
  const { isHudVisible, health, armor, hunger, thirst, stamina, setHealth } = useGameStore()
  const {
    showHealthBadgeWhenSmallerThan,
    showArmorBadgeWhenSmallerThan,
    showHungerBadgeWhenSmallerThan,
    showThirstBadgeWhenSmallerThan,
    showStaminaBadgeWhenSmallerThan
  } = useGameSettingStore()

  useWebUIMessage<[number]>('setHealth', ([health]) => {
    setHealth(health)
  })

  const hudVariants = {
    open: { opacity: 1, x: 0 },
    closed: { opacity: 0, x: 500 },
  }

  const stats = [
    {
      key: "health",
      value: health,
      Icon: MotionHeart,
      showBadge: health < showHealthBadgeWhenSmallerThan,
      iconClassName: "h-12 outline-none!",
      containerClassName: "flex-col",
    },
    {
      key: "armor",
      value: armor,
      Icon: MotionShield,
      showBadge: armor < showArmorBadgeWhenSmallerThan,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "hunger",
      value: hunger,
      Icon: MotionHam,
      showBadge: hunger < showHungerBadgeWhenSmallerThan,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "thirst",
      value: thirst,
      Icon: MotionGlassWater,
      showBadge: thirst < showThirstBadgeWhenSmallerThan,
      iconClassName: "h-12 outline-none!",
    },
    {
      key: "stamina",
      value: stamina,
      Icon: MotionZap,
      showBadge: stamina < showStaminaBadgeWhenSmallerThan,
      iconClassName: "h-12 outline-none!",
    },
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
          <Icon className={iconClassName} />
          {showBadge && (
            <Badge
              className="text-xs! bg-destructive! h-5 min-w-5 rounded-full px-1 font-mono tabular-nums absolute -top-1 -right-1"
              variant="destructive"
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
import { motion } from "motion/react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { GlassWater, Heart, Shield, Zap } from "lucide-react"
import { useState } from "react";

const MotionHeart = motion(Heart);
const MotionGlassWater = motion(GlassWater);
const MotionZap = motion(Zap);
const MotionShield = motion(Shield);
const MotionAvatar = motion(Avatar);

export const HUD = () => {
  const [isOpen, setIsOpen] = useState(false)
  const hudVariants = {
    open: { opacity: 1, x: 0 },
    closed: { opacity: 0, x: 500 },
  }

  return (
    <motion.div
      variants={hudVariants}
      initial="closed"
      animate={isOpen ? "open" : "closed"}
      transition={{ duration: 0.5 }}
      className="fixed flex bottom-5 right-5 z-10 rounded-full w-60 h-12 bg-secondary text-primary-foreground! px-1 py-0"
    >
      <div className="flex items-center justify-center w-12">
        <MotionHeart
          className="h-12 outline-none!"
          whileTap={{
            scale: 1.3,
            transition: { type: "spring", stiffness: 300, damping: 10 },
          }}
        />
      </div>
      <div className="flex items-center justify-center w-12">
        <GlassWater className="h-12" />
      </div>
      <div className="flex items-center justify-center w-12">
        <Zap className="h-12" />
      </div>
      <div className="flex items-center justify-center w-12">
        <Shield className="h-12" />
      </div>
      <div className="flex items-center justify-center w-12">
        <Avatar>
          <AvatarImage src="https://github.com/shadcn.png" alt="@shadcn" />
          <AvatarFallback>CN</AvatarFallback>
        </Avatar>
      </div>
    </motion.div>
  )
}
export const verticalStackAnim = ({ index }: { index: number }) => {
    return {
        y: -(index + 1) * 44,
        scale: 1,
        opacity: 1,
    }
}

export const verticalFanStackAnim = ({ index }: { index: number }) => {
    return {
        y: -(index + 1) * 60,
        rotate: (index - 1.5) * 5, // fan-out style
        opacity: 1,
      }
}

export const heartbeatAnimation = {
  animate: { scale: [1, 1.15, 1] },
  transition: {
    duration: 0.2,
    ease: "easeInOut" as const,
    repeat: Infinity,
    repeatDelay: 0.2,
  },
}

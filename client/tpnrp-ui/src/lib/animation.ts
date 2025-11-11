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
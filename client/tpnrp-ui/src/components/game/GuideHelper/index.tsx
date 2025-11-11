import { Button } from "@/components/ui/button";
import { Kbd } from "@/components/ui/kbd";
import { verticalStackAnim } from "@/lib/animation";
import { AnimatePresence, motion } from "motion/react"
import { useState } from "react"

interface FileItem {
    id: number;
    name: string;
    icon: string;
}
  
  const files: FileItem[] = [
    { id: 1, name: "Resume.pdf", icon: "📄" },
    { id: 2, name: "Photo.png", icon: "🖼️" },
    { id: 3, name: "Archive.zip", icon: "🗜️" },
    { id: 4, name: "Music.mp3", icon: "🎵" },
]

const MotionButton = motion(Button)
  
export const GuideHelper = () => {
    const [open, setOpen] = useState(false)

    return (
        <div className="fixed bottom-8 right-2 flex flex-col items-end">
            {/* Stack Animation */}
            <AnimatePresence>
                {open && files.map((file, index) => (
                    // <motion.div
                    //     key={file.id}
                    //     initial={{ y: 0, rotate: 0, opacity: 0 }}
                    //     animate={verticalStackAnim({ index })}
                    //     exit={{ y: 0, rotate: 0, opacity: 0 }}
                    //     transition={{ type: "spring", stiffness: 250, damping: 18 }}
                    //     className="absolute flex p-2 items-center justify-center bg-background rounded [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!"
                    //     style={{
                    //         zIndex: files.length - index,
                    //         transformOrigin: "bottom center",
                    //     }}
                    //     >
                    //     <span className="text-sm">{file.name}</span>
                    // </motion.div>
                    <MotionButton
                        key={file.id}
                        initial={{ y: 0, rotate: 0, opacity: 0 }}
                        animate={verticalStackAnim({ index })}
                        exit={{ y: 0, rotate: 0, opacity: 0 }}
                        transition={{ type: "spring", stiffness: 250, damping: 18 }}
                        variant="secondary"
                        size="sm"
                        className="absolute flex items-center justify-center rounded p-1 [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]! transition-none"
                        style={{
                            zIndex: files.length - index,
                            transformOrigin: "bottom center",
                        }}
                    >
                        <span className="text-sm">{file.name}</span>
                    </MotionButton>
                ))}
            </AnimatePresence>

            {/* Main Dock Button */}
            <Button
                variant="secondary"
                size="sm"
                onClick={() => setOpen((prev) => !prev)}
                className="relative z-50"
            >
                <Kbd className="bg-muted-foreground text-muted-background">/</Kbd> Guide
            </Button>
        </div>
    )
}
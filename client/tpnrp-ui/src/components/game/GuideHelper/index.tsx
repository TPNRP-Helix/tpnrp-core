import { Button } from "@/components/ui/button";
import { verticalStackAnim } from "@/lib/animation";
import { Download } from "lucide-react";
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

  
export const GuideHelper = () => {
    const [open, setOpen] = useState(false)

    return (
        <div className="fixed bottom-8 right-8 flex flex-col items-center">
            {/* Stack Animation */}
            <AnimatePresence>
                {open &&
                files.map((file, index) => (
                    <motion.div
                    key={file.id}
                    initial={{ y: 0, rotate: 0, opacity: 0 }}
                    animate={verticalStackAnim({ index })}
                    exit={{ y: 0, rotate: 0, opacity: 0 }}
                    transition={{ type: "spring", stiffness: 250, damping: 18 }}
                    className="absolute flex h-12 w-12 items-center justify-center rounded-xl bg-white shadow-lg border"
                    style={{
                        zIndex: files.length - index,
                        transformOrigin: "bottom center",
                    }}
                    >
                    <span className="text-2xl">{file.icon}</span>
                    </motion.div>
                ))}
            </AnimatePresence>

            {/* Main Dock Button */}
            <Button
                variant="default"
                size="icon"
                onClick={() => setOpen((prev) => !prev)}
                className="relative z-50 h-12 w-12 rounded-full"
            >
                <Download className="h-5 w-5" />
            </Button>
        </div>
    )
}
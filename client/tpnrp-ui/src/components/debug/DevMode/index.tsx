import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useEffect, useState } from "react"
import helixBgImage from "@/assets/devmode/helix-bg.png"
import { Console } from "./Console"
const IS_SHOW_BG = false

export const DevMode = () => {
    const [isOpenDevMode, setIsOpenDevMode] = useState(false)
    const [isShowConsole, setIsShowConsole] = useState(true)

    useEffect(() => {
        window.addEventListener("message", function (event) {
            if (!event.data || !event.data.name) return;

            switch (event.data.name) {
                case "onToggleConsole":
                    setIsShowConsole(prev => !prev)
                break;
            }
        });
    }, [])
    
    return (
        <>
        {IS_SHOW_BG && (
            <div className="fixed top-0 left-0 w-full h-full -z-10">
                <img src={helixBgImage} alt="DevMode" className="w-full h-full object-cover" />
            </div>
        )}
        <Sheet open={isOpenDevMode} onOpenChange={setIsOpenDevMode}>
            <SheetTrigger asChild>
                <Button className="relative top-1 left-1">Dev Mode</Button>
            </SheetTrigger>
            <SheetContent>
                <SheetHeader>
                <SheetTitle>Dev Mode Tools</SheetTitle>
                <SheetDescription>
                    DevMode Tools support for testing inventory features
                </SheetDescription>
                </SheetHeader>
                <div className="grid gap-4 p-4">
                    <Tabs defaultValue="inventory" className="w-full">
                        <TabsList className="grid w-full grid-cols-2">
                            <TabsTrigger value="inventory">Inventory</TabsTrigger>
                            <TabsTrigger value="menu">Menu</TabsTrigger>
                        </TabsList>
                        <TabsContent value="inventory">
                            inventory
                        </TabsContent>
                        <TabsContent value="menu">
                            menu
                        </TabsContent>
                    </Tabs>
                </div>
            </SheetContent>
        </Sheet>
        <Sheet open={isShowConsole} onOpenChange={setIsShowConsole}>
            <SheetTrigger asChild>
                <Button className="relative top-1 left-1 ml-2">Console</Button>
            </SheetTrigger>
            <SheetContent className="w-[800px] sm:max-w-[800px]">
                <SheetHeader>
                    <SheetTitle>Console</SheetTitle>
                </SheetHeader>
                <div className="grid gap-4 p-4">
                    <Console />
                </div>
            </SheetContent>
        </Sheet>
    </>
    )
}
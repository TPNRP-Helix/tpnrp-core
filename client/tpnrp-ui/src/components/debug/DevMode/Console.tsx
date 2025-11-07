import { ScrollArea } from "@/components/ui/scroll-area"
import { useEffect, useState } from "react"

export const Console = () => {
    const [messages, setMessages] = useState<{ message: string, index: number }[]>([])

    const handleConsoleMessage = (event: MessageEvent) => {
        if (!event.data || !event.data.name) return
        console.log('event.data', event.data)
        switch (event.data.name) {
            case "onLogMessage":
                setMessages((prev) => [...prev, { message: event.data.args[0], index: event.data.args[1] }])
            break
        }
    }

    useEffect(() => {
        window.addEventListener("message", handleConsoleMessage)
        return () => {
            window.removeEventListener("message", handleConsoleMessage)
        }
    }, [])

    return (
        <>
            <div className="flex flex-col gap-2 border border-black rounded-md p-2 bg-black h-[calc(100vh-10rem)]">
                <ScrollArea>
                    {messages.map((message) => (
                        <div key={message.index}>{message.message}</div>
                    ))}
                </ScrollArea>
            </div>
        </>
    )
}
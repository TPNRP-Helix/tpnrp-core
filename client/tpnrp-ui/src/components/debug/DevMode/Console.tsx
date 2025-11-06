import { ScrollArea } from "@/components/ui/scroll-area"
import { useEffect, useState } from "react"

export const Console = () => {
    const [messages, setMessages] = useState<{ message: string, index: number }[]>([])

    useEffect(() => {
        
        window.addEventListener("message", function (event) {
            if (!event.data || !event.data.name) return;

            switch (event.data.name) {
                case "onLogMessage":
                    console.log('event.data', event.data)
                    setMessages((prev) => [...prev, { message: event.data.args[0], index: event.data.args[1] }])
                break;
            }
        });
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
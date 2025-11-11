import { ScrollArea } from "@/components/ui/scroll-area"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { useWebUIMessage } from "@/hooks/use-hevent"

export const Console = () => {
    const { consoleMessages, appendConsoleMessage } = useDevModeStore()

    useWebUIMessage<[string, number]>('onLogMessage', ([message, index]) => {
        appendConsoleMessage({ message, index })
    })

    return (
        <>
            <div className="flex flex-col gap-2 border border-black rounded-md p-2 bg-black h-[calc(100vh-10rem)]">
                <ScrollArea>
                    {consoleMessages.map((message) => (
                        <div key={message.index}>{message.message}</div>
                    ))}
                </ScrollArea>
            </div>
        </>
    )
}
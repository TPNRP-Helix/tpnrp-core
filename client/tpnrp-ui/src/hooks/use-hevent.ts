import { useEffect } from 'react'


interface WebUIMessageData<T = unknown> {
  name: string
  args: T
}

export const useWebUIMessage = <T = unknown>(name: string, handler: (data: T) => void) => {

  useEffect(() => {
    const eventListener = (event: MessageEvent<WebUIMessageData<T>>) => {
        if (!event.data || !event.data.name) return  
        const { name: eventName } = event.data

        if (eventName === name) {
            handler(event.data.args)
        }
    }

    window.addEventListener('message', eventListener)
    // Remove Event Listener on component cleanup
    return () => window.removeEventListener('message', eventListener)
  }, [])
}
export type TNotification = {
    title: string
    message: string
    type: 'success' | 'error' | 'warning' | 'info'
    duration: number
}
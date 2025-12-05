export type TNotification = {
    title: string
    message: string
    type: 'success' | 'error' | 'warning' | 'info'
    duration: number
}

export type TCharacter = {
    name: string
    citizenId: string
    level: number
    money: number
    gender: 'male' | 'female'
}

export type TPlayer = {
    name: string
    citizenId: string
}
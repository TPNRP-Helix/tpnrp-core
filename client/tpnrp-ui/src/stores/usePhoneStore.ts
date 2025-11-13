import type { TPhoneNotification } from "@/types/phone"
import { create } from "zustand"

type PhoneState = {
  isShow: boolean
  notifications: TPhoneNotification[]
  setShowPhone: (value: boolean) => void
  toggleShowPhone: () => void
  addNotification: (notification: TPhoneNotification) => void
  removeNotification: (id: string) => void
}

export const usePhoneStore = create<PhoneState>((set) => ({
  isShow: false,
  notifications: [],
  setShowPhone: (value: boolean) => set({ isShow: value }),
  toggleShowPhone: () => set((state) => ({ isShow: !state.isShow })),
  addNotification: (notification: TPhoneNotification) => set((state) => ({ notifications: [...state.notifications, notification] })),
  removeNotification: (id: string) => set((state) => ({ notifications: state.notifications.filter((notification) => notification.id !== id) })),
}))


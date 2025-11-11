import { create } from "zustand"

export type ConsoleMessage = {
  message: string
  index: number
}

type DevModeState = {
  permission: string
  isDevModeOpen: boolean
  isConsoleOpen: boolean
  isUIPreviewOpen: boolean
  consoleMessages: ConsoleMessage[]
  setDevModeOpen: (value: boolean) => void
  toggleDevMode: () => void
  setConsoleOpen: (value: boolean) => void
  toggleConsole: () => void
  appendConsoleMessage: (message: ConsoleMessage) => void
  resetConsole: () => void
  setPermission: (value: string) => void
  setUIPreviewOpen: (value: boolean) => void
}

export const useDevModeStore = create<DevModeState>((set) => ({
  permission: 'player',
  isDevModeOpen: false,
  isConsoleOpen: false,
  isUIPreviewOpen: false,
  consoleMessages: [],
  setUIPreviewOpen: (value: boolean) => set({ isUIPreviewOpen: value }),
  setDevModeOpen: (value) => set({ isDevModeOpen: value }),
  toggleDevMode: () =>
    set((state) => ({
      isDevModeOpen: !state.isDevModeOpen,
    })),
  setConsoleOpen: (value) => set({ isConsoleOpen: value }),
  toggleConsole: () =>
    set((state) => ({
      isConsoleOpen: !state.isConsoleOpen,
    })),
  appendConsoleMessage: (message) =>
    set((state) => ({
      consoleMessages: [...state.consoleMessages, message],
    })),
  resetConsole: () => set({ consoleMessages: [] }),
  setPermission: (value) => set({ permission: value }),
}))


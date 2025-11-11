
import { DevMode } from "./components/debug/DevMode"
import { HUD } from "./components/game/HUD"
import { ThemeProvider } from "./components/theme-provider"
import { Settings } from "./components/game/Settings"
import { CreateCharacter } from "./components/game/CreateCharacter"
import { ToasterController } from "./components/game/HUD/ToasterController"
import { GuideHelper } from "./components/game/GuideHelper"

declare global {
  interface Window {
    onLogMessage: (message: string, index: number) => void;
    onToggleConsole: () => void;
    hEvent: (event: string, data?: Record<string, unknown>) => void;
  }
}

function App() {
  return (
    <>
      <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
        <DevMode />
        <HUD />
        <GuideHelper />
        <Settings />
        <CreateCharacter />
        <ToasterController />
      </ThemeProvider>
    </>
  )
}

export default App

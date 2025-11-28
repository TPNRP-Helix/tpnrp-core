
import { DevMode } from "./components/debug/DevMode"
import { HUD } from "./components/game/HUD"
import { ThemeProvider } from "./components/theme-provider"
import { Settings } from "./components/game/Settings"
import { CreateCharacter } from "./components/game/CreateCharacter"
import { ToasterController } from "./components/game/HUD/ToasterController"
import { GuideHelper } from "./components/game/GuideHelper"
import { Inventory } from "./components/game/Inventory"

declare global {
  interface Window {
    hEvent: (event: string, data?: Record<string, unknown>, cb?: (result: unknown) => void) => void;
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
        <Inventory />
        <CreateCharacter />
        <ToasterController />
      </ThemeProvider>
    </>
  )
}

export default App

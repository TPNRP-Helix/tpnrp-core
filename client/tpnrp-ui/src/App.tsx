
import { DevMode } from "./components/debug/DevMode"
import { HUD } from "./components/game/HUD"
import { ThemeProvider } from "./components/theme-provider"
import { Settings } from "./components/game/Settings"
import { CreateCharacter } from "./components/game/CreateCharacter";

declare global {
  interface Window {
    onLogMessage: (message: string, index: number) => void;
    onToggleConsole: () => void;
    hEvent: (event: string) => void;
  }
}

function App() {
  return (
    <>
      <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
        <DevMode />
        <HUD />
        <Settings />
        <CreateCharacter />
      </ThemeProvider>
    </>
  )
}

export default App

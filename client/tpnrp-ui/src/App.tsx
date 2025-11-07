
import { DevMode } from "./components/debug/DevMode"
import { HUD } from "./components/game/HUD"
import { ThemeProvider } from "./components/theme-provider"

declare global {
  interface Window {
    onLogMessage: (message: string, index: number) => void;
    onToggleConsole: () => void;
  }
}

function App() {
  return (
    <>
      <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
        <DevMode />
        <HUD />
      </ThemeProvider>
    </>
  )
}

export default App

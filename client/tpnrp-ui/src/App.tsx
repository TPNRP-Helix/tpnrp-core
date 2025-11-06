
import { DevMode } from "./components/debug/DevMode"
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
      </ThemeProvider>
    </>
  )
}

export default App

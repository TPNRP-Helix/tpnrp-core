import { lazy, Suspense } from "react"
import { HUD } from "./components/game/HUD"
import { ThemeProvider } from "./components/theme-provider"
import { CreateCharacterEventListener } from "./components/game/CreateCharacter/EventListener"
// Lazy load conditionally rendered components to reduce initial bundle size
const DevMode = lazy(() => import("./components/debug/DevMode").then(module => ({ default: module.DevMode })))
const GuideHelper = lazy(() => import("./components/game/GuideHelper").then(module => ({ default: module.GuideHelper })))
const Settings = lazy(() => import("./components/game/Settings").then(module => ({ default: module.Settings })))
const Inventory = lazy(() => import("./components/game/Inventory").then(module => ({ default: module.Inventory })))
const CreateCharacter = lazy(() => import("./components/game/CreateCharacter").then(module => ({ default: module.CreateCharacter })))
const ToasterController = lazy(() => import("./components/game/HUD/ToasterController").then(module => ({ default: module.ToasterController })))

declare global {
  interface Window {
    hEvent: (event: string, data?: Record<string, unknown>, cb?: (result: any) => void) => void;
  }
}

function App() {
  return (
    <>
      <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
        <HUD />
        <CreateCharacterEventListener />
        <Suspense fallback={null}>
          <CreateCharacter />
          <DevMode />
          <GuideHelper />
          <Settings />
          <Inventory />
          <ToasterController />
        </Suspense>
      </ThemeProvider>
    </>
  )
}

export default App

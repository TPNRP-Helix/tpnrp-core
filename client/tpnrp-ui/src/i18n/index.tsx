import { createContext, useContext, useMemo } from "react"
import { useGameSettingStore } from "@/stores/useGameSetting"
import en from "@/locales/en.json"
import vi from "@/locales/vi.json"

type Translations = Record<string, string>
type LocaleMap = Record<string, Translations>

const locales: LocaleMap = {
	en,
	vi,
}

type I18nContextValue = {
	lang: string
	t: (key: string, vars?: Record<string, string | number>) => string
	availableLanguages: string[]
}

const I18nContext = createContext<I18nContextValue | null>(null)

export function I18nProvider({ children }: { children: React.ReactNode }) {
	const lang = useGameSettingStore((s) => s.language)

	const value = useMemo<I18nContextValue>(() => {
		const dictionary: Translations = locales[lang] || locales.en
		const t = (key: string, vars?: Record<string, string | number>) => {
			const raw = dictionary[key] ?? key
			if (!vars) return raw
			return Object.keys(vars).reduce((acc, k) => {
				const val = String(vars[k])
				return acc.replace(new RegExp(`{${k}}`, "g"), val)
			}, raw)
		}
		return {
			lang,
			t,
			availableLanguages: Object.keys(locales),
		}
	}, [lang])

	return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>
}

export function useI18n() {
	const ctx = useContext(I18nContext)
	if (!ctx) {
		throw new Error("useI18n must be used within I18nProvider")
	}
	return ctx
}

export function registerLocale(code: string, messages: Translations) {
	locales[code] = messages
}



import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Dialog, DialogContent, DialogDescription, DialogFooter } from "@/components/ui/dialog"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useCreateCharacterStore } from "@/stores/useCreateCharacterStore"
import { Sheet, SheetContent } from "@/components/ui/sheet"
import { useCallback, useState } from "react"
import {
    Item,
    ItemContent,
    ItemDescription,
    ItemTitle,
} from "@/components/ui/item"
import { Badge } from "@/components/ui/badge"
import { AlertCircleIcon, ChevronDownIcon, Mars, Venus } from "lucide-react"
import { FieldGroup, FieldSet, FieldLabel, Field, FieldContent, FieldTitle } from "@/components/ui/field"
import { RadioGroup } from "@/components/ui/radio-group"
import { RadioGroupItem } from "@/components/ui/radio-group"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Calendar } from "@/components/ui/calendar"
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { UnitedStateFlag } from "@/components/svg/flags/UnitedStateFlag"
import { VietnamFlag } from "@/components/svg/flags/VietnamFlag"
import { Spinner } from "@/components/ui/spinner"
import { useI18n } from "@/i18n"
import { useGameSettingStore } from "@/stores/useGameSettingStore"
import { useGameStore } from "@/stores/useGameStore"
import { Separator } from "@/components/ui/separator"
import type { TCharacter } from "@/types/game"
import { cn } from "@/lib/utils"

type TCreateCharacterResponse = {
    name: string
    citizenId: string
    level: number
    money: {
        cash: number
        bank: number
    }
    characterInfo: {
        gender: 'male' | 'female'
        birthday: string
    }
}

export const CreateCharacter = () => {
    const { t } = useI18n()
    const { language, setLanguage } = useGameSettingStore()
    const {
        isShowCreateCharacter, setShowCreateCharacter,
        isShowSelectCharacter, setShowSelectCharacter,
        maxCharacters, setMaxCharacters,
        isOpenCalendar, setIsOpenCalendar,
        dateOfBirth, setDateOfBirth,
        gender, setGender,
        firstName, setFirstName,
        lastName, setLastName,
        playerCharacters, setPlayerCharacters,
    } = useCreateCharacterStore()
    
    const [error, setError] = useState<{ type: string, message: string } | null>(null)
    const [selectedCitizenId, setSelectedCitizenId] = useState<string>('')
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [isShowConfirmDeleteCharacter, setIsShowConfirmDeleteCharacter] = useState(false)
    const { toggleHud, setIsInGame, setShowLoading } = useGameStore()
    
    useWebUIMessage<[number, unknown[]]>('setPlayerCharacters', ([maxCharacters, characters]) => {
        // Set max characters
        setMaxCharacters(maxCharacters)
        // Format characters
        const formattedCharacters: TCharacter[] = Object.entries(characters).map(([_, value]: [string, any]) => {
            return {
                name: value.name,
                citizenId: value.citizenId,
                level: parseInt(value.level) ?? 1,
                money: parseInt(value.money) ?? 0,
                gender: value.gender,
            }
        })
        setPlayerCharacters(formattedCharacters)
        // Show Select Character Sheet
        setShowSelectCharacter(true)
        setShowLoading(false)
        setIsInGame(true)
    })

    useWebUIMessage<[TCreateCharacterResponse]>('onCreateCharacterSuccess', ([playerData]) => {
        // Set preview character info
        setPlayerCharacters([...playerCharacters, {
            name: playerData?.name ?? '',
            citizenId: playerData?.citizenId ?? 'ERR',
            level: playerData?.level ?? 1,
            money: playerData?.money?.cash ?? 0,
            gender: playerData?.characterInfo?.gender ?? 'male',
        }])
        // Hide create character dialog
        setShowCreateCharacter(false)
        // Show Select Character Sheet
        setShowSelectCharacter(true)
    })

    useWebUIMessage<[TCreateCharacterResponse]>('joinGameSuccess', ([playerData]) => {
        // Hide Select Character
        setShowSelectCharacter(false)
        // Hide Create Character Dialog
        setShowCreateCharacter(false)
        // Enable main HUD
        toggleHud()
        // Enable in-game Guide 
        setIsInGame(true)
    })

    const onClickCreateCharacter = useCallback(() => {
        setShowSelectCharacter(false)
        setShowCreateCharacter(true)
    }, [setShowCreateCharacter, setShowSelectCharacter])

    const onSubmitCreateCharacter = useCallback(() => {
        if (isSubmitting) {
            return
        }
        setIsSubmitting(true)
        if (!firstName || firstName.trim() === '') {
            console.log(t('error.firstNameRequired'), firstName)
            setError({ type: 'firstName', message: t('error.firstNameRequired') })
            setIsSubmitting(false)
            return
        }
        if (!lastName || lastName.trim() === '') {
            setError({ type: 'lastName', message: t('error.lastNameRequired') })
            setIsSubmitting(false)
            return
        }
        if (!dateOfBirth) {
            setError({ type: 'dateOfBirth', message: t('error.dobRequired') })
            setIsSubmitting(false)
            return
        }
        window.hEvent('createCharacter', {
            firstName,
            lastName,
            gender,
            dateOfBirth,
        })
    }, [firstName, lastName, dateOfBirth, gender, isSubmitting])

    const onClickJoinGame = useCallback(() => {
        const isInBrowser = window.location.port === '5173'
        if (isInBrowser) {
            // Hide Select Character
            setShowSelectCharacter(false)
            // Hide Create Character Dialog
            setShowCreateCharacter(false)
            // Enable main HUD
            toggleHud()
            // Enable in-game Guide 
            setIsInGame(true)
        }
        window.hEvent('joinGame', { citizenId: selectedCitizenId })
    }, [selectedCitizenId])

    const onClickDeleteCharacter = useCallback(() => {
        // TODO: Delete character
        const isInBrowser = window.location.port === '5173'
        if (isInBrowser) {
            setPlayerCharacters(playerCharacters.filter((character) => character.citizenId !== selectedCitizenId))
        }
        setIsShowConfirmDeleteCharacter(false)
        setSelectedCitizenId('')
        window.hEvent('deleteCharacter', { citizenId: selectedCitizenId })
    }, [selectedCitizenId])
    
    return (
        <>
            <Sheet open={isShowSelectCharacter} onOpenChange={setShowSelectCharacter}>
                <SheetContent
                    onInteractOutside={(e) => e.preventDefault()}
                    onEscapeKeyDown={(e) => e.preventDefault()}
                    isShowOverlay={false}
                    side="left"
                    isShowCloseButton={false}
                    title={t("selectCharacter.title")}
                >
                    <div className="grid gap-4 p-4">
                        {Array.from({ length: maxCharacters }).map((_, index) => {
                            const character = playerCharacters[index] ?? null

                            return (
                                <Item
                                    variant='muted'
                                    key={`character-${index}`}
                                    className={cn('relative rounded [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!',
                                    {
                                        'bg-primary/10': selectedCitizenId === character?.citizenId,
                                        'cursor-pointer': character?.citizenId !== '',
                                    })}
                                    style={{ overflow: 'initial !important' }}
                                    onClick={() => setSelectedCitizenId(character?.citizenId ?? '')}
                                >
                                    <ItemContent>
                                        <ItemTitle>
                                            {character ? (
                                                <>
                                                    {character.name}
                                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums">Lv.{character.level}</Badge>
                                                    <Badge variant="secondary" className="h-5 min-w-5 rounded-full px-1 font-mono tabular-nums bg-blue-500">
                                                        {character.gender === 'male' ? <Mars className="size-4" /> : <Venus className="size-4" />}
                                                    </Badge>
                                                    
                                                </>
                                            ) : (
                                                <>{t("selectCharacter.emptySlot", { n: index + 1 })}</>
                                            )}
                                        </ItemTitle>
                                        <ItemDescription>
                                            {character ? (
                                                <ul>
                                                    <li>{t("selectCharacter.citizenId")}: {character.citizenId}</li>
                                                    <li>{t("selectCharacter.money")}: ${character.money}</li>
                                                </ul>
                                            ) : <>{t("selectCharacter.createNew")}</>}
                                        </ItemDescription>
                                    </ItemContent>
                                </Item>
                            )
                        })}
                        <Separator className="mt-2" />
                        <div className="flex flex-row items-center justify-center gap-2">
                            {selectedCitizenId === '' ? (
                                <>
                                    <Button className="w-full" variant="default" size="sm" onClick={onClickCreateCharacter}>
                                        {t("selectCharacter.create")}
                                    </Button>
                                </>
                            ) : (
                                <>
                                    <Button
                                        variant="secondary" size="sm" className="w-1/2"
                                        onClick={() => setIsShowConfirmDeleteCharacter(true)}
                                        disabled={selectedCitizenId === ''}
                                    >
                                        {t("selectCharacter.delete")}
                                    </Button>
                                    <Button
                                        variant="default" size="sm" className="w-1/2"
                                        onClick={() => onClickJoinGame()}
                                        disabled={selectedCitizenId === ''}
                                    >
                                        {t("selectCharacter.join")}
                                    </Button>
                                </>
                            )}
                        </div>
                        <Separator className="mt-2" />
                        <Alert>
                            <AlertCircleIcon />
                            <AlertTitle>{t("selectCharacter.infoTitle")}</AlertTitle>
                            <AlertDescription>
                                <p>{t("selectCharacter.infoDesc")}</p>
                            </AlertDescription>
                        </Alert>
                        <div className="absolute bottom-4 left-4">
                            <Select value={language} onValueChange={(val) => setLanguage(val)}>
                                <SelectTrigger className="w-[180px]">
                                    <SelectValue placeholder={t("selectCharacter.language.placeholder")} />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectGroup>
                                        <SelectItem value="en"> <UnitedStateFlag /> English</SelectItem>
                                        <SelectItem value="vi"> <VietnamFlag /> Tiếng Việt</SelectItem>
                                    </SelectGroup>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                </SheetContent>
            </Sheet>
            {/* Create Character Dialog */}
            <Dialog open={isShowCreateCharacter} onOpenChange={(isOpen) => {
                setShowCreateCharacter(isOpen)
                if (!isOpen) {
                    setShowSelectCharacter(true)
                }
            }}>
                <form onSubmit={onSubmitCreateCharacter}>
                    <DialogContent className="sm:max-w-[425px]" title={t("createCharacter.title")}>
                        <div className="grid gap-4 p-4">
                            <DialogDescription>
                                {t("createCharacter.description")}
                            </DialogDescription>
                            <div className="flex gap-2">
                                <div className="grid gap-3 w-full">
                                    <Label htmlFor="firstName">{t("createCharacter.firstName")}</Label>
                                    <Input id="firstName" name="firstName" value={firstName} onChange={(e) => {
                                        setFirstName(e.target.value)
                                        setError(null)
                                    }} />
                                </div>
                                <div className="grid gap-3 w-full">
                                    <Label htmlFor="lastName">{t("createCharacter.lastName")}</Label>
                                    <Input id="lastName" name="lastName" value={lastName} onChange={(e) => {
                                        setLastName(e.target.value)
                                        setError(null)
                                    }} />
                                </div>
                            </div>
                            {error && (error.type === 'firstName' || error.type === 'lastName') && (
                                <Alert variant="destructive">
                                    <AlertCircleIcon />
                                    <AlertTitle>{error.message}</AlertTitle>
                                </Alert>
                            )}
                            <FieldGroup>
                                <FieldSet>
                                    <FieldLabel htmlFor="compute-environment-p8w">
                                        {t("createCharacter.gender")}
                                    </FieldLabel>
                                    <RadioGroup
                                        className="flex gap-2"
                                        value={gender}
                                        name="gender"
                                        onValueChange={(value) => setGender(value as 'male' | 'female')}
                                    >
                                        <FieldLabel htmlFor="male">
                                            <Field orientation="horizontal">
                                                <FieldContent>
                                                    <FieldTitle> <Mars className="size-4" /> {t("createCharacter.gender.male")}</FieldTitle>
                                                </FieldContent>
                                                <RadioGroupItem value="male" id="male" />
                                            </Field>
                                        </FieldLabel>
                                        <FieldLabel htmlFor="female">
                                            <Field orientation="horizontal">
                                                <FieldContent>
                                                    <FieldTitle> <Venus className="size-4" /> {t("createCharacter.gender.female")}</FieldTitle>
                                                </FieldContent>
                                                <RadioGroupItem value="female" id="female" />
                                            </Field>
                                        </FieldLabel>
                                    </RadioGroup>
                                </FieldSet>
                            </FieldGroup>
                            <div className="flex flex-col gap-3">
                                <Label htmlFor="date" className="px-1">
                                    {t("createCharacter.dob")}
                                </Label>
                                <Popover open={isOpenCalendar} onOpenChange={setIsOpenCalendar}>
                                    <PopoverTrigger asChild>
                                    <Button
                                        variant="secondary"
                                        id="date"
                                        className="w-full justify-between font-normal"
                                    >
                                        {dateOfBirth ? dateOfBirth.toLocaleDateString() : t("createCharacter.selectDate")}
                                        <ChevronDownIcon />
                                    </Button>
                                    </PopoverTrigger>
                                    <PopoverContent className="w-auto overflow-hidden p-0" align="start">
                                    <Calendar
                                        mode="single"
                                        selected={dateOfBirth}
                                        captionLayout="dropdown"
                                        onSelect={(date) => {
                                            setDateOfBirth(date)
                                            setIsOpenCalendar(false)
                                            setError(null)
                                        }}
                                    />
                                    </PopoverContent>
                                </Popover>
                            </div>
                            {error && (error.type === 'dateOfBirth') && (
                                <Alert variant="destructive">
                                    <AlertCircleIcon />
                                    <AlertTitle>{error.message}</AlertTitle>
                                </Alert>
                            )}
                        </div>
                        <DialogFooter>
                            <Button variant="secondary" type="reset" disabled={isSubmitting}>{t("createCharacter.reset")}</Button>
                            <Button type="submit" disabled={isSubmitting} onClick={(e) => {
                                e.preventDefault()
                                onSubmitCreateCharacter()
                            }}>{isSubmitting ? (
                                <>
                                    <Spinner /> {t("createCharacter.submitting")}
                                </>
                            ) : (
                                t("createCharacter.submit")
                            )}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </form>
            </Dialog>
            <Dialog open={isShowConfirmDeleteCharacter} onOpenChange={setIsShowConfirmDeleteCharacter}>
                <DialogContent
                className="outline-none! w-[400px]"
                showCloseButton={false}
                title={t("selectCharacter.delete")}
                onInteractOutside={(e) => e.preventDefault()}
                aria-describedby={undefined}
                >
                    <div className="flex flex-row items-center justify-center py-8 px-4 gap-2">
                        {t("selectCharacter.deleteConfirmDesc", { citizenId: selectedCitizenId })}
                    </div>
                    <DialogFooter>
                        <Button variant="secondary" size="sm" onClick={() => setIsShowConfirmDeleteCharacter(false)}>
                            {t("selectCharacter.cancel")}
                        </Button>
                        <Button variant="destructive" size="sm" onClick={() => onClickDeleteCharacter()}>
                            {t("selectCharacter.delete")}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </>
    )
}

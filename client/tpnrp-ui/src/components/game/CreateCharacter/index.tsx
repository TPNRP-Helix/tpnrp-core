import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { useWebUIMessage } from "@/hooks/use-hevent"
import { useCreateCharacterStore } from "@/stores/useCreateCharacterStore"
import { useDevModeStore } from "@/stores/useDevModeStore"
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import { useCallback, useState } from "react"
import {
    Item,
    ItemActions,
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
import { Select, SelectContent, SelectGroup, SelectItem, SelectLabel, SelectTrigger, SelectValue } from "@/components/ui/select"
import { UnitedStateFlag } from "@/components/svg/flags/UnitedStateFlag"
import { VietnamFlag } from "@/components/svg/flags/VietnamFlag"
import { Spinner } from "@/components/ui/spinner"

type TCharacter = {
    name: string
    citizenId: string
    level: number
    money: number
    gender: 'male' | 'female'
}

export const CreateCharacter = () => {
    const { appendConsoleMessage } = useDevModeStore()
    const {
        isShowCreateCharacter,
        isShowSelectCharacter,
        setShowCreateCharacter,
        setShowSelectCharacter,
        maxCharacters,
        setMaxCharacters,
        isOpenCalendar,
        setIsOpenCalendar,
        dateOfBirth,
        setDateOfBirth,
        gender,
        setGender,
        firstName,
        setFirstName,
        lastName,
        setLastName,
    } = useCreateCharacterStore()
    
    const [playerCharacters, setPlayerCharacters] = useState<TCharacter[]>([])
    const [isSubmitting, setIsSubmitting] = useState(false)

    useWebUIMessage<[{ maxCharacters: number, characters: unknown[] }]>('setPlayerCharacters', ([{ maxCharacters, characters }]) => {
        // TPN Log
        appendConsoleMessage({ message: `Max char: ${maxCharacters} - characters ${JSON.stringify(characters)}`, index: 0 })

        // Set max characters
        setMaxCharacters(maxCharacters)
        // Format characters
        const formattedCharacters: TCharacter[] = Object.entries(characters).map(([_, value]: [string, any]) => {
            return {
                name: value.name,
                citizenId: value.citizenId,
                level: parseInt(value.level) ?? 1,
                money: parseInt(value.money) ?? 0,
                gender: value.gender === 1 ? 'male' : 'female',
            }
        })
        setPlayerCharacters(formattedCharacters)
        // Show Select Character Sheet
        setShowSelectCharacter(true)
    })

    const onClickCreateCharacter = useCallback(() => {
        setShowSelectCharacter(false)
        setShowCreateCharacter(true)
    }, [setShowCreateCharacter, setShowSelectCharacter])

    const onSubmitCreateCharacter = useCallback((e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        console.log('submit')
    }, [])
    
    return (
        <>
            <Sheet open={isShowSelectCharacter} onOpenChange={setShowSelectCharacter}>
                <SheetContent
                    onInteractOutside={(e) => e.preventDefault()}
                    onEscapeKeyDown={(e) => e.preventDefault()}
                    isShowOverlay={false}
                    side="left"
                    isShowCloseButton={false}
                >
                    <SheetHeader>
                        <SheetTitle>Select Character</SheetTitle>
                    </SheetHeader>
                    <div className="grid gap-4 p-4">
                        {Array.from({ length: maxCharacters }).map((_, index) => {
                            const character = playerCharacters[index] ?? null

                            return (
                                <Item variant='muted' key={`character-${index}`} className="rounded [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!">
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
                                                <>{`Empty slot ${index + 1}`}</>
                                            )}
                                        </ItemTitle>
                                        <ItemDescription>
                                            {character ? (
                                                <ul>
                                                    <li>Citizen ID: {character.citizenId}</li>
                                                    <li>Money: ${character.money}</li>
                                                </ul>
                                            ) : <>Create new character</>}
                                        </ItemDescription>
                                    </ItemContent>
                                    <ItemActions className="opacity-0 group-hover/item:opacity-100 transition-opacity">
                                        {character ? (
                                            <Button variant="default" size="sm">
                                                Join
                                            </Button>
                                        ) : (
                                            <Button variant="default" size="sm" onClick={onClickCreateCharacter}>
                                                Create
                                            </Button>
                                        )}
                                    </ItemActions>
                                </Item>
                            )
                        })}
                        <Alert>
                            <AlertCircleIcon />
                            <AlertTitle>Info</AlertTitle>
                            <AlertDescription>
                                <p>Select your character or create a new one to start your journey.</p>
                            </AlertDescription>
                        </Alert>
                        <div className="absolute bottom-4 left-4">
                            <Select>
                                <SelectTrigger className="w-[180px]">
                                    <SelectValue placeholder="Select Language" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectGroup>
                                        <SelectItem value="en"> <UnitedStateFlag /> English</SelectItem>
                                        <SelectItem value="vi"> <VietnamFlag /> Vietnamese</SelectItem>
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
                    <DialogContent className="sm:max-w-[425px] ">
                        <DialogHeader>
                            <DialogTitle>Create Character</DialogTitle>
                            <DialogDescription>
                                Create a new character to start your journey.
                            </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 p-4">
                            <div className="flex gap-2">
                                <div className="grid gap-3 w-full">
                                    <Label htmlFor="firstName">First Name</Label>
                                    <Input id="firstName" name="firstName" defaultValue="" />
                                </div>
                                <div className="grid gap-3 w-full">
                                    <Label htmlFor="lastName">Last Name</Label>
                                    <Input id="lastName" name="lastName" defaultValue="" />
                                </div>
                            </div>
                            <FieldGroup>
                                <FieldSet>
                                    <FieldLabel htmlFor="compute-environment-p8w">
                                        Gender
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
                                                    <FieldTitle> <Mars className="size-4" /> Male</FieldTitle>
                                                </FieldContent>
                                                <RadioGroupItem value="male" id="male" />
                                            </Field>
                                        </FieldLabel>
                                        <FieldLabel htmlFor="female">
                                            <Field orientation="horizontal">
                                                <FieldContent>
                                                    <FieldTitle> <Venus className="size-4" /> Female</FieldTitle>
                                                </FieldContent>
                                                <RadioGroupItem value="female" id="female" />
                                            </Field>
                                        </FieldLabel>
                                    </RadioGroup>
                                </FieldSet>
                            </FieldGroup>
                            <div className="flex flex-col gap-3">
                                <Label htmlFor="date" className="px-1">
                                    Date of birth
                                </Label>
                                <Popover open={isOpenCalendar} onOpenChange={setIsOpenCalendar}>
                                    <PopoverTrigger asChild>
                                    <Button
                                        variant="secondary"
                                        id="date"
                                        className="w-full justify-between font-normal"
                                    >
                                        {dateOfBirth ? dateOfBirth.toLocaleDateString() : "Select date"}
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
                                        }}
                                    />
                                    </PopoverContent>
                                </Popover>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="secondary" type="reset" disabled={isSubmitting}>Reset</Button>
                            <Button type="submit" disabled={isSubmitting}>{isSubmitting ? <>
                                <Spinner /> Creating...
                            </> : 'Create'} </Button>
                        </DialogFooter>
                    </DialogContent>
                </form>
            </Dialog>
        </>
    )
}

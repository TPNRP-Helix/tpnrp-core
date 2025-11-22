SHARED.CONFIG = {
    LANGUAGE = 'en',
    BASE_EXP = 100, -- Base experience for level 1
    MULTIPLIER = {
        LEVEL = 1, -- Level experience multiplier 
        SKILL = 1, -- Skill level experience multiplier
    },
    UPDATE_INTERVAL = 5, -- Update interval in minutes
    BASIC_NEEDS = {
        HUNGER_RATE = 5, -- Hunger rate
        THIRST_RATE = 4, -- Thirst rate
    },
    MAX_CHARACTERS = 5, -- Maximum number of characters per player
    PERMISSIONS = {
        [1] = {
            role = 'admin',
            license = '7c463225-264c-4bf3-bc9a-cbd74938e5f6' -- Leopold
        }
    },
    NEWBIE_INVENTORY = {'id_card', 'phone'},
    INVENTORY_CAPACITY = {
        WEIGHT = 15000, -- Weight in grams
        SLOTS = 5, -- Slots count
    },
}
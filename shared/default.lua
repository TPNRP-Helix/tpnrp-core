local DEFAULT_POSITION = { x = -274.27, y = 6641.01, z = 7.45 }
local DEFAULT_HEADING = 270.0

SHARED.DEFAULT = {
    SPAWN = {
        POSITION = DEFAULT_POSITION,
        HEADING = DEFAULT_HEADING,
    },
    LEVEL = 1,
    SKILLS = {
        miner = {
            level = 1,
            exp = 0
        },       -- Miner
        lumberjack = {
            level = 1,
            exp = 0
        },  -- Lumberjack
        fisherman = {
            level = 1,
            exp = 0
        },   -- Fisherman
        butcher = {
            level = 1,
            exp = 0
        },     -- Butcher
        herbalism = {
            level = 1,
            exp = 0
        },   -- Herbalism
        farmer = {
            level = 1,
            exp = 0
        },      -- Farmer
        tailor = {
            level = 1,
            exp = 0
        },      -- Tailor
        cooking = {
            level = 1,
            exp = 0
        },      -- Cooking
        furnacing = {
            level = 1,
            exp = 0
        },      -- Furnacing
        crafting = {
            level = 1,
            exp = 0
        },      -- Crafting
    },
    PLAYER = {
        money = {
            cash = 0,
            bank = 0,
        },
        character_info = {
            firstName = '',
            lastName = '',
            gender = '',
            birthday = ''
        },
        job = {
            name = '',
            grade = 0,
        },
        gang = {},
        position = DEFAULT_POSITION,
        heading = DEFAULT_HEADING,
        metadata = {
            hunger = 100,
            thirst = 100,
            health = 100,
            armor = 0,
            stamina = 100,
            isDead = false
        },
    }
}
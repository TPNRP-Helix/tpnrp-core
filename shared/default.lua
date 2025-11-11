SHARED.DEFAULT = {
    SPAWN = {
        POSITION = { x = -274.27, y = 6641.01, z = 7.45 },
        HEADING = 270.0,
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
        position = SHARED.DEFAULT.SPAWN.POSITION,
        heading = SHARED.DEFAULT.SPAWN.HEADING,
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
/**
-- HELIX Client 
TriggerCallback('callbackName', function(result)
    print(result)
end, arg1, arg2)

-- HELIX Server
RegisterCallback('callbackName', function(source, arg1, arg2)
    return returnValue
end)

**/

SHARED.CONFIG = {
    LANGUAGE = 'en',
    DEFAULT_SPAWN = {
        POSITION = { x = -274.27, y = 6641.01, z = 7.45 },
        HEADING = 270.0,
    },
    INVENTORY = {
        WEIGHT_LIMIT = 80000, -- 80kg
        SLOTS = 64,
    },
}
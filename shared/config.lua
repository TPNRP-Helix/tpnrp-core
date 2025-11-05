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
    BASE_EXP = 100, -- Base experience for level 1
    MULTIPLIER = {
        LEVEL = 1, -- Level multiplier 
        SKILL = 1, -- Skill level multiplier
    },
}
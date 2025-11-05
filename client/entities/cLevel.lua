---@class CLevel
---@field player CPlayer player entity
CLevel = {}
CLevel.__index = CLevel

---@param player CPlayer player entity
---@return CLevel
function CLevel.new(player)
    ---@class CLevel
    local self = setmetatable({}, CLevel)

    self.player = player
    self.level = SHARED.DEFAULT.LEVEL
    self.exp = 0
    self.skills = SHARED.DEFAULT.SKILLS

    /********************************/
    /*         Initializes          */
    /********************************/

    ---Contructor function
    local function _contructor()
        -- On sync level
        RegisterClientEvent('TPN:level:sync', function(type, name, newExp, expGain, isLevelUp, levelPercent)
            self:onSyncLevel(type, name, newExp, expGain, isLevelUp, levelPercent)
        end)
    end


    /********************************/
    /*          Functions           */
    /********************************/
    
    -- On sync level
    ---@param type 'add' | 'remove' level type
    ---@param name string skill name
    ---@param newExp number new experience
    ---@param expGain number experience gain
    ---@param isLevelUp boolean is level up
    ---@param levelPercent number level percent
    function self:onSyncLevel(type, name, newExp, expGain, isLevelUp, levelPercent)
        if name == '' then
            -- Update level
            self.exp = newExp
            if isLevelUp then
                self.level = self.level + 1
            end
            self.levelPercent = levelPercent
        else
            -- Update skill level
            self.skills[name].exp = newExp
            if isLevelUp then
                self.skills[name].level = self.skills[name].level + 1
            end
        end
        -- Update UI for level changes
        TPNRPUI:SendEvent('LEVEL_EXP_GAIN', {
            type = type,
            name = name,
            expGain = expGain,
            isLevelUp = isLevelUp,
            levelPercent = levelPercent
        })
    end

    _contructor()
    ---- END ----
    return self
end

return CLevel
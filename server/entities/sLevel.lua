---@class SLevel
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment SEquipment|nil
SLevel = {}
SLevel.__index = SLevel

---@return SLevel
function SLevel.new(playerController)
    ---@class SLevel
    local self = setmetatable({}, SLevel)

    -- Player's controller
    self.playerController = playerController
    -- Current player level
    self.level = SHARED.DEFAULT.LEVEL
    -- Current player experience
    self.exp = 0
    -- Skills data
    self.skills = SHARED.DEFAULT.SKILLS

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        -- Get level by citizen id
        local levelData = DAO.level.get(self.playerController.playerData.citizen_id)
        -- Assign level data
        self.level = levelData.level or SHARED.DEFAULT.LEVEL
        self.exp = levelData.exp or 0
        self.skills = levelData.skills or SHARED.DEFAULT.SKILLS
    end

    ---/********************************/
    ---/*           Player             */
    ---/********************************/

    ---Save player
    ---@return boolean success is save success or not
    function self:save()
        return DAO.level.save(self)
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Get required experience for a level
    ---@param level number level
    ---@return number number required experience
    function self:getRequiredExpForLevel(level)
        if level <= 1 then return 0 end
        return math.floor(SHARED.CONFIG.BASE_EXP * (SHARED.CONFIG.MULTIPLIER.LEVEL ^ (level - 1)))
    end

    ---Calculate level percent
    ---@param exp number experience
    ---@param level number current level
    ---@return number level percent
    function self:calculateLevelPercent(exp, level)
        local currentLevelBeginExp = self:getRequiredExpForLevel(level)
        local nextLevelExp = self:getRequiredExpForLevel(level + 1)
        -- Calculate total level experience
        local totalLevelExp = nextLevelExp - currentLevelBeginExp
        local currentLevelExp = exp - currentLevelBeginExp
        -- Calculate level percent
        return (currentLevelExp / totalLevelExp) * 100
    end

    ---Add experience
    ---@param exp number experience
    function self:addExp(exp)
        local isLevelUp = false
        local nextLevelExp = self:getRequiredExpForLevel(self.level + 1)
        local expGain = exp * SHARED.CONFIG.MULTIPLIER.EXP
        local newExp = self.exp + expGain
        -- Check if level up
        if newExp >= nextLevelExp then
            self.level = self.level + 1
            isLevelUp = true
            -- Boardcast event levelUp to all other server's script
            TriggerLocalServerEvent('TPN:level:onLevelUp', self.playerData.citizen_id, 'level', self.level)
        end
        -- Assign new experience
        self.exp = newExp
        local levelPercent = self:calculateLevelPercent(newExp, self.level)
        -- Sync exp to client
        TriggerClientEvent(self.playerController, 'TPN:level:sync', 'add', '', newExp, expGain, isLevelUp, levelPercent)
    end

    ---Add skill experience
    ---@param skillName string skill name
    ---@param exp number experience
    function self:addSkillExp(skillName, exp)
        local isSkillLevelUp = false
        local nextSkillLevelExp = self:getRequiredExpForLevel(self.skills[skillName].level + 1)
        local skillExpGain = exp * SHARED.CONFIG.MULTIPLIER.SKILL
        local newSkillExp = self.skills[skillName].exp + skillExpGain
        -- Check if skill level up
        if newSkillExp >= nextSkillLevelExp then
            self.skills[skillName].level = self.skills[skillName].level + 1
            isSkillLevelUp = true
            -- Boardcast event levelUp to all other server's script
            TriggerLocalServerEvent('TPN:level:onLevelUp', self.playerData.citizen_id, skillName, self.skills[skillName].level)
        end
        -- Assign new skill experience
        self.skills[skillName].exp = newSkillExp
        local skillPercent = self:calculateLevelPercent(newSkillExp, self.skills[skillName].level)
        -- Sync skill exp to client
        TriggerClientEvent(self.playerController, 'TPN:level:sync', 'add', skillName, newSkillExp, skillExpGain, isSkillLevelUp, skillPercent)
    end

    _contructor()
    ---- END ----
    return self
end

return SLevel

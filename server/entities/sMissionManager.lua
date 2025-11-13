---@class SMissionManager
---@field core TPNRPServer core entity
---@field player SPlayer player entity
SMissionManager = {}
SMissionManager.__index = SMissionManager

---@param player SPlayer player entity
---@return SMissionManager
function SMissionManager.new(player)
    ---@class SMissionManager
    local self = setmetatable({}, SMissionManager)
    
    -- Core
    self.core = player.core
    -- Player entity
    self.player = player
    ---@type TMissionEntity[]
    self.missions = {}

    ---@type string|nil active mission name
    self.activeMissionName = nil

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
       local missions = DAO.mission.get(self.player.playerData.citizenId)
       if not missions then return end
       self.missions = missions
       -- Find active mission
       for _, mission in pairs(missions) do
        if mission.isActive then
            self.activeMissionName = mission.id
        end
       end

       self:bindTPNEvents()
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    ---Save missions
    ---@return boolean success
    function self:save()
        return DAO.mission.save(self.player)
    end

    ---Bind TPN events
    function self:bindTPNEvents()
      
    end

    ---Trigger an action to update mission required
    ---@param actionName TMissionActionType action name 
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    function self:triggerAction(actionName, data)
        -- Get current mission
        local currentMission = self:getCurrentActiveMission()
        -- Failed to get mission
        if not currentMission then return false end
        -- Get mission data
        local missionData = self:getMissionData(currentMission.id)
        -- Failed to get mission data
        if not missionData then return false end
        for _, requirement in pairs(missionData.requirements) do
            if requirement.type == actionName then
                return self:updateActiveMissionProgress(requirement, data)
            end
        end
        -- Update failed
        return false
    end

    ---Get current active mission
    ---@return TMissionEntity|nil current active mission
    function self:getCurrentActiveMission()
        if not self.activeMissionName then return nil end
        -- Return current mission by activeMissionName
        return self.missions[self.activeMissionName] or nil
    end

    ---Get mission data
    ---@param missionName string mission name
    ---@return TMissionData|nil mission data
    function self:getMissionData(missionName)
        return SHARED.missions[missionName] or nil
    end

    ---Set current active mission
    ---@param missionName string mission name
    function self:setActiveMission(missionName)
        self.activeMissionName = missionName
    end

    ---/********************************/
    ---/*            Local             */
    ---/********************************/

    ---[PRIVATE] Initialize and increment progress amount
    ---@param progress TMissionProgress progress entry
    ---@param increment number amount to increment
    local function incrementProgressAmount(progress, increment)
        if not progress.currentAmount then
            progress.currentAmount = 0
        end
        progress.currentAmount = progress.currentAmount + increment
    end

    ---[PRIVATE] Validate and update item-based progress (buy, sell, drop, craft, use)
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    ---@return boolean success
    local function updateItemProgress(progress, requirement, data)
        if not requirement.name or progress.name ~= requirement.name then
            return false
        end
        if not data.amount or type(data.amount) ~= 'number' or data.amount <= 0 then
            return false
        end
        incrementProgressAmount(progress, data.amount)
        return true
    end

    ---[PRIVATE] Validate and update NPC take item progress
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    ---@return boolean success
    local function updateNpcTakeItemProgress(progress, requirement, data)
        if not requirement.npcName or not data.npcName or requirement.npcName ~= data.npcName then
            return false
        end
        incrementProgressAmount(progress, data.amount or 1)
        return true
    end

    ---[PRIVATE] Validate and update NPC kill progress
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    ---@return boolean success
    local function updateKillNpcProgress(progress, requirement, data)
        if not requirement.npcName or not data.npcName or requirement.npcName ~= data.npcName then
            return false
        end
        incrementProgressAmount(progress, 1)
        return true
    end

    ---[PRIVATE] Validate and update NPC talk progress
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    ---@return boolean success
    local function updateTalkNpcProgress(progress, requirement, data)
        if not requirement.npcName or not data.npcName or requirement.npcName ~= data.npcName then
            return false
        end
        incrementProgressAmount(progress, 1)
        progress.isTalkedToNPC = true
        return true
    end

    ---[PRIVATE] Validate and update money progress
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    ---@return boolean success
    local function updateMoneyProgress(progress, requirement, data)
        if not requirement.type or requirement.type ~= 'spend' or requirement.type ~= 'receive' then
            return false
        end
        if not data.amount or type(data.amount) ~= 'number' or data.amount <= 0 then
            return false
        end
        incrementProgressAmount(progress, data.amount)
        return true
    end

    ---[PRIVATE] Check if progress entry matches requirement
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@return boolean matches
    local function progressMatchesRequirement(progress, requirement)
        if progress.type ~= requirement.type then
            return false
        end
        
        if requirement.name and progress.name ~= requirement.name then
            return false
        end
        
        if requirement.npcName and progress.npcName ~= requirement.npcName then
            return false
        end
        
        return true
    end

    ---[PRIVATE] Check if a requirement is met by progress
    ---@param progress TMissionProgress progress entry
    ---@param requirement TMissionRequirement requirement
    ---@return boolean isMet
    local function isRequirementMet(progress, requirement)
        if requirement.type == 'talk_npc' then
            return progress.isTalkedToNPC or false
        end
        
        local requiredAmount = requirement.amount or 1
        local currentAmount = progress.currentAmount or 0
        return currentAmount >= requiredAmount
    end

    ---Action type handlers lookup table
    local actionHandlers = {
        buy = updateItemProgress,
        sell = updateItemProgress,
        drop = updateItemProgress,
        craft = updateItemProgress,
        use = updateItemProgress,
        kill_npc = updateKillNpcProgress,
        talk_npc = updateTalkNpcProgress,
        npc_take_item = updateNpcTakeItemProgress,
        add_item = updateItemProgress,
        remove_item = updateItemProgress,
        spend = updateMoneyProgress,
        receive = updateMoneyProgress,
    }

    ---/********************************/
    ---/*          Missions            */
    ---/********************************/

    ---Update mission progress
    ---@param requirement TMissionRequirement requirement
    ---@param data {npcName:string|nil; amount:number|nil; name:string|nil} data
    ---@return boolean success is update success or not
    function self:updateActiveMissionProgress(requirement, data)
        if not data then return false end
        
        local currentMission = self:getCurrentActiveMission()
        if not currentMission then return false end
        
        local handler = actionHandlers[requirement.type]
        if not handler then return false end
        
        for _, progress in pairs(currentMission.progress) do
            if progress.type == requirement.type then
                if handler(progress, requirement, data) then
                    return true
                end
            end
        end
        
        return false
    end

    ---Check if current active mission is completed
    ---@return boolean isCompleted
    function self:checkMissionCompleted()
        local currentMission = self:getCurrentActiveMission()
        if not currentMission then return false end
        
        local missionData = self:getMissionData(currentMission.id)
        if not missionData then return false end
        
        for _, requirement in pairs(missionData.requirements) do
            local requirementMet = false
            
            for _, progress in pairs(currentMission.progress) do
                if progressMatchesRequirement(progress, requirement) then
                    if isRequirementMet(progress, requirement) then
                        requirementMet = true
                        break
                    end
                end
            end
            
            if not requirementMet then
                return false
            end
        end
        
        return true
    end

    ---Get mission reward
    ---@return TMissionReward[]|nil mission reward
    function self:getMissionReward()
        local currentMission = self:getCurrentActiveMission()
        if not currentMission then return nil end
        
        local missionData = self:getMissionData(currentMission.id)
        if not missionData then return nil end
        
        return missionData.rewards or nil
    end

    ---Give player reward
    ---@return boolean success
    function self:givePlayerReward()
        local reward = self:getMissionReward()
        if not reward then return false end

        for _, reward in pairs(reward) do
            if reward.type == 'item' then
                self.player.inventory:addItem(reward.name, reward.amount, nil, reward.info)
            elseif reward.type == 'cash' then
                self.player:addMoney('cash', reward.amount)
            elseif reward.type == 'bank' then
                self.player:addMoney('bank', reward.amount)
            elseif reward.type == 'exp' then
                self.player.level:addExp(reward.exp)
            elseif reward.type == 'skill' then
                self.player.level:addSkillExp(reward.name, reward.exp)
            end
        end
        -- Sync player data to client
        self.player:updatePlayerData()
        return true
    end

    _contructor()
    ---- END ----
    return self
end

return SMissionManager


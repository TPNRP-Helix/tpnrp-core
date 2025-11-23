---@class SNPCManager
---@field core TPNRPServer core entity
SNPCManager = {}
SNPCManager.__index = SNPCManager

---@return SNPCManager
---@param core TPNRPServer core entity
function SNPCManager.new(core)
    ---@class SNPCManager
    local self = setmetatable({}, SNPCManager)
    -- Server Core
    self.core = core
    

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        RegisterCallback('onTakeMission', function(source, data)
            return self:onTakeMission(source, data)
        end)
    end

    ---Handle player take mission
    ---@param source PlayerController source id
    ---@param data {missionName:string} data
    ---@return {status:boolean, message:string} result of taking mission
    function self:onTakeMission(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.playerNotFound')
            }
        end
        if not data.missionName or type(data.missionName) ~= 'string' then
            return {
                status = false,
                message = SHARED.t('error.invalidData')
            }
        end
        return player.missionManager:takeMission(data.missionName)
    end

    function self:findMissionByNPCName(npcName)
        for _, mission in pairs(SHARED.missions) do
            if mission.assignedNPC == npcName then
                return mission
            end
            for _, requirement in pairs(mission.requirements) do
                local requirementNpcName = requirement.npcName or requirement.name
                if requirement.type == 'talk_npc' and requirementNpcName == npcName then
                    return mission
                end
            end
        end
        
        return nil
    end

    ---@param npcName string
    ---@return TMissionData[] missions assigned to this npc
    function self:getMissionsByNPCName(npcName)
        local missions = {}
        for _, mission in pairs(SHARED.missions) do
            if mission.assignedNPC == npcName then
                table.insert(missions, mission)
            end
        end
        return missions
    end

    ---@param mission TMissionData
    ---@param nodeId number|nil
    ---@return TMissionDialogNode|nil
    function self:getDialogNode(mission, nodeId)
        if not mission or not mission.npcDialogs then return nil end
        local desiredNodeId = nodeId or 1
        for _, node in pairs(mission.npcDialogs) do
            if node.id == desiredNodeId then
                return node
            end
        end
        return nil
    end

    ---@param node TMissionDialogNode
    ---@param optionId string
    ---@return TMissionDialogOption|nil
    function self:getDialogOption(node, optionId)
        if not node or not node.options then return nil end
        for _, option in pairs(node.options) do
            if option.id == optionId then
                return option
            end
        end
        return nil
    end

    ---@param player SPlayer
    ---@param npcName string
    ---@return TMissionData|nil missionData, TMissionEntity|nil missionEntity
    function self:getPlayerMissionByNPC(player, npcName)
        if not player or not player.missionManager then return nil, nil end
        local missionEntity = player.missionManager:getCurrentActiveMission()
        if not missionEntity then return nil, nil end
        local missionData = SHARED.missions[missionEntity.id]
        if missionData and missionData.assignedNPC == npcName then
            return missionData, missionEntity
        end
        return nil, nil
    end

    ---Return dialog payload for client consumption
    ---@param player SPlayer
    ---@param npcName string
    function self:startDialog(player, npcName)
        local missionData, missionEntity = self:getPlayerMissionByNPC(player, npcName)
        if not missionData then
            return {
                status = false,
                message = 'mission_not_found'
            }
        end

        local dialogState
        if missionEntity and missionEntity.progress then
            for _, progress in pairs(missionEntity.progress) do
                if progress.type == 'talk_npc' then
                    dialogState = progress.dialogState
                    break
                end
            end
        end

        local nodeId = dialogState and dialogState.nodeId or 1
        local node = self:getDialogNode(missionData, nodeId)
        if not node then
            return {
                status = false,
                message = 'dialog_node_not_found'
            }
        end

        return {
            status = true,
            missionId = missionData.id,
            npcName = npcName,
            node = node
        }
    end

    ---Handle player selection and advance dialog
    ---@param player SPlayer
    ---@param npcName string
    ---@param dialogData {nodeId:number; optionId:string}
    function self:handleDialogSelection(player, npcName, dialogData)
        local missionData = nil
        local missionEntity = nil
        missionData, missionEntity = self:getPlayerMissionByNPC(player, npcName)
        if not missionData then
            return {
                status = false,
                message = 'mission_not_found'
            }
        end
        if not dialogData or not dialogData.optionId then
            return {
                status = false,
                message = 'invalid_payload'
            }
        end

        local node = self:getDialogNode(missionData, dialogData.nodeId)
        if not node then
            return {
                status = false,
                message = 'dialog_node_not_found'
            }
        end

        local option = self:getDialogOption(node, dialogData.optionId)
        if not option then
            return {
                status = false,
                message = 'dialog_option_not_found'
            }
        end

        local nextNodeId = option.nextNode or node.id
        local isResolved = option.completesMission or false

        local updateStatus = false
        if player.missionManager then
            updateStatus = player.missionManager:triggerAction('talk_npc', {
                npcName = npcName,
                dialogNode = nextNodeId,
                optionId = option.id,
                isResolved = isResolved
            }) or false
        end

        local nextNode = self:getDialogNode(missionData, nextNodeId)

        return {
            status = updateStatus,
            missionId = missionData.id,
            npcName = npcName,
            option = option,
            isResolved = isResolved,
            nextNode = nextNode,
            rewards = option.rewards
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SNPCManager

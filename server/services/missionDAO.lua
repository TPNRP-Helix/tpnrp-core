DAO.mission = {}
---Get player's missions by citizen id
---@param citizenId string
---@return TMissionEntity[] | nil mission entities
DAO.mission.get = function(citizenId)
    local result = DAO.DB.Select('SELECT missions FROM player_missions where citizen_id = ?', { citizenId })
    local missionData = result[1] and result[1].Columns:ToTable()
    if missionData then
        -- Format mission data
        return JSON.parse(missionData.missions)
    end

    return nil
end

---Save player's missions
---@param player SPlayer player entity
---@return boolean success
DAO.mission.save = function(player)
    -- Validate data
    if not player or not player.playerData then
        print('[ERROR] DAO.mission.save: Invalid player data!')
        return false
    end
    local citizenId = player.playerData.citizenId or nil
    if not citizenId then
        print('[ERROR] DAO.mission.save: Invalid citizen id!')
        return false
    end
    -- Begin transaction
	DAO.DB.Execute('BEGIN TRANSACTION;')
	local sql = [[
		INSERT INTO player_missions (citizen_id, missions)
		VALUES (?, ?)
		ON CONFLICT(citizen_id) DO UPDATE SET
			missions = excluded.missions
	]]
	local params = {
		citizenId,
		JSON.stringify(player.missionManager.missions),
	}
	local result = DAO.DB.Execute(sql, params)
	if result then
		DAO.DB.Execute('COMMIT;')
		print(('[LOG] Saved missions for %s (Citizen ID: %s)'):format(player.playerData.name, player.playerData.citizenId))
		return true
	end
	print(('[ERROR] DAO.mission.save: Failed to save missions for %s (Citizen ID: %s)'):format(player.playerData.name, player.playerData.citizenId))
	DAO.DB.Execute('ROLLBACK;')
	return false
end
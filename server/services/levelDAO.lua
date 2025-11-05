DAO.level = {}
---Get player's level by citizen id
---@param citizen_id string
---@return {level:number, exp:number, skills:any} level Level info
DAO.level.get = function(citizen_id)
    local result = DAO.DB.Select('SELECT level, exp, skills FROM levels where citizen_id = ?', { citizen_id })
    local levelData = result[1] and result[1].Columns:ToTable()
    if levelData then
        -- Format level data
        return {
            level = tonumber(levelData.level),
            exp = tonumber(levelData.exp),
            skills = JSON.parse(levelData.skills),
        }
    end

    return {
        level = SHARED.DEFAULT.LEVEL,
        exp = 0,
        skills = SHARED.DEFAULT.SKILLS,
    }
end

---Save player
---@param level SLevel
---@return boolean success
DAO.level.save = function(level)
	-- Validate data
	if not level or not level.playerController or not level.playerController.playerData then
		print('[ERROR] DAO.level.save: Invalid level or player data!')
		return false
	end
	local playerData = level.playerController.playerData
	local citizen_id = playerData.citizen_id
	-- Begin transaction
	DAO.DB.Execute('BEGIN TRANSACTION;')
	local sql = [[
		INSERT INTO levels (citizen_id, level, exp, skills)
		VALUES (?, ?, ?, ?)
		ON CONFLICT(citizen_id) DO UPDATE SET
			level = excluded.level,
			exp = excluded.exp,
			skills = excluded.skills
	]]
	local params = {
		citizen_id,
		tonumber(level.level) or SHARED.DEFAULT.LEVEL,
		tonumber(level.exp) or 0,
		JSON.stringify(level.skills or SHARED.DEFAULT.SKILLS),
	}
	local result = DAO.DB.Execute(sql, params)
	if result then
		DAO.DB.Execute('COMMIT;')
		print(('[LOG] Saved level for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizen_id))
		return true
	end
	print(('[ERROR] DAO.level.save: Failed to save level for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizen_id))
	DAO.DB.Execute('ROLLBACK;')
	return false
end

DAO.player = {}
---Get player by citizen id
---@param citizenId string
---@return PlayerData
DAO.player.get = function(citizenId)
    local result = DAO.DB.Select('SELECT * FROM players where citizen_id = ?', { citizenId })
    ---@type PlayerData | nil
    local playerData = nil
    local rowData = result[1] and result[1].Columns:ToTable()

    -- Validate PlayerData
    if rowData then
        ---@type PlayerData
        playerData = {
            characterId = rowData.character_id,
            license = rowData.license,
            name = rowData.name,
            money = JSON.parse(rowData.money),
            characterInfo = JSON.parse(rowData.character_info),
            job = JSON.parse(rowData.job),
            gang = JSON.parse(rowData.gang),
            position = JSON.parse(rowData.position),
            metadata = JSON.parse(rowData.metadata),
            citizenId = rowData.citizen_id,
        }

        return playerData
    end
    -- Fallback to default playerData if user didn't have yet
    ---@type PlayerData
    playerData = SHARED.DEFAULT.PLAYER
    playerData.citizenId = citizenId
    return playerData
end

---Save player
---@param player SPlayer
---@return boolean success
DAO.player.save = function(player)
    local playerData = player.playerData
    local pCoords = player:getCoords()
    local pHeading = player:getHeading()
    if not playerData then
        print('[ERROR] DAO.player.save: playerData is empty!')
        return false
    end
    -- Save player into database
    local result = DAO.DB.Execute([[INSERT INTO players (citizen_id, license, name, money, character_info, job, gang, position, heading, metadata)
        VALUES (?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(citizen_id) DO UPDATE SET
            name = excluded.name,
            money = excluded.money,
            character_info = excluded.character_info,
            job = excluded.job,
            gang = excluded.gang,
            position = excluded.position,
            heading = excluded.heading,
            metadata = excluded.metadata;
        ]],
        {
            playerData.citizenId,
            playerData.license,
            playerData.name,
            JSON.stringify(playerData.money),
            JSON.stringify(playerData.characterInfo),
            JSON.stringify(playerData.job),
            JSON.stringify(playerData.gang),
            JSON.stringify(pCoords),
            pHeading,
            JSON.stringify(playerData.metadata),
        })
    if result then
        print(('[LOG] Saved player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizenId))
        return true
    end
    print(('[ERROR] DAO.player.save: Failed to save player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizenId))
    return false
end

---Delete player
---@param player SPlayer
---@return boolean success
DAO.player.delete = function(player)
    -- TODO: Delete
    print('[ERROR] DAO.player.delete - Not implemented!')
    return false
end

---Get player's characters
---@param license string
---@return table<number, PlayerData> characters
DAO.player.getCharacters = function(license)
    local result = DAO.DB.Select('SELECT * FROM players WHERE license = ?', { license })
    if not result then return {} end
    local resultData = result and result:ToTable()
    print('[TPN][SERVER] DAO.player.getCharacters - result: ' .. JSON.stringify(resultData))
    -- Format characters
    ---@type table<number, PlayerData>
    local characters = {}
    for i = 1, #resultData do
        local rowData = resultData[i]
        if type(rowData) == 'table' then
            local row = {}
            for CName, CValue in pairs(rowData) do
                row[CName] = CValue
            end
            row.characterInfo = JSON.parse(row.character_info)
            row.money = JSON.parse(row.money)
            row.job = JSON.parse(row.job)

            characters[#characters + 1] = row
        end
    end
    -- Return characters
    return characters
end

---Create character
---@param license string
---@param playerData PlayerData
---@return boolean success
DAO.player.createCharacter = function(license, playerData)
    -- Save player into database
    local result = DAO.DB.Execute([[INSERT INTO players (citizen_id, license, name, money, character_info, job, gang, position, heading, metadata)
        VALUES (?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(citizen_id) DO UPDATE SET
            name = excluded.name,
            money = excluded.money,
            character_info = excluded.character_info,
            job = excluded.job,
            gang = excluded.gang,
            position = excluded.position,
            heading = excluded.heading,
            metadata = excluded.metadata;
        ]],
        {
            playerData.citizenId,
            license,
            playerData.name,
            JSON.stringify(playerData.money),
            JSON.stringify(playerData.characterInfo),
            JSON.stringify(playerData.job),
            JSON.stringify(playerData.gang),
            JSON.stringify(SHARED.DEFAULT.SPAWN.POSITION),
            SHARED.DEFAULT.SPAWN.HEADING,
            JSON.stringify(playerData.metadata),
        })
    if result then
        print(('[LOG] Saved player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizenId))
        return true
    end
    print(('[ERROR] DAO.player.save: Failed to save player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizenId))
    return false
end
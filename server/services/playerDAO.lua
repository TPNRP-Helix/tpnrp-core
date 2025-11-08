DAO.player = {}
---Get player by citizen id
---@param citizen_id string
---@return PlayerData | nil
DAO.player.get = function(citizen_id)
    local result = DAO.DB.Select('SELECT * FROM players where citizen_id = ?', { citizen_id })
    local playerData = result[1] and result[1].Columns:ToTable()

    -- Validate PlayerData
    if playerData then
        playerData.money = JSON.parse(playerData.money)
        playerData.character_info = JSON.parse(playerData.character_info)
        playerData.job = JSON.parse(playerData.job)
        playerData.gang = JSON.parse(playerData.gang)
        playerData.position = JSON.parse(playerData.position)
        playerData.metadata = JSON.parse(playerData.metadata)

        ---@type PlayerData
        return playerData
    end

    return nil
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
    local result = DAO.DB.Execute([[INSERT INTO players (character_id, citizen_id, license, name, money, character_info, job, gang, position, heading, metadata)
        VALUES (?,?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(citizen_id) DO UPDATE SET
            character_id = excluded.character_id,
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
            tonumber(playerData.character_id),
            playerData.citizen_id,
            playerData.license,
            playerData.name,
            JSON.stringify(playerData.money),
            JSON.stringify(playerData.character_info),
            JSON.stringify(playerData.job),
            JSON.stringify(playerData.gang),
            JSON.stringify(pCoords),
            pHeading,
            JSON.stringify(playerData.metadata),
        })
    if result then
        print(('[LOG] Saved player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizen_id))
        return true
    end
    print(('[ERROR] DAO.player.save: Failed to save player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizen_id))
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
            row.charinfo            = JSON.parse(row.charinfo)
            row.money               = JSON.parse(row.money)
            row.job                 = JSON.parse(row.job)

            characters[#characters + 1] = row
        end
    end
    -- Return characters
    return characters
end
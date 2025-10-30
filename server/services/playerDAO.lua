
---Get player by citizen id
---@param citizenid string
DAO.getPlayer = function(citizenid)
    local result = DAO.DB.Select('SELECT * FROM players where citizenid = ?', { citizenid })
    local playerData = result[1] and result[1].Columns:ToTable()

    -- Validate PlayerData
    if playerData then
        return playerData
    end

    return nil
end

DAO.loadPlayer = function(player)
    -- TODO:
end

DAO.deletePlayer = function(player)
    -- TODO:
end

---@param player SPlayer
DAO.savePlayer = function(player)
    local playerData = player.playerData
    local pcoords = player:getCoords()
    local pheading = player:getHeading()
    if not playerData then
        print('[ERROR] DAO.SAVEPLAYER - playerData is empty!')
        return false
    end
    -- TODO:
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
            JSON.stringify(playerData.charinfo),
            JSON.stringify(playerData.job),
            JSON.stringify(playerData.gang),
            JSON.stringify(pcoords),
            pheading,
            JSON.stringify(playerData.metadata),
        })
    
    -- TODO: Save player inventories

    print(('[LOG] Saved player for %s (Citizen ID: %s)'):format(playerData.name, playerData.citizen_id))
end
---@param inventory SInventory
DAO.saveInventory = function(inventory)
    
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
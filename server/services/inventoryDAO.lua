---Save inventory
---@param inventory SInventory
---@return boolean success
DAO.saveInventory = function(inventory)
    -- Don't execute any query if inventory or player or playerData doesn't exist
    if not inventory or not inventory.player or not inventory.player.playerData then
        print('[ERROR] DAO.saveInventory: Invalid inventory or player data!')
        return false
    end
    local citizen_id = inventory.player.playerData.citizen_id
    local inv_table = inventory.inventories or {}
    local has_error = false

    -- Begin transaction
    DAO.DB.Execute('BEGIN TRANSACTION;')
    for slot, item in pairs(inv_table) do
        local sql = [[
            INSERT INTO inventories (citizen_id, slot, name, data, type)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(citizen_id, slot, name, type) DO UPDATE SET
                data = excluded.data
        ]]
        local params = {
            citizen_id,
            tonumber(slot),
            item.name,
            JSON.stringify(item.info or {}),
            'player',
        }
        local res = DAO.DB.Execute(sql, params)
        if not res then
            print(('DAO.saveInventory failed for citizen_id=%s slot=%s name=%s'):format(citizen_id, slot, item.name))
            has_error = true
            break
        end
    end
    if has_error then
        DAO.DB.Execute('ROLLBACK;')
        return false
    end
    DAO.DB.Execute('COMMIT;')
    print(('[LOG] Saved inventory for %s (Citizen ID: %s)'):format(inventory.player.playerData.name, inventory.player.playerData.citizen_id))
    return true
end
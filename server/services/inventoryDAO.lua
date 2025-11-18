DAO.inventory = {}
---Save inventory
---@param inventory SInventory
---@return boolean success
DAO.inventory.save = function(inventory)
    -- Don't execute any query if inventory or player or playerData doesn't exist
    if not inventory or not inventory.player or not inventory.player.playerData then
        print('[ERROR] DAO.inventory.save: Invalid inventory or player data!')
        return false
    end
    local citizenId = inventory.player.playerData.citizenId
    if not citizenId then
        print('[ERROR] DAO.inventory.save: Invalid citizen id!')
        return false
    end
    local items = inventory.items
    local formattedItems = {}
    for _, item in pairs(items) do
        local item = SHARED.items[item.name:lower()]
        if item then
            -- Only format the item if it is in the shared/items.lua
            formattedItems[#formattedItems + 1] = {
                name = item.name,
                amount = item.amount,
                info = item.info,
                slot = item.slot,
            }
        end
    end
    -- Begin transaction
    DAO.DB.Execute('BEGIN TRANSACTION;')
    local sql = [[
        INSERT INTO inventories (type, citizen_id, items)
        VALUES (?, ?, ?)
        ON CONFLICT(citizen_id, type) DO UPDATE SET
            items = excluded.items
    ]]
    local params = {
        inventory.type,
        citizenId,
        JSON.stringify(formattedItems),
    }
    local result = DAO.DB.Execute(sql, params)
    if result then
        DAO.DB.Execute('COMMIT;')
        print(('[LOG] Saved inventory for %s (Citizen ID: %s)'):format(inventory.player.playerData.name, inventory.player.playerData.citizenId))
        return true
    end
    print(('[ERROR] DAO.inventory.save: Failed to save inventory for %s (Citizen ID: %s)'):format(inventory.player.playerData.name, inventory.player.playerData.citizenId))
    DAO.DB.Execute('ROLLBACK;')
    return false
end

---Get player's inventory (type = 'player' | 'stack')
---@param citizenId string
---@param type 'player' | 'stack' | ''
---@return table<number, SInventoryItemType> | nil
DAO.inventory.get = function(citizenId, type)
    if not type then
        type = 'player'
    end
    -- Query inventory items
    local result = DAO.DB.Select('SELECT * FROM inventories where citizen_id = ? and type = ?', { citizenId, type })
    local inventory = result[1] and result[1].Columns:ToTable()
    if not inventory then
        return nil
    end
    -- Format items
    local items = JSON.parse(inventory.items)
    local formattedItems = {}
    -- Mapping base item data with the item data from the database
    for _, item in pairs(items) do
        local itemData = SHARED.items[item.name:lower()]
        if item then
            -- Save item slot as index
            formattedItems[item.slot] = itemData
            formattedItems[item.slot].amount = item.amount
            formattedItems[item.slot].info = item.info
            formattedItems[item.slot].slot = item.slot
        end
    end
    -- Return formatted items
    return formattedItems
end
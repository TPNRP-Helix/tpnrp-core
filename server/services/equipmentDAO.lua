DAO.equipment = {}
---Save inventory
---@param equipment SEquipment
---@return boolean status success status
DAO.equipment.save = function(equipment)
    -- Don't execute any query if equipment or player or playerData doesn't exist
    if not equipment or not equipment.player or not equipment.player.playerData then
        print('[ERROR] DAO.equipment.save: Invalid equipment or player data!')
        return false
    end
    local citizen_id = equipment.player.playerData.citizenId
    local items = equipment.items
    local formattedItems = {}
    for _, equipmentItem in pairs(items) do
        local baseItem = SHARED.items[equipmentItem.name:lower()]
        if baseItem then
            -- Only format the item if it is in the shared/items.lua
            -- Preserve the actual equipment item's info and slot, not the base definition's
            formattedItems[#formattedItems + 1] = {
                name = baseItem.name,
                info = equipmentItem.info,
                slot = equipmentItem.slot,
            }
        end
    end
    -- Begin transaction
    DAO.DB.Execute('BEGIN TRANSACTION;')
    local sql = [[
        INSERT INTO equipments (citizen_id, items)
        VALUES (?, ?)
        ON CONFLICT(citizen_id) DO UPDATE SET
            items = excluded.items
    ]]
    local params = {
        citizen_id,
        JSON.stringify(formattedItems),
    }
    local result = DAO.DB.Execute(sql, params)
    if result then
        DAO.DB.Execute('COMMIT;')
        print(('[LOG] Saved equipment for %s (Citizen ID: %s)'):format(equipment.player.playerData.name, equipment.player.playerData.citizenId))
        return true
    end
    print(('[ERROR] DAO.equipment.save: Failed to save equipment for %s (Citizen ID: %s)'):format(equipment.player.playerData.name, equipment.player.playerData.citizenId))
    DAO.DB.Execute('ROLLBACK;')
    return false
end

---Get player's inventory (type = 'player' | 'stack')
---@param citizenId string
---@return table<EEquipmentClothType, SEquipmentItemType> | nil
DAO.equipment.get = function(citizenId)
    -- Query equipment items
    local result = DAO.DB.Select('SELECT * FROM equipments where citizen_id = ?', { citizenId })
    local equipment = result[1] and result[1].Columns:ToTable()
    if not equipment then
        return nil
    end
    -- Format items
    local items = JSON.parse(equipment.items)
    local formattedItems = {}
    -- Mapping base item data with the item data from the database
    for _, item in pairs(items) do
        local itemData = SHARED.items[item.name:lower()]
        if item then
            local nextIndex = #formattedItems + 1
            formattedItems[nextIndex] = itemData
            formattedItems[nextIndex].amount = 1
            formattedItems[nextIndex].info = item.info
            formattedItems[nextIndex].slot = item.slot
        end
    end
    -- Return formatted items
    return formattedItems
end
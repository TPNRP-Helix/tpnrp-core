DAO.container = {}
---Save inventory
---@param container SContainer
---@return boolean success
DAO.container.save = function(container, citizenId)
    -- Don't execute any query if inventory or player or playerData doesn't exist
    if not container or not citizenId then
        print('[ERROR] DAO.container.save: Invalid container data!')
        return false
    end
    
    local items = container.items
    local formattedItems = {}
    for _, item in pairs(items) do
        local rawItem = SHARED.items[item.name:lower()]
        if rawItem then
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
        INSERT INTO inventories (container_id, type, citizen_id, max_slot, max_weight, items, is_destroy_on_empty, position, rotation)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(container_id) DO UPDATE SET
            items = excluded.items,
            max_slot = excluded.max_slot,
            max_weight = excluded.max_weight,
            is_destroy_on_empty = excluded.is_destroy_on_empty,
            position = excluded.position,
            rotation = excluded.rotation,
    ]]
    local params = {
        container.containerId,
        'container',
        citizenId,
        container.maxSlot,
        container.maxWeight,
        JSON.stringify(formattedItems),
        container.isDestroyOnEmpty,
        JSON.stringify({ x = container.position.x, y = container.position.y, z = container.position.z }),
        JSON.stringify({ Yaw = container.rotation.Yaw }),
    }
    local result = DAO.DB.Execute(sql, params)
    if result then
        DAO.DB.Execute('COMMIT;')
        print(('[LOG] Saved container for %s (Citizen ID: %s)'):format(container.containerId, citizenId))
        return true
    end
    print(('[ERROR] DAO.container.save: Failed to save container for %s (Citizen ID: %s)'):format(container.containerId, citizenId))
    DAO.DB.Execute('ROLLBACK;')
    return false
end

---Get container by containerId
---@param containerId string
---@return ResponseGetContainer|nil
DAO.container.get = function(containerId)
    local type = 'container'

    -- Query inventory items
    local result = DAO.DB.Select('SELECT * FROM inventories where container_id = ? and type= ?', { containerId, type })
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
    return {
        id = inventory.container_id,
        items = formattedItems,
        maxSlot = inventory.max_slot,
        maxWeight = inventory.max_weight,
        isDestroyOnEmpty = inventory.is_destroy_on_empty,
        position = JSON.parse(inventory.position),
        rotation = JSON.parse(inventory.rotation),
        displayModel = inventory.display_model,
    }
end

---Get all containers
---@return table<string, {id:string; items: table<number,SInventoryItemType>; maxSlot: number; maxWeight: number}> containers
DAO.container.getAll = function()
    local result = DAO.DB.Action('Select', 'SELECT * FROM inventories where type = ?', { 'container' })
    if not result or #result == 0 then
        return {}
    end
    return result
end
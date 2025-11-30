DAO.container = {}
---Save inventory
---@param container SContainer
---@return boolean success
DAO.container.save = function(container)
    -- Don't execute any query if inventory or player or playerData doesn't exist
    if not container or not container.citizenId then
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
        INSERT INTO containers (container_id, type, citizen_id, max_slot, max_weight, items, holder_item, is_destroy_on_empty, position, rotation)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(container_id) DO UPDATE SET
            items = excluded.items,
            max_slot = excluded.max_slot,
            max_weight = excluded.max_weight,
            holder_item = excluded.holder_item,
            is_destroy_on_empty = excluded.is_destroy_on_empty,
            position = excluded.position,
            rotation = excluded.rotation;
    ]]
    local position = ''
    if container.position then
        position = JSON.stringify({ x = container.position.x, y = container.position.y, z = container.position.z })
    end
    local rotation = ''
    if container.rotation then
        rotation = JSON.stringify({ Yaw = container.rotation.Yaw })
    end
    local holderItem = ''
    if container.holderItem then
        holderItem = JSON.stringify(container.holderItem)
    end

    local params = {
        container.containerId,
        'container',
        container.citizenId,
        container.maxSlot,
        container.maxWeight,
        holderItem,
        JSON.stringify(formattedItems),
        container.isDestroyOnEmpty,
        position,
        rotation,
    }
    local result = DAO.DB.Execute(sql, params)
    if result then
        DAO.DB.Execute('COMMIT;')
        print(('[LOG] Saved container for %s (Citizen ID: %s)'):format(container.containerId, container.citizenId))
        return true
    end
    print(('[ERROR] DAO.container.save: Failed to save container for %s (Citizen ID: %s)'):format(container.containerId, container.citizenId))
    DAO.DB.Execute('ROLLBACK;')
    return false
end

---Get container by containerId
---@param containerId string
---@return ResponseGetContainer|nil
DAO.container.get = function(containerId)
    local type = 'container'

    -- Query inventory items
    local result = DAO.DB.Select('SELECT * FROM containers where container_id = ? and type= ?', { containerId, type })
    local inventory = result[1] and result[1].Columns:ToTable()
    if not inventory then
        return nil
    end
    -- Format items
    local items = JSON.parse(inventory.items)
    if not items then
        items = {}
    end
    local formattedItems = {}
    -- Mapping base item data with the item data from the database
    for _, item in pairs(items) do
        local itemData = SHARED.items[item.name:lower()]
        if item then
            local nextIndex = #formattedItems + 1
            formattedItems[nextIndex] = itemData
            formattedItems[nextIndex].amount = item.amount
            formattedItems[nextIndex].info = item.info
            formattedItems[nextIndex].slot = item.slot
        end
    end
    -- Return formatted items
    return {
        id = inventory.container_id,
        items = formattedItems,
        maxSlot = tonumber(inventory.max_slot),
        maxWeight = tonumber(inventory.max_weight),
        isDestroyOnEmpty = inventory.is_destroy_on_empty,
        position = JSON.parse(inventory.position),
        rotation = JSON.parse(inventory.rotation),
        displayModel = inventory.display_model,
        holderItem = JSON.parse(inventory.holder_item),
    }
end

---Get all containers
---@return table<string, {id:string; items: table<number,SInventoryItemType>; maxSlot: number; maxWeight: number}> containers
DAO.container.getAll = function()
    local result = DAO.Action('Select', 'SELECT * FROM containers where type = ?', { 'container' })
    if not result or #result == 0 then
        return {}
    end
    return result
end
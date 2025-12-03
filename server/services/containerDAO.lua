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
    local expirationHours = SHARED.CONFIG.CONTAINER_EXPIRATION_HOURS or 24
    local expirationSeconds = expirationHours * 3600
    local currentTimestamp = os.time()
    local expirationTimestamp = currentTimestamp + expirationSeconds
    local sql = [[
        INSERT INTO containers (container_id, type, citizen_id, max_slot, max_weight, items, holder_item, is_destroy_on_empty, position, rotation, time_expired)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(container_id) DO UPDATE SET
            items = excluded.items,
            max_slot = excluded.max_slot,
            max_weight = excluded.max_weight,
            holder_item = excluded.holder_item,
            is_destroy_on_empty = excluded.is_destroy_on_empty,
            position = excluded.position,
            rotation = excluded.rotation,
            time_expired = excluded.time_expired;
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
        container.containerType or 'container',
        container.citizenId,
        container.maxSlot,
        container.maxWeight,
        JSON.stringify(formattedItems),
        holderItem,
        container.isDestroyOnEmpty and 1 or 0,
        position,
        rotation,
        expirationTimestamp,
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
DAO.container.get = function(containerId, containerType)
    if not containerType then
        containerType = 'container'
    end
    -- Query inventory items
    local result = DAO.DB.Select('SELECT * FROM containers where container_id = ? and type= ?', { containerId, containerType })
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
    -- Calculate expiration time if not set (for backward compatibility)
    local timeExpired = tonumber(inventory.time_expired)
    if not timeExpired then
        local expirationHours = SHARED.CONFIG.CONTAINER_EXPIRATION_HOURS or 24
        local expirationSeconds = expirationHours * 3600
        timeExpired = os.time() + expirationSeconds
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
        timeExpired = timeExpired,
        containerType = inventory.type or 'container',
    }
end

---Get all containers
---@return table<string, ResponseGetContainer> containers
DAO.container.getAll = function(containerType)
    if not containerType then
        containerType = 'container'
    end
    local result = DAO.Action('Select', 'SELECT * FROM containers WHERE type = ? AND position IS NOT NULL AND position != ? AND rotation IS NOT NULL AND rotation != ?', { containerType, '', '' })
    if not result or #result == 0 then
        return {}
    end
    local containers = {}
    for _, container in pairs(result) do
        local rotation = JSON.parse(container.rotation)
        local position = JSON.parse(container.position)
        local items = JSON.parse(container.items)
        local formattedItems = {}
    -- Mapping base item data with the item data from the database
        for _, item in ipairs(items) do
            local itemData = SHARED.items[item.name:lower()]
            if item then
                local nextIndex = #formattedItems + 1
                formattedItems[nextIndex] = itemData
                formattedItems[nextIndex].amount = item.amount
                formattedItems[nextIndex].info = item.info
                formattedItems[nextIndex].slot = item.slot
            end
        end
        -- Calculate expiration time if not set (for backward compatibility)
        local timeExpired = tonumber(container.time_expired)
        if not timeExpired then
            local expirationHours = SHARED.CONFIG.CONTAINER_EXPIRATION_HOURS or 24
            local expirationSeconds = expirationHours * 3600
            timeExpired = os.time() + expirationSeconds
        end
        
        containers[#containers + 1] = {
            id = container.container_id,
            citizenId = container.citizen_id,
            items = formattedItems,
            maxSlot = tonumber(container.max_slot),
            maxWeight = tonumber(container.max_weight),
            rotation = Rotator(0, rotation.Yaw, 0),
            position = Vector(position.x, position.y, position.z),
            isDestroyOnEmpty = container.is_destroy_on_empty == 1,
            containerType = container.type or 'container',
            displayModel = container.display_model,
            holderItem = JSON.parse(container.holder_item),
            timeExpired = timeExpired,
        }
    end

    return containers
end

---Delete container by containerId
---@param containerId string
---@return boolean success
DAO.container.delete = function(containerId)
    local result = DAO.DB.Execute('DELETE FROM containers WHERE container_id = ?;', { containerId })
    if result then
        return true
    end
    return false
end

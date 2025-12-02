---@class SInventoryManager
---@field core TPNRPServer Core
---@field containers table<string, SContainer> Dictionary of containers managed by sInventoryManager, keyed by containerId
SInventoryManager = {}
SInventoryManager.__index = SInventoryManager

---@param core TPNRPServer Core
---@return SInventoryManager
function SInventoryManager.new(core)
    ---@class SInventoryManager
    local self = setmetatable({}, SInventoryManager)

    -- Core
    self.core = core

    ---@type table<string, SContainer> Dictionary of containers managed by sInventoryManager, keyed by containerId
    self.containers = {}

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        --- Callback events
        RegisterCallback('onOpenInventory', function(source, data)
            return self:onOpenInventory(source, data)
        end)

        --- Open Container Inventory
        RegisterCallback('onOpenContainerInventory', function(source, data)
            return self:onOpenInventory(source, data)
        end)

        RegisterCallback('onPickUpItem', function(source, data)
            return self:onPickUpItem(source, data)
        end)

        RegisterCallback('onMoveInventoryItem', function(source, data)
            return self:onMoveInventoryItem(source, data)
        end)

        RegisterCallback('createDropItem', function(source, data)
            return self:createDropItem(source, data)
        end)

        RegisterCallback('devAddItem', function(source, data)
            local player = self.core:getPlayerBySource(source)
            if not player then
                return {
                    status = false,
                    message = 'Player not found!',
                }
            end
            local permission = self.core:getPermission(source)
            if permission ~= 'admin' then
                return {
                    status = false,
                    message = SHARED.t('error.notAllowed'),
                }
            end
            local itemInfo = nil
            if data.itemName == 'cloth_bag_item_1' then
                local createContainerResult = self:createContainer({
                    citizenId = player.playerData.citizenId,
                    slotCount = 30,
                    weightLimit = 80000
                })

                itemInfo = {
                    slotCount = 30,
                    weightLimit = 80000,
                    containerId = createContainerResult.containerId
                }
            end
            local result = player.inventory:addItem(data.itemName, data.amount, nil, itemInfo)
            if not result.status and result.message == 'Inventory is full!' then
                local backpack = player.inventory:getBackpackContainer()
                if backpack then
                    result = backpack:addItem(data.itemName, data.amount, nil, itemInfo)
                end
            end
            return {
                status = result.status,
                message = result.message,
            }
        end)

        RegisterCallback('splitItem', function(source, data)
            return self:splitItem(source, data)
        end)

        RegisterCallback('useItem', function(source, data)
            return self:useItem(source, data)
        end)

        RegisterCallback('wearItem', function(source, data)
            return self:wearItem(source, data)
        end)

        RegisterCallback('unequipItem', function(source, data)
            return self:unequipItem(source, data)
        end)

        RegisterServerEvent('onCloseInventory', function(source)
            local player = self.core:getPlayerBySource(source)
            if not player then
                return
            end

            player.inventory.openingContainerId = nil
        end)

        -- Load container from DB and create entity
        local allContainers = DAO.container.getAll()
        -- Loop through containers
        if allContainers and type(allContainers) == 'table' then
            for _, container in pairs(allContainers) do
                if not container then
                    goto nextContainer
                end
                -- Create container entity, spawn it in world, add interaction for it
                -- Safely serialize container for debugging (convert userdata to plain tables)
                local itemName = ''
                if container.holderItem then
                    itemName = container.holderItem.name or ''
                else
                    itemName = (container.items and container.items[1] and container.items[1].name) or ''
                end
                local worldItem = SHARED.getWorldItemPath(itemName)
                local spawnPosition = Vector(container.position.x, container.position.y, container.position.z)
                local spawnRotation = Rotator(0, container.rotation.Yaw, 0)
                
                local spawnStaticMeshParams = {
                    containerId = container.id,
                    entityPath = worldItem.path,
                    position = spawnPosition,
                    rotation = spawnRotation,
                    scale = worldItem.scale,
                    collisionType = ECollisionType.IgnoreOnlyPawn,
                    mobilityType = EMobilityType.Movable,
                }
                -- Spawn bag
                local spawnResult = self.core.gameManager:spawnStaticMesh(spawnStaticMeshParams)
                if not spawnResult.status then
                    print('[WARNING] Failed to spawn container ' .. container.id .. '!')
                    goto nextContainer
                end
                -- Item have an option to pick up item
                local options = {
                    {
                        Text = SHARED.t('inventory.pickUpItem'),
                        Input = '/Game/Helix/Input/Actions/IA_Interact.IA_Interact',
                        Action = function(Drop, Instigator)
                            local controller = Instigator and Instigator:GetController()
                            if controller then
                                TriggerClientEvent(controller, 'pickUpItem', { containerId = spawnResult.entityId })
                            end
                        end,
                    }
                }
                if container.holderItem then
                    table.insert(options, {
                        Text = SHARED.t('inventory.openDrop'),
                        Input = '/Game/Helix/Input/Actions/IA_Weapon_Reload.IA_Weapon_Reload',
                        Action = function(Drop, Instigator)
                            local controller = Instigator and Instigator:GetController()
                            if controller then
                                TriggerClientEvent(controller, 'openContainerInventory', { containerId = spawnResult.entityId })
                            end
                        end,
                    })
                end
                -- Spawn success
                local addInteractableResult = self.core.gameManager:addInteractable({
                    entityId = spawnResult.entityId,
                    entity = spawnResult.entity,
                    options = options,
                })
                if not addInteractableResult.status then
                    -- On failed to create interactable => Destroy bag
                    DeleteEntity(spawnResult.entity)
                    goto nextContainer
                end
                
                local newContainerObj = SContainer.new(self.core, container.id, container.citizenId)
                newContainerObj:initEntity({
                    entityId = spawnResult.entityId,
                    entity = spawnResult.entity,
                    interactableEntity = addInteractableResult.interactableEntity,
                    position = spawnPosition,
                    rotation = spawnRotation,
                    items = container.items,
                    maxSlot = container.maxSlot,
                    maxWeight = container.maxWeight,
                    isDestroyOnEmpty = container.isDestroyOnEmpty,
                    holderItem = container.holderItem,
                })
                self.containers[spawnResult.entityId] = newContainerObj

                ::nextContainer::
            end
        end
    end

    ---On shutdown
    function self:onShutdown()
        for _, container in pairs(self.containers) do
            container:save()
            container:destroy()
        end
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Open container by id
    ---@param containerId string container id
    ---@return {status: boolean; message: string; container: SContainer|nil} result of opening container
    function self:openContainerId(containerId)
        local container = self.containers[containerId]
        if not container then
            return {
                status = false,
                message = 'Container not found!',
                container = nil
            }
        end
        return {
            status = true,
            message = 'Container opened!',
            container = container,
        }
    end

    ---Init container
    ---@param containerId string container id
    ---@param citizenId string citizen id
    ---@return {status: boolean; message: string; container: SContainer|nil} result of initializing container
    function self:initContainer(containerId, citizenId)
        local container = SContainer.new(self.core, containerId, citizenId)
        if container:load() then
            -- Assign container to list
            self.containers[containerId] = container
            return {
                status = true,
                message = 'Container initialized!',
                container = container,
            }
        end

        return {
            status = false,
            message = 'Failed to init container!',
            container = nil
        }
    end

    ---Create new container
    ---@param data {citizenId:string; slotCount:number; weightLimit:number}
    ---@return {status: boolean; message: string; containerId: string|nil} result of creating container
    function self:createContainer(data)
        local containerId = self.core.gameManager:createId('bag_item')
        
        local container = SContainer.new(self.core, containerId, data.citizenId)
        container:createNewContainer({
            maxSlot = data.slotCount,
            maxWeight = data.weightLimit,
            items = {},
            containerId = containerId,
        })
        -- Save container into database
        container:save()
        -- Push container into self.containers for manage later
        self.containers[containerId] = container

        return {
            status = true,
            message = 'Container created!',
            containerId = containerId,
        }
    end

    ---On open inventory
    ---@param source PlayerController player controller
    ---@param data {type:'player' | 'container'; containerId:string|nil} data
    ---@return TInventoryOpenInventoryResultType result
    function self:onOpenInventory(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        -- Get player's inventory and equipment
        local result = player.inventory:openInventory()
        if data.type == 'container' then
            ---@type SContainer|nil container
            local container = self.containers[data.containerId]
            if not container then
                return {
                    status = false,
                    message = 'Container not found!',
                }
            end
            player.inventory.openingContainerId = container.containerId
            -- Ensure container items have correct slot properties
            -- Items are stored as an array, so we need to ensure each item's slot property is correct
            -- Use ipairs to iterate in order and preserve slot numbers correctly
            local containerItems = {}
            for index, item in ipairs(container.items) do
                if item and item.slot then
                    -- Create a copy to ensure slot property is preserved correctly
                    -- IMPORTANT: Use item.slot (from database) not array index
                    containerItems[#containerItems + 1] = {
                        name = item.name,
                        label = item.label,
                        weight = item.weight,
                        type = item.type,
                        image = item.image,
                        unique = item.unique,
                        useable = item.useable,
                        shouldClose = item.shouldClose,
                        description = item.description,
                        amount = item.amount,
                        slot = item.slot, -- Preserve the slot property from the item (NOT array index)
                        info = item.info and JSON.parse(JSON.stringify(item.info)) or {}
                    }
                end
            end
            result.container = {
                id = container.containerId,
                items = containerItems,
                capacity = {
                    weight = container.maxWeight,
                    slots = container.maxSlot,
                }
            }
        end

        return result
    end

    ---Convert numeric equipment slot to EEquipmentClothType enum
    ---@param slotNumber number numeric slot from client
    ---@return EEquipmentClothType | nil equipment cloth type
    local function getEquipmentClothTypeFromSlot(slotNumber)
        local slotMap = {
            [1] = EEquipmentClothType.Hat,
            [2] = EEquipmentClothType.Glasses,
            [3] = EEquipmentClothType.Ears,
            [4] = EEquipmentClothType.Top,
            [5] = EEquipmentClothType.Undershirts,
            [6] = EEquipmentClothType.Leg,
            [7] = EEquipmentClothType.Shoes,
            [8] = EEquipmentClothType.Bag,
            [9] = EEquipmentClothType.Bracelets,
            [10] = EEquipmentClothType.Watch,
            [11] = EEquipmentClothType.Mask,
            [12] = EEquipmentClothType.Accessories,
            [13] = EEquipmentClothType.Torso, -- Torso is Gloves
            [14] = EEquipmentClothType.Armor,
        }
        return slotMap[slotNumber]
    end

    ---Get item from container
    ---@param containerId string container id
    ---@param slot number slot number
    ---@return SInventoryItemType | nil item data, or nil if item not found
    local function getItemFromContainer(containerId, slot)
        local container = self.containers[containerId]
        if not container then
            return nil
        end
        -- Use getItemBySlot to properly find item by slot number
        local item, _ = container:getItemBySlot(slot)
        if not item then
            return nil
        end
        -- Create a copy to prevent slot syncing issues when the same item exists in both inventory and container
        return {
            name = item.name,
            label = item.label,
            weight = item.weight,
            type = item.type,
            image = item.image,
            unique = item.unique,
            useable = item.useable,
            shouldClose = item.shouldClose,
            description = item.description,
            amount = item.amount,
            slot = item.slot,
            info = item.info and JSON.parse(JSON.stringify(item.info)) or {}
        }
    end

    ---Get item from a specific group and slot
    ---@param player SPlayer player entity
    ---@param group 'inventory' | 'equipment' group type
    ---@param slot number slot number (numeric for inventory, equipment slot number for equipment)
    ---@param sourceGroupId string|nil source group id
    ---@param targetGroupId string|nil target group id
    ---@return table | nil item data or nil
    local function getItemFromGroup(player, group, slot, sourceGroupId, targetGroupId)
        if group == 'inventory' then
            ---@cast slot number
            local foundSlot, foundIndex = player.inventory:getItemBySlot(slot)
            return foundSlot
        elseif group == 'equipment' then
            ---@cast slot number
            local clothType = getEquipmentClothTypeFromSlot(slot)
            if not clothType then
                return nil
            end
            return player.equipment:getItemByClothType(clothType)
        elseif group == 'container' and sourceGroupId ~= nil then
            return getItemFromContainer(sourceGroupId, slot)
        elseif group == 'backpack' then
            local backpack = player.inventory:getBackpackContainer()
            if not backpack then
                return nil
            end
            -- Backpack should minus inventory capacity slots
            local backpackSlotIndex = slot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
            local resultItem, _ = backpack:getItemBySlot(backpackSlotIndex)
            return resultItem
        end
        return nil
    end

    ---Move item between different groups
    ---@param player SPlayer player entity
    ---@param sourceItem SInventoryItemType|SEquipmentItemType source item data
    ---@param targetItem SInventoryItemType|SEquipmentItemType|nil target item data
    ---@param sourceGroup 'inventory' | 'equipment' | 'container' source group type
    ---@param targetGroup 'inventory' | 'equipment' | 'container' target group type
    ---@param sourceSlot number source slot number
    ---@param targetSlot number target slot number
    ---@param sourceGroupId string|nil source group id
    ---@param targetGroupId string|nil target group id
    ---@return {status: boolean; message: string; slot:number} result of moving item
    local function moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, sourceSlot, targetSlot, sourceGroupId, targetGroupId)
        if sourceGroup == 'inventory' then
            -- Move item from inventory to backpack
            if targetGroup == 'backpack' then
                local backpackSlotIndex = targetSlot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
                -- if targetItem exist then swapping sourceItem and targetItem
                local backpack = player.inventory:getBackpackContainer()
                if not backpack then
                    return {
                        status = false,
                        message = 'Backpack not found!',
                    }
                end
                if targetItem then
                    -- Remove item from source
                    local removeResult = player.inventory:removeItem(sourceItem.name, sourceItem.amount, sourceSlot, false)
                    if not removeResult.status then
                        return {
                            status = false,
                            message = removeResult.message,
                        }
                    end
                    targetItem.slot = sourceSlot
                    -- Add targetItem back to source
                    local addResult = player.inventory:addItem(targetItem.name, targetItem.amount, sourceSlot, targetItem.info, false)
                    if not addResult.status then
                        -- Rollback: Add sourceItem back to inventory
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addResult.message,
                        }
                    end
                    
                    -- Remove targetItem from backpack
                    local removeBackpackResult = backpack:removeItem(targetItem.name, targetItem.amount, backpackSlotIndex)
                    if not removeBackpackResult.status then
                        -- Rollback: Remove targetItem from inventory and Add sourceItem back to inventory
                        player.inventory:removeItem(targetItem.name, targetItem.amount, sourceSlot, false)
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = removeBackpackResult.message,
                        }
                    end
                    sourceItem.slot = backpackSlotIndex
                    -- Add sourceItem to backpack
                    local addBackpackResult = backpack:addItem(sourceItem.name, sourceItem.amount, backpackSlotIndex, sourceItem.info)
                    if not addBackpackResult.status then
                        -- Rollback: Add targetItem back to backpack, Remove targetItem from inventory, Add sourceItem back to inventory
                        backpack:addItem(targetItem.name, targetItem.amount, backpackSlotIndex, targetItem.info)
                        player.inventory:removeItem(targetItem.name, targetItem.amount, sourceSlot, false)
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addBackpackResult.message,
                        }
                    end
                else
                    -- Target don't have any item then just move sourceItem to targetSlot
                    -- Remove item from source
                    local removeResult = player.inventory:removeItem(sourceItem.name, sourceItem.amount, sourceSlot, false)
                    if not removeResult.status then
                        return {
                            status = false,
                            message = removeResult.message,
                        }
                    end
                    sourceItem.slot = backpackSlotIndex
                    -- Add targetItem back to source
                    local addResult = backpack:addItem(sourceItem.name, sourceItem.amount, backpackSlotIndex, sourceItem.info)
                    if not addResult.status then
                        -- Rollback: Add sourceItem back to inventory
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addResult.message,
                        }
                    end
                end
                -- Sync inventory
                player.inventory:sync()
                return {
                    status = true,
                    message = 'Item moved successfully!',
                    slot = backpackSlotIndex,
                }
            end
            -- Moving from inventory to equipment
            if targetGroup == 'equipment' then
                local clothType = SHARED.getClothItemTypeByName(sourceItem.name)
                if not clothType then
                    return {
                        status = false,
                        message = SHARED.t('error.itemNotCloth'),
                    }
                end
                local equipResult = player.equipment:equipItem(sourceItem.name, targetSlot)
                return {
                    status = equipResult.status,
                    message = equipResult.message,
                    slot = targetSlot,
                }
            end
            -- Moving from inventory to container
            if targetGroup == 'container' then
                ---@type SContainer|nil container
                local container = self.containers[targetGroupId]
                if not container then
                    return {
                        status = false,
                        message = 'Container not found!',
                    }
                end
                if targetItem then
                    -- Remove source item from inventory
                    local removeResult = player.inventory:removeItem(sourceItem.name, sourceItem.amount, sourceSlot)
                    if not removeResult.status then
                        return {
                            status = false,
                            message = removeResult.message,
                        }
                    end
                    -- Add target item to inventory
                    targetItem.slot = sourceSlot
                    local addResult = player.inventory:addItem(targetItem.name, targetItem.amount, sourceSlot, targetItem.info)
                    if not addResult.status then
                        -- Rollback: Add sourceItem back to inventory
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addResult.message,
                        }
                    end
                    -- Remove target item from container
                    local removeTargetResult = container:removeItem(targetItem.name, targetItem.amount, targetSlot)
                    if not removeTargetResult.status then
                        -- Rollback: Remove targetItem from inventory, Add sourceItem back to inventory
                        player.inventory:removeItem(targetItem.name, targetItem.amount, sourceSlot)
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = removeTargetResult.message,
                        }
                    end
                    -- Add source item to container
                    sourceItem.slot = targetSlot
                    local addTargetResult = container:addItem(sourceItem.name, sourceItem.amount, targetSlot, sourceItem.info)
                    if not addTargetResult.status then
                        -- Rollback: Add targetItem back to container, Remove targetItem from inventory, Add sourceItem back to inventory
                        container:addItem(targetItem.name, targetItem.amount, targetSlot, targetItem.info)
                        player.inventory:removeItem(targetItem.name, targetItem.amount, sourceSlot)
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addTargetResult.message,
                        }
                    end
                else
                    -- Remove item from inventory
                    local removeResult = player.inventory:removeItem(sourceItem.name, sourceItem.amount, sourceSlot)
                    if not removeResult.status then
                        return {
                            status = false,
                            message = removeResult.message,
                        }
                    end
                    -- Add item to container
                    sourceItem.slot = targetSlot
                    local addResult = container:addItem(sourceItem.name, sourceItem.amount, targetSlot, sourceItem.info)
                    if not addResult.status then
                        -- Rollback: Add sourceItem back to inventory
                        player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addResult.message,
                        }
                    end
                end

                return {
                    status = true,
                    message = 'Item moved from inventory to container!',
                    slot = targetSlot,
                }
            end
        end

        if sourceGroup == 'equipment' then
            -- Moving from equipment to inventory
            if targetGroup == 'inventory' then
                -- Un-equip item
                if targetItem then
                    local clothType = SHARED.getClothItemTypeByName(sourceItem.name)
                    if not clothType then
                        self.core.cheatDetector:logCheater({
                            action = 'moveInventoryItem',
                            player = player or nil,
                            citizenId = player.playerData.citizenId or '',
                            license = player.playerData.license or '',
                            name = player.playerData.name or '',
                            content = ('[ERROR] [1] SInventoryManager.onMoveInventoryItem: Item %s is not a cloth item! Player trying to un-equip item that is not a cloth item!')
                                :format(sourceItem.name)
                        })
                        return {
                            status = false,
                            message = 'Item is not a cloth item!',
                        }
                    end

                    -- Have target item => un-equip clothes
                    local unequipResult = player.equipment:unequipItem(clothType, targetSlot)
                    return {
                        status = unequipResult.status,
                        message = unequipResult.message,
                        slot = targetSlot,
                    }
                else
                    local clothItemType = SHARED.getClothItemTypeByName(sourceItem.name)
                    if not clothItemType then
                        -- This should not invoke. Because sourceItem of equipment must be a cloth item
                        print('[SERVER] [ERROR] SInventoryManager.onMoveEquipmentItem: Source item is not a cloth item! Revalidate source item')
                        return {
                            status = false,
                            message = 'Source item is not a cloth item!',
                        }
                    end
                    local unequipResult = player.equipment:unequipItem(clothItemType, targetSlot)
                    return {
                        status = unequipResult.status,
                        message = unequipResult.message,
                        slot = targetSlot,
                    }
                end

                return {
                    status = true,
                    message = 'Item moved from equipment to inventory!',
                }
            end

            if targetGroup == 'backpack' then
                -- TODO: Move item from equipment to backpack
                local sourceItemClothType = SHARED.getClothItemTypeByName(sourceItem.name)
                if not sourceItemClothType then
                    -- This should not invoke. Because sourceItem of equipment must be a cloth item
                    print('[SERVER] [ERROR] SInventoryManager.onMoveEquipmentItem: Source item is not a cloth item! Revalidate source item')
                    return {
                        status = false,
                        message = 'Source item is not a cloth item!',
                    }
                end
                if targetItem then
                    local backpack = player.inventory:getBackpackContainer()
                    local targetItemClothType = SHARED.getClothItemTypeByName(targetItem.name)
                    if not backpack then
                        return {
                            status = false,
                            message = 'Backpack not found!',
                        }
                    end
                    if not targetItemClothType then
                        -- targetItem is not a cloth type then just find empty slot
                        local emptySlot = backpack:getEmptySlot()
                        if not emptySlot then
                            return {
                                status = false,
                                message = SHARED.t('backpack.full'),
                            }
                        end
                        local unequipResult = player.equipment:unequipItem(sourceItemClothType, emptySlot)
                        if not unequipResult.status then
                            return {
                                status = false,
                                message = unequipResult.message,
                            }
                        end
                        return {
                            status = true,
                            message = 'Item moved from equipment to backpack!',
                            slot = emptySlot,
                        }
                    else
                        -- targetItem is a clothType
                        -- TODO: Check is same clothType?
                        -- If same clothType then swap
                        -- If not then find empty slot for sourceItem
                        if targetItemClothType == sourceItemClothType then
                            -- Same clothType then swap them
                            local removeTargetItemResult = backpack:removeItem(targetItem.name, targetItem.amount, targetSlot)
                            if not removeTargetItemResult.status then
                                return {
                                    status = false,
                                    message = removeTargetItemResult.message,
                                }
                            end
                            local unequipResult = player.equipment:unequipItem(sourceItemClothType, targetSlot)
                            if not unequipResult.status then
                                return {
                                    status = false,
                                    message = unequipResult.message,
                                }
                            end
                            -- Then equip targetItem
                            local equipResult = player.equipment:equipItem(targetItem.name, targetSlot)
                            
                            return {
                                status = true,
                                message = 'Item moved from equipment to backpack!',
                                slot = targetSlot,
                            }
                        else
                            -- Not same cloth type then find empty slot for sourceItem
                            local emptySlot = backpack:getEmptySlot()
                            if not emptySlot then
                                return {
                                    status = false,
                                    message = SHARED.t('backpack.full'),
                                }
                            end
                            local unequipResult = player.equipment:unequipItem(sourceItemClothType, emptySlot)
                            if not unequipResult.status then
                                return {
                                    status = false,
                                    message = unequipResult.message,
                                }
                            end
                            return {
                                status = true,
                                message = 'Item moved from equipment to backpack!',
                                slot = emptySlot,
                            }
                        end
                    end
                else
                    local clothType = SHARED.getClothItemTypeByName(sourceItem.name)
                    if not clothType then
                        print('[SERVER] [ERROR] SInventoryManager.onMoveEquipmentItem: Item %s is not a cloth item! Player trying to move item that is not a cloth item!')
                        return {
                            status = false,
                            message = 'Item is not a cloth item!',
                        }
                    end
                    local unequipResult = player.equipment:unequipItem(clothType, targetSlot)
                    if not unequipResult.status then
                        return {
                            status = false,
                            message = unequipResult.message,
                        }
                    end
                end

                return {
                    status = true,
                    message = 'Item moved from equipment to backpack!',
                }
            end

            -- TODO: Move item from equipment to container
            if targetGroup == 'container' then
                return {
                    status = false,
                    message = 'Moving items to/from other groups is not implemented yet!',
                }
            end
        end

        if sourceGroup == 'container' then
            -- Moving from container to inventory
            if targetGroup == 'inventory' then
                ---@type SContainer|nil container
                local container = self.containers[sourceGroupId]
                if not container then
                    return {
                        status = false,
                        message = 'Container not found!',
                    }
                end
                local removeResult = container:removeItem(sourceItem.name, sourceItem.amount, sourceSlot)
                if not removeResult.status then
                    return {
                        status = false,
                        message = removeResult.message,
                    }
                end
                local addResult = player.inventory:addItem(sourceItem.name, sourceItem.amount, targetSlot, sourceItem.info)
                if not addResult.status then
                    -- Rollback item to container
                    container:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                    return {
                        status = false,
                        message = addResult.message,
                    }
                end
                -- Save container to database to persist the item removal
                container:save()
                return {
                    status = true,
                    message = 'Item moved from container to inventory!',
                    slot = targetSlot,
                }
            end

            if targetGroup == 'equipment' then
                return {
                    status = false,
                    message = 'Moving items to/from other groups is not implemented yet!',
                }
            end

            if targetGroup == 'backpack' then
                -- TODO:
            end
        end

        if sourceGroup == 'backpack' then
            if targetGroup == 'inventory' then
                -- TODO: Move item from backpack to inventory
                print('===============================================')
                print('[SERVER] [DEBUG] onMoveInventoryItem: backpack slot ' .. sourceSlot .. ' to inventory slot ' .. targetSlot)
                print('[SERVER] [DEBUG] onMoveInventoryItem sourceGroup: ' .. sourceGroup .. ' sourceGroupId: ' .. sourceGroupId)
                print('[SERVER] [DEBUG] onMoveInventoryItem targetGroup: ' .. targetGroup .. ' targetGroupId: ' .. targetGroupId)
                print('===============================================')
                local backpackSlot = sourceSlot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
                local backpack = player.inventory:getBackpackContainer()
                if not backpack then
                    return {
                        status = false,
                        message = 'Backpack not found!',
                    }
                end
                if targetItem then
                    -- Swap item 
                    -- Remove sourceItem from backpack
                    local removeResult = backpack:removeItem(sourceItem.name, sourceItem.amount, backpackSlot)
                    if not removeResult.status then
                        return {
                            status = false,
                            message = removeResult.message,
                        }
                    end
                    -- Remove targetItem from inventory
                    local removeTargetItemResult = player.inventory:removeItem(targetItem.name, targetItem.amount, targetSlot, false)
                    if not removeTargetItemResult.status then
                        -- Rollback on failed: Add sourceItem back to backpack
                        backpack:addItem(sourceItem.name, sourceItem.amount, backpackSlot, sourceItem.info)
                        return {
                            status = false,
                            message = removeTargetItemResult.message,
                        }
                    end
                    -- Add sourceItem to inventory
                    sourceItem.slot = targetSlot
                    local addResult = player.inventory:addItem(sourceItem.name, sourceItem.amount, targetSlot, sourceItem.info, false)
                    if not addResult.status then
                        -- Rollback on failed: Add sourceItem back to backpack
                        sourceItem.slot = sourceSlot -- Reverse slot of sourceItem
                        backpack:addItem(sourceItem.name, sourceItem.amount, backpackSlot, sourceItem.info)
                        player.inventory:addItem(targetItem.name, targetItem.amount, targetSlot, targetItem.info)
                        return {
                            status = false,
                            message = addResult.message,
                        }
                    end
                    -- Add targetItem to backpack
                    targetItem.slot = backpackSlot
                    local addTargetItemResult = backpack:addItem(targetItem.name, targetItem.amount, backpackSlot, targetItem.info)
                    if not addTargetItemResult.status then
                        -- Rollback on failed: Add sourceItem back to inventory
                        player.inventory:addItem(targetItem.name, targetItem.amount, targetSlot, targetItem.info, false)
                        sourceItem.slot = sourceSlot -- Reverse slot of sourceItem
                        backpack:addItem(sourceItem.name, sourceItem.amount, backpackSlot, sourceItem.info)
                        player.inventory:removeItem(sourceItem.name, sourceItem.amount, targetSlot)
                        return {
                            status = false,
                            message = addTargetItemResult.message,
                        }
                    end
                    player.inventory:sync()
                    return {
                        status = true,
                        message = 'Item moved from backpack to inventory!',
                        slot = targetSlot,
                    }
                else
                    -- Move item to target slot
                    local removeResult = backpack:removeItem(sourceItem.name, sourceItem.amount, backpackSlot)
                    if not removeResult.status then
                        return {
                            status = false,
                            message = removeResult.message,
                        }
                    end
                    sourceItem.slot = targetSlot
                    local addResult = player.inventory:addItem(sourceItem.name, sourceItem.amount, targetSlot, sourceItem.info, false)
                    if not addResult.status then
                        -- Rollback on failed: Add sourceItem back to backpack
                        backpack:addItem(sourceItem.name, sourceItem.amount, backpackSlot, sourceItem.info)
                        return {
                            status = false,
                            message = addResult.message,
                        }
                    end
                    player.inventory:sync()
                    return {
                        status = true,
                        message = 'Item moved from backpack to inventory!',
                        slot = targetSlot,
                    }
                end
            end

            if targetGroup == 'equipment' then
                -- TODO:
            end

            if targetGroup == 'container' then
                -- TODO:
            end
        end

        -- Unknown combination
        return {
            status = false,
            message = 'Unknown group combination!',
        }
    end

    ---Move item to same group
    ---@param player SPlayer player entity
    ---@param sourceItem SInventoryItemType source item data
    ---@param targetItem SInventoryItemType|nil target item data
    ---@param sourceGroup 'inventory' | 'equipment' | 'other' source group type
    ---@param targetGroup 'inventory' | 'equipment' | 'other' target group type
    ---@param targetSlot number target slot number
    ---@return {status: boolean; message: string; slot:number} result of moving item
    local function moveItemSameGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, targetSlot, sourceGroupId, targetGroupId)
        if sourceGroup ~= targetGroup then
            return {
                status = false,
                message = 'Source group and target group are different!',
            }
        end

        if sourceGroup == 'inventory' then
            local moveResult = player.inventory:moveItem(sourceItem, targetSlot)
            if not moveResult.status then
                return {
                    status = false,
                    message = moveResult.message,
                }
            end
            player.inventory:sync()
            return moveResult
        elseif sourceGroup == 'equipment' then
            return {
                status = false,
                message = 'Equipment does not support swapping items!',
            }
        elseif sourceGroup == 'container' then
            -- Handle other inventory types (ground, other player, etc.)
            local container = self.containers[sourceGroupId]
            if not container then
                return {
                    status = false,
                    message = 'Container not found!',
                }
            end
            local moveResult = container:moveItem(sourceItem, targetSlot)
            if not moveResult.status then
                return {
                    status = false,
                    message = moveResult.message,
                }
            end
            container:save()
            player.inventory:sync()
            return moveResult
        elseif sourceGroup == 'backpack' then
            local backpack = player.inventory:getBackpackContainer()
            if not backpack then
                return {
                    status = false,
                    message = 'Backpack not found!',
                }
            end
            -- Convert target global slot to backpack slot
            local targetBackpackSlot = targetSlot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
            -- sourceItem.slot should already be the backpack slot (not global slot)
            -- because getItemFromGroup converts it when retrieving from backpack
            local sourceBackpackSlot = sourceItem.slot
            -- Ensure sourceItem.slot matches the actual backpack slot
            -- Get the item again using the correct backpack slot to ensure we have the right reference
            local actualSourceItem, _ = backpack:getItemBySlot(sourceBackpackSlot)
            if not actualSourceItem then
                return {
                    status = false,
                    message = 'Source item not found in backpack!',
                }
            end
            -- Ensure the slot is correct before calling moveItem
            actualSourceItem.slot = sourceBackpackSlot
            local result = backpack:moveItem(actualSourceItem, targetBackpackSlot)
            -- Sync
            player.inventory:sync()

            return result
        end

        return {
            status = false,
            message = 'Group not supported!',
        }
    end

    ---On move inventory item
    ---@param source PlayerController player controller
    ---@param data {sourceSlot: number; targetSlot: number; sourceGroup: string; targetGroup: string; sourceGroupId: string|nil; targetGroupId: string|nil} data
    ---@return {status: boolean; message: string; slot:number} result of moving item
    function self:onMoveInventoryItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end

        -- Validate inputs
        local sourceSlot = data.sourceSlot
        local targetSlot = data.targetSlot
        local sourceGroup = data.sourceGroup
        local targetGroup = data.targetGroup
        local sourceGroupId = data.sourceGroupId
        local targetGroupId = data.targetGroupId
        if not sourceSlot or not targetSlot or not sourceGroup or not targetGroup then
            return {
                status = false,
                message = 'Invalid parameters!',
            }
        end

        -- Same slot, same group => Don't do anything
        if sourceSlot == targetSlot and sourceGroup == targetGroup then
            return {
                status = false,
                message = 'Same slot and group!',
            }
        end

        -- Validate sourceGroupId for container operations
        if sourceGroup == 'container' and not sourceGroupId then
            return {
                status = false,
                message = 'Container ID is required when moving from container!',
            }
        end

        -- Validate targetGroupId for container operations
        if targetGroup == 'container' and not targetGroupId then
            return {
                status = false,
                message = 'Container ID is required when moving to container!',
            }
        end

        -- Validate container exists if source is container
        if sourceGroup == 'container' and sourceGroupId and not self.containers[sourceGroupId] then
            return {
                status = false,
                message = 'Source container not found!',
            }
        end

        -- Validate container exists if target is container
        if targetGroup == 'container' and targetGroupId and not self.containers[targetGroupId] then
            return {
                status = false,
                message = 'Target container not found!',
            }
        end

        -- Get source item
        local sourceItem = getItemFromGroup(player, sourceGroup, sourceSlot, sourceGroupId, targetGroupId)
        if not sourceItem then
            -- Provide more specific error message based on source group
            local errorMessage = ''
            if sourceGroup == 'container' then
                if not sourceGroupId then
                    errorMessage = ('[ERROR] [0] SInventoryManager.onMoveInventoryItem: Container ID is missing! Cannot move item from container.')
                elseif not self.containers[sourceGroupId] then
                    errorMessage = ('[ERROR] [0] SInventoryManager.onMoveInventoryItem: Container %s not found! Source item not found in slot %s of container!')
                        :format(sourceGroupId, sourceSlot)
                else
                    errorMessage = ('[ERROR] [0] SInventoryManager.onMoveInventoryItem: Source item not found in slot %s of container %s!')
                        :format(sourceSlot, sourceGroupId)
                end
            elseif sourceGroup == 'backpack' then
                errorMessage = ('[ERROR] [0] SInventoryManager.onMoveInventoryItem: Source item not found in slot %s of backpack!')
                    :format(sourceSlot)
            else
                errorMessage = ('[ERROR] [0] SInventoryManager.onMoveInventoryItem: Source item not found in slot %s of %s! Player trying to move item that they don\'t have!')
                    :format(sourceSlot, sourceGroup)
            end
            
            self.core.cheatDetector:logCheater({
                action = 'moveInventoryItem',
                player = player or nil,
                citizenId = player.playerData.citizenId or '',
                license = player.playerData.license or '',
                name = player.playerData.name or '',
                content = errorMessage
            })
            return {
                status = false,
                message = 'Source item not found!',
            }
        end

        local targetItem = getItemFromGroup(player, targetGroup, targetSlot, targetGroupId, sourceGroupId)
        local result = nil
        if sourceGroup == targetGroup then
            -- Same group => Move item to target slot
            result = moveItemSameGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, targetSlot)
        else
            -- Different group => Move item to target slot
            result = moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, sourceSlot,
                targetSlot, sourceGroupId, targetGroupId)
        end

        if not result.status then
            return {
                status = false,
                message = result.message,
            }
        end
        -- destroy container when move done
        if data.sourceGroup == 'container' and self.containers[sourceGroupId] and sourceGroupId ~= nil then
            -- Check if container is empty
            if self.containers[sourceGroupId].isDestroyOnEmpty then
                ---@type SContainer container
                local containerEntity = self.containers[sourceGroupId]
                local deleteResult = containerEntity:destroy()
                if deleteResult.status then
                    self.containers[sourceGroupId] = nil
                end
            end
        end
        -- Return the result from the move function
        return result
    end

    ---Create drop item
    ---@param source PlayerController player controller
    ---@param data {itemName: string, amount: number, fromSlot: number} data
    ---@return TResponseCreateDropItem result of creating drop item
    function self:createDropItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
                itemData = data,
            }
        end
        local container = nil
        if data.fromSlot <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            container = player.inventory
        else
            container = player.inventory:getBackpackContainer()
        end
        if not container then
            return {
                status = false,
                message = 'Container not found!',
                itemData = data,
            }
        end
        local playerPawn = GetPlayerPawn(source)
        local playerCoords = GetEntityCoords(playerPawn)
        local PawnRotation = GetEntityRotation(playerPawn)
        local ForwardVec = playerPawn:GetActorForwardVector()
        local SpawnPosition = playerCoords + (ForwardVec * 200)
        local item = nil
        -- Get item from player's inventory
        item = container:getItemBySlot(data.fromSlot)
        
        if not item then
            self.core.cheatDetector:logCheater({
                action = 'createDropItem',
                player = player or nil,
                citizenId = player.playerData.citizenId or '',
                license = player.playerData.license or '',
                name = player.playerData.name or '',
                content = ('[ERROR] SInventoryManager.createDropItem: Item not found in inventory! Player trying to create drop item that they don\'t have in their inventory!')
                    :format(data.fromSlot)
            })
            return {
                status = false,
                message = 'Item not found in inventory!',
                itemData = data,
            }
        end

        -- Verify item name matches
        if item.name:lower() ~= data.itemName:lower() then
            return {
                status = false,
                message = 'Item at slot does not match requested item!',
                itemData = data,
            }
        end

        -- Check if item has enough amount
        if item.amount < data.amount then
            return {
                status = false,
                message = string.format('Not enough items! (Has: %d, Requested: %d)', item.amount, data.amount),
                itemData = data,
            }
        end

        -- Create a copy of the item with the requested amount for the drop
        local dropItem = {
            name = item.name,
            label = item.label,
            weight = item.weight,
            type = item.type,
            image = item.image,
            unique = item.unique,
            useable = item.useable,
            shouldClose = item.shouldClose,
            description = item.description,
            amount = data.amount,
            slot = 1,                                                        -- Will be set to 1 for the drop container
            info = item.info and JSON.parse(JSON.stringify(item.info)) or {} -- Deep copy info if it exists
        }

        -- Remove item from player's inventory
        local removeResult = container:removeItem(data.itemName, data.amount, data.fromSlot)
        if not removeResult.status then
            return {
                status = false,
                message = removeResult.message,
                itemData = data,
            }
        end
        local worldItem = SHARED.getWorldItemPath(data.itemName)
        -- TODO: Need a native function to get ground Z
        SpawnPosition.Z = SpawnPosition.Z - 90
        PawnRotation.Yaw = PawnRotation.Yaw + worldItem.rotation
        local spawnStaticMeshParams = {
            entityPath = worldItem.path,
            position = SpawnPosition,
            rotation = PawnRotation,
            scale = worldItem.scale,
            collisionType = ECollisionType.IgnoreOnlyPawn,
            mobilityType = EMobilityType.Movable,
        }
        if item.info.containerId then
            spawnStaticMeshParams.containerId = item.info.containerId
        end
        -- Spawn bag
        local spawnResult = self.core.gameManager:spawnStaticMesh(spawnStaticMeshParams)
        if not spawnResult.status then
            -- Spawn failed => Add item back to player's inventory
            container:addItem(data.itemName, data.amount, data.fromSlot, dropItem.info)
            return {
                status = false,
                message = spawnResult.message,
                itemData = data,
            }
        end
        -- Item have an option to pick up item
        local options = {
            {
                Text = SHARED.t('inventory.pickUpItem'),
                Input = '/Game/Helix/Input/Actions/IA_Interact.IA_Interact',
                Action = function(Drop, Instigator)
                    local controller = Instigator and Instigator:GetController()
                    if controller then
                        TriggerClientEvent(controller, 'pickUpItem', { containerId = spawnResult.entityId })
                    end
                end,
            }
        }
        -- If item have containerId then it will have an option to open container inventory
        if item.info.containerId then
            table.insert(options, {
                Text = SHARED.t('inventory.openDrop'),
                Input = '/Game/Helix/Input/Actions/IA_Weapon_Reload.IA_Weapon_Reload',
                Action = function(Drop, Instigator)
                    local controller = Instigator and Instigator:GetController()
                    if controller then
                        TriggerClientEvent(controller, 'openContainerInventory', { containerId = spawnResult.entityId })
                    end
                end,
            })
        end
        -- Spawn success
        local addInteractableResult = self.core.gameManager:addInteractable({
            entityId = spawnResult.entityId,
            entity = spawnResult.entity,
            options = options,
        })
        if not addInteractableResult.status then
            -- Add item back to player's inventory
            container:addItem(data.itemName, data.amount, data.fromSlot, dropItem.info)
            -- On failed to create interactable => Destroy bag
            DeleteEntity(spawnResult.entity)
            return {
                status = false,
                message = addInteractableResult.message,
                itemData = data,
            }
        end
        if item.info.containerId then
            self.containers[spawnResult.entityId].entity = spawnResult.entity
            self.containers[spawnResult.entityId].interactableEntity = addInteractableResult.interactableEntity
            self.containers[spawnResult.entityId].position = SpawnPosition
            self.containers[spawnResult.entityId].rotation = PawnRotation
            self.containers[spawnResult.entityId].holderItem = {
                name = dropItem.name,
                amount = dropItem.amount,
                info = dropItem.info,
            }
        else
            -- Add container to dictionary (dropItem already has slot = 1)
            local dropContainer = SContainer.new(self.core, spawnResult.entityId, player.playerData.citizenId)
            dropContainer:initEntity({
                entityId = spawnResult.entityId,
                entity = spawnResult.entity,
                interactableEntity = addInteractableResult.interactableEntity,
                position = SpawnPosition,
                rotation = PawnRotation,
                items = {
                    [1] = dropItem,
                },
                maxSlot = 1, -- Drop item should only have 1 slot
                maxWeight = SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT,
                isDestroyOnEmpty = true
            })
            self.containers[spawnResult.entityId] = dropContainer
        end
        -- Save container to db
        self.containers[spawnResult.entityId]:save()

        return {
            status = true,
            message = 'Drop item created successfully!',
            itemData = data,
        }
    end

    --- Split item
    ---@param source PlayerController player controller
    ---@param data {slot: number} item data
    function self:splitItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        if data.slot <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            return player.inventory:splitItem(data.slot)
        else
            local backpack = player.inventory:getBackpackContainer()
            if backpack then
                local backpackSlot = data.slot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
                return backpack:splitItem(backpackSlot)
            end
        end
        return {
            status = false,
            message = 'Container not found!',
        }
    end

    --- Use item
    ---@param source PlayerController player controller
    ---@param data {itemName: string; slot: number} item data
    function self:useItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        local itemInfo = nil
        if data.slot <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            -- Inventory
            itemInfo = player.inventory:getItemBySlot(data.slot)
        else
            local backpack = player.inventory:getBackpackContainer()
            if backpack then
                local backpackSlot = data.slot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
                itemInfo = backpack:getItemBySlot(backpackSlot)
            end
        end
        -- Verify item at slot
        if not itemInfo then
            self.core.cheatDetector:logCheater({
                action = 'useItem',
                player = player or nil,
                citizenId = player.playerData.citizenId or '',
                license = player.playerData.license or '',
                name = player.playerData.name or '',
                content = ('[ERROR] sInventoryManager.useItem: Item %s not found in inventory!'):format(data.itemName)
            })
            return {
                status = false,
                message = SHARED.t('error.itemNotFound'),
            }
        end
        -- Verify that slot item matches with data.itemName
        if itemInfo.name ~= data.itemName then
            self.core.cheatDetector:logCheater({
                action = 'useItem',
                player = player or nil,
                citizenId = player.playerData.citizenId or '',
                license = player.playerData.license or '',
                name = player.playerData.name or '',
                content = ('[ERROR] sInventoryManager.useItem: Item %s does not match!'):format(data.itemName)
            })
            return {
                status = false,
                message = SHARED.t('error.itemNotFound'),
            }
        end
        -- Player are allowed to use item
        local result = self.core:useItem(player, data)
        if result.status then
            -- Each use should only remove 1 item
            if data.slot <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
                player.inventory:removeItem(data.itemName, 1, data.slot)
            else
                local backpack = player.inventory:getBackpackContainer()
                if backpack then
                    local backpackSlot = data.slot - SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS
                    backpack:removeItem(data.itemName, 1, backpackSlot)
                end
            end

            player.missionManager:triggerAction('use', {
                item = data.itemName,
                slot = data.slot,
                amount = 1,
                info = itemInfo.info,
            })
        end
        return result
    end

    ---Wear item
    ---@param source PlayerController player controller
    ---@param data {itemName: string; slot: number} item data
    function self:wearItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        local container = nil
        local containerType = ''
        if data.slot <= SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS then
            container = player.inventory
            containerType = 'inventory'
        else
            containerType = 'backpack'
            local backpack = player.inventory:getBackpackContainer()
            if backpack then
                container = backpack
            end
        end
        if not container then
            return {
                status = false,
                message = SHARED.t('error.itemNotFound'),
            }
        end
        local itemInfo = container:getItemBySlot(data.slot)
        if not itemInfo then
            return {
                status = false,
                message = SHARED.t('error.itemNotFound'),
            }
        end
        local itemClothType = SHARED.getClothItemTypeByName(itemInfo.name)
        if not itemClothType then
            return {
                status = false,
                message = SHARED.t('error.itemNotCloth'),
            }
        end
        return player.equipment:equipItem(itemInfo.name, data.slot)
    end

    ---Unequip item
    ---@param source PlayerController player controller
    ---@param data {itemName: string; toSlotNumber: number} item data
    function self:unequipItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        local clothType = SHARED.getClothItemTypeByName(data.itemName)
        if not clothType then
            -- This should no happen. Because item that being equipped must be a cloth item
            return {
                status = false,
                message = SHARED.t('error.itemNotCloth'),
            }
        end

        return player.equipment:unequipItem(clothType, data.toSlotNumber or nil)
    end

    --- Pick up item from container
    ---@param source PlayerController player controller
    ---@param data {containerId: string} data
    ---@return {status: boolean; message: string} result of picking up item
    function self:onPickUpItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        local containerResult = self:openContainerId(data.containerId)
        if not containerResult.status then
            return {
                status = false,
                message = containerResult.message,
            }
        end
        -- Get container position 
        local containerPosition = containerResult.container.entity:K2_GetActorLocation()
        local playerPosition = player:getCoords()
        local distance = GetDistanceBetweenCoords(playerPosition, containerPosition)
        -- If item is too far away, return error
        if distance > 300 then
            return {
                status = false,
                message = 'Item is too far away!',
            }
        end
        local canAddItemsResult = player:canAddContainerItems(data.containerId)
        if not canAddItemsResult.status then
            return {
                status = false,
                message = canAddItemsResult.message,
            }
        end
        if containerResult.container.holderItem then
            -- TODO: add container to item
            local addHolderItemResult = player:addItem(containerResult.container.holderItem.name, containerResult.container.holderItem.amount, containerResult.container.holderItem.info, nil, false)
            if not addHolderItemResult.status then
                return {
                    status = false,
                    message = addHolderItemResult.message,
                }
            end
        end
        -- Weight and Slot limit passed => Add items to player's inventory
        for _, value in ipairs(containerResult.container.items) do
            local itemName = value.name
            local amount = value.amount
            local itemInfo = value.info
            local addItemResult = player:addItem(itemName, amount, itemInfo, nil, false)
            if not addItemResult.status then
                return {
                    status = false,
                    message = addItemResult.message,
                }
            end
        end
        
        -- Sync inventory to client (Sync when all items are added)
        player.inventory:sync()
        
        -- Reset: position, rotation, interactableEntity, entity on success
        self.containers[data.containerId].position = nil
        self.containers[data.containerId].rotation = nil
        self.containers[data.containerId].timeExpired = nil
        -- Destroy entity and interactable entity
        self.containers[data.containerId]:destroy()

        return {
            status = true,
            message = 'Items picked up from container!',
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SInventoryManager

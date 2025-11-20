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

    local function onServerLoad()
    end

    ---Contructor function
    local function _contructor()

         --- In-game Events
         --- Open Inventory
         RegisterCallback('onOpenInventory', function(source, data)
            return self:onOpenInventory(source, data)
        end)

        --- Open Container Inventory
        RegisterCallback('onOpenContainerInventory', function(source, data)
            return self:onOpenInventory(source, data)
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
            local result = player.inventory:addItem(data.itemName, data.amount)
            return {
                status = result.status,
                message = result.message,
            }
        end)
    end

    ---On shutdown
    function self:onShutdown()
        for _, container in pairs(self.containers) do
            container:save()
        end
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---On open inventory
    ---@param source PlayerController player controller
    ---@param data {type:'player' | 'container'; containerId:string|nil} data
    ---@return TInventoryOpenInventoryResultType result
    function self:onOpenInventory(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get player by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        -- Get player's inventory and equipment
        local result = player.inventory:openInventory()
        if data.type == 'container' then
            local container = self.containers[data.containerId]
            if not container then
                return {
                    status = false,
                    message = 'Container not found!',
                }
            end
            result.container = {
                id = container.id,
                items = container.items,
                capacity = {
                    weight = container.maxWeight,
                    slots = container.maxSlot,
                }
            }
        end
        -- Open inventory
        print('[TPN][SERVER] onOpenInventory - result: ', JSON.stringify(result))

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
        return container.items[slot] or nil
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
            return player.inventory:findItemBySlot(slot)
        elseif group == 'equipment' then
            ---@cast slot number
            local clothType = getEquipmentClothTypeFromSlot(slot)
            if not clothType then
                return nil
            end
            return player.equipment:findItemByClothType(clothType)
        elseif group == 'container' and sourceGroupId ~= nil then
            return getItemFromContainer(sourceGroupId, slot)
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
        -- Moving from inventory to equipment
        if sourceGroup == 'inventory' and targetGroup == 'equipment' then
            local clothType = SHARED.getClothItemTypeByName(sourceItem.name)
            if not clothType then
                return {
                    status = false,
                    message = SHARED.t('error.itemNotCloth'),
                }
            end
            local equipResult = player.equipment:equipItem(sourceItem.name, targetSlot)
            print('[TPN][SERVER] moveItemDifferentGroup - equipResult: ', JSON.stringify(equipResult))
            return {
                status = equipResult.status,
                message = equipResult.message,
                slot = targetSlot,
            }
        end
        
        -- Moving from equipment to inventory
        if sourceGroup == 'equipment' and targetGroup == 'inventory' then
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
                        content = ('[ERROR] SInventoryManager.onMoveInventoryItem: Item %s is not a cloth item! Player trying to un-equip item that is not a cloth item!'):format(sourceItem.name)
                    })
                    return {
                        status = false,
                        message = 'Item is not a cloth item!',
                    }
                end

                -- Have target item => un-equip clothes
                local unequipResult = player.equipment:unequipItem(clothType, targetSlot)
                print('[TPN][SERVER] moveItemDifferentGroup - unequipResult: ', JSON.stringify(unequipResult))
                return {
                    status = unequipResult.status,
                    message = unequipResult.message,
                    slot = targetSlot,
                }
            else
                -- No target item => Move item to target slot
                local moveResult = player.inventory:moveItem(sourceItem, targetSlot)
                print('[TPN][SERVER] moveItemDifferentGroup - moveResult: ', JSON.stringify(moveResult))
                return {
                    status = moveResult.status,
                    message = moveResult.message,
                    slot = targetSlot,
                }
            end
            
            return {
                status = true,
                message = 'Item moved from equipment to inventory!',
            }
        end
        
        -- Moving from inventory to container
        if sourceGroup == 'inventory' and targetGroup == 'container' then
            ---@type SContainer|nil container
            local container = self.containers[targetGroupId]
            if not container then
                return {
                    status = false,
                    message = 'Container not found!',
                }
            end

            local removeResult = player.inventory:removeItem(sourceItem.name, sourceItem.amount, sourceSlot)
            if not removeResult.status then
                return {
                    status = false,
                    message = removeResult.message,
                }
            end
            local addResult = container:addItem(sourceItem.name, sourceItem.amount, targetSlot, sourceItem.info)
            if not addResult.status then
                -- Rollback item to inventory
                player.inventory:addItem(sourceItem.name, sourceItem.amount, sourceSlot, sourceItem.info)
                return {
                    status = false,
                    message = addResult.message,
                }
            end

            return {
                status = true,
                message = 'Item moved from inventory to container!',
                slot = targetSlot,
            }
        end
        -- Moving from container to inventory
        if sourceGroup == 'container' and targetGroup == 'inventory' then
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

            return {
                status = true,
                message = 'Item moved from container to inventory!',
                slot = targetSlot,
            }
        end

        -- [TODO] Moving from/to other groups (not implemented yet)
        if sourceGroup == 'container' and targetGroup == 'equipment' then
            return {
                status = false,
                message = 'Moving items to/from other groups is not implemented yet!',
            }
        end

        -- [TODO] Moving from/to other groups (not implemented yet)
        if sourceGroup == 'equipment' and targetGroup == 'container' then
            return {
                status = false,
                message = 'Moving items to/from other groups is not implemented yet!',
            }
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
            return player.inventory:moveItem(sourceItem, targetSlot)
        elseif sourceGroup == 'equipment' then
            return {
                status = false,
                message = 'Equipment does not support swapping items!',
            }
        elseif sourceGroup == 'container' then
            -- TODO: Handle other inventory types (ground, other player, etc.)
            local container = self.containers[sourceGroupId]
            if not container then
                return {
                    status = false,
                    message = 'Container not found!',
                }
            end
            return container:moveItem(sourceItem, targetSlot)
        end

        return {
            status = true,
            message = 'Item moved successfully!',
        }
    end

    ---On move inventory item
    ---@param source PlayerController player controller
    ---@param data {sourceSlot: number; targetSlot: number; sourceGroup: string; targetGroup: string; sourceGroupId: string|nil; targetGroupId: string|nil} data
    ---@return {status: boolean; message: string; slot:number} result of moving item
    function self:onMoveInventoryItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get player by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        print('[SERVER][INFO] SInventoryManager.onMoveInventoryItem - data: ', JSON.stringify(data))
        
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

        -- Get source item
        local sourceItem = getItemFromGroup(player, sourceGroup, sourceSlot, sourceGroupId, targetGroupId)
        if not sourceItem then
            self.core.cheatDetector:logCheater({
                action = 'moveInventoryItem',
                player = player or nil,
                citizenId = player.playerData.citizenId or '',
                license = player.playerData.license or '',
                name = player.playerData.name or '',
                content = ('[ERROR] SInventoryManager.onMoveInventoryItem: Source item not found in slot %s! Player trying to move item that they don\'t have in their inventory!'):format(sourceSlot)
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
            result = moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, sourceSlot, targetSlot, sourceGroupId, targetGroupId)
        end
        
        -- Return the result from the move function
        return result or {
            status = false,
            message = 'Move operation failed!',
        }
    end

    ---Create drop item
    ---@param source PlayerController player controller
    ---@param data {itemName: string, amount: number, fromSlot: number} data
    ---@return TResponseCreateDropItem result of creating drop item
    function self:createDropItem(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get player by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
                itemData = data,
            }
        end
        local playerPawn = GetPlayerPawn(source)
        local playerCoords = GetEntityCoords(playerPawn)
        local PawnRotation = GetEntityRotation(playerPawn)
        local ForwardVec = playerPawn:GetActorForwardVector()
        local SpawnPosition = playerCoords + (ForwardVec * 200)
        PawnRotation.Yaw = PawnRotation.Yaw
        -- Get item from player's inventory
        local item = player.inventory:findItemBySlot(data.fromSlot)
        if not item then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get item by slot!')
            self.core.cheatDetector:logCheater({
                action = 'createDropItem',
                player = player or nil,
                citizenId = player.playerData.citizenId or '',
                license = player.playerData.license or '',
                name = player.playerData.name or '',
                content = ('[ERROR] SInventoryManager.createDropItem: Item not found in inventory! Player trying to create drop item that they don\'t have in their inventory!'):format(data.fromSlot)
            })
            return {
                status = false,
                message = 'Item not found in inventory!',
                itemData = data,
            }
        end
        -- Remove item from player's inventory
        local removeResult = player.inventory:removeItem(data.itemName, data.amount, data.fromSlot)
        if not removeResult.status then
            return {
                status = false,
                message = removeResult.message,
                itemData = data,
            }
        end
        local worldItem = SHARED.getWorldItemPath(data.itemName)
        -- Spawn bag
        local spawnResult = self.core.gameManager:spawnStaticMesh({
            entityPath = worldItem.path,
            position = SpawnPosition,
            rotation = PawnRotation,
            scale = worldItem.scale,
            collisionType = ECollisionType.IgnoreOnlyPawn,
            mobilityType = EMobilityType.Movable,
        })
        if not spawnResult.status then
            -- Spawn failed => Add item back to player's inventory
            player.inventory:addItem(data.itemName, data.amount, data.fromSlot, item.info)
            return {
                status = false,
                message = spawnResult.message,
                itemData = data,
            }
        end
        
        local options = {
            {
                Text = 'Open Drop',
                Input = '/Game/Helix/Input/Actions/IA_Interact.IA_Interact',
                Action = function(Drop, Instigator)
                    print('[TPN][SERVER] createDropItem - Open bag!')
                    local controller = Instigator and Instigator:GetController()
                    if controller then
                        TriggerClientEvent(controller, 'openContainerInventory', { containerId = spawnResult.entityId })
                    end
                end,
            }
        }
        -- Spawn success
        local addInteractableResult = self.core.gameManager:addInteractable({
            entityId = spawnResult.entityId,
            entity = spawnResult.entity,
            options = options,
        })
        if not addInteractableResult.status then
            -- Add item back to player's inventory
            player.inventory:addItem(data.itemName, data.amount, data.fromSlot, item.info)
            -- Destroy bag
            self.core.gameManager:destroyEntity(spawnResult.entityId)
            return {
                status = false,
                message = addInteractableResult.message,
                itemData = data,
            }
        end

        -- Set item slot to 1 (Because player are drop)
        item.slot = 1
        -- Add container to dictionary
        local container = SContainer.new(self.core, spawnResult.entityId, player.playerData.citizenId)
        container:initEntity({
            entityId = spawnResult.entityId,
            entity = spawnResult.entity,
            items = {
                [1] = item,
            },
            maxSlot = SHARED.CONFIG.INVENTORY_CAPACITY.SLOTS,
            maxWeight = SHARED.CONFIG.INVENTORY_CAPACITY.WEIGHT,
        })
        self.containers[spawnResult.entityId] = container

        return {
            status = true,
            message = 'Drop item created successfully!',
            itemData = data,
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SInventoryManager

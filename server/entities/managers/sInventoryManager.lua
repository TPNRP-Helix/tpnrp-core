---@class SInventoryManager
---@field core TPNRPServer Core
SInventoryManager = {}
SInventoryManager.__index = SInventoryManager

---@param core TPNRPServer Core
---@return SInventoryManager
function SInventoryManager.new(core)
    ---@class SInventoryManager
    local self = setmetatable({}, SInventoryManager)

    -- Core
    self.core = core

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
         --- In-game Events
         RegisterCallback('onOpenInventory', function(source, data)
            return self:onOpenInventory(source, data)
        end)

        RegisterCallback('onMoveInventoryItem', function(source, data)
            return self:onMoveInventoryItem(source, data)
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

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---On open inventory
    ---@param source PlayerController player controller
    ---@param data table data
    ---@return {status: boolean; message: string; inventory: table<number, SInventoryItemType>|nil} result
    function self:onOpenInventory(source, data)
        local player = self.core:getPlayerBySource(source)
        if not player then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get player by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetPlayer'),
            }
        end
        print('[TPN][SERVER] onOpenInventory - data: ', JSON.stringify(data))
        -- Open inventory
        local result = player.inventory:openInventory(data)
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

    ---Get item from a specific group and slot
    ---@param player SPlayer player entity
    ---@param group 'inventory' | 'equipment' | 'other' group type
    ---@param slot number slot number (numeric for inventory, equipment slot number for equipment)
    ---@return table | nil item data or nil
    local function getItemFromGroup(player, group, slot)
        if group == 'inventory' then
            ---@cast slot number
            return player.inventory:findItemBySlot(slot)
        elseif group == 'equipment' then
            ---@cast slot number
            local clothType = getEquipmentClothTypeFromSlot(slot)
            if not clothType then
                return nil
            end
            return player.equipment.items[clothType]
        elseif group == 'other' then
            -- TODO: Handle other inventory types (ground, other player, etc.)
            return nil
        end
        return nil
    end

    ---Move item between different groups
    ---@param player SPlayer player entity
    ---@param sourceItem SInventoryItemType|SEquipmentItemType source item data
    ---@param targetItem SInventoryItemType|SEquipmentItemType|nil target item data
    ---@param sourceGroup 'inventory' | 'equipment' | 'other' source group type
    ---@param targetGroup 'inventory' | 'equipment' | 'other' target group type
    ---@param sourceSlot number source slot number
    ---@param targetSlot number target slot number
    ---@return {status: boolean; message: string; slot:number} result of moving item
    local function moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, sourceSlot, targetSlot)
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
        
        -- [TODO] Moving from/to other groups (not implemented yet)
        if sourceGroup == 'inventory' and targetGroup == 'other' then
            return {
                status = false,
                message = 'Moving items to/from other groups is not implemented yet!',
            }
        end
        -- [TODO] Moving from/to other groups (not implemented yet)
        if sourceGroup == 'other' and targetGroup == 'inventory' then
            return {
                status = false,
                message = 'Moving items to/from other groups is not implemented yet!',
            }
        end

        -- [TODO] Moving from/to other groups (not implemented yet)
        if sourceGroup == 'other' and targetGroup == 'equipment' then
            return {
                status = false,
                message = 'Moving items to/from other groups is not implemented yet!',
            }
        end

        -- [TODO] Moving from/to other groups (not implemented yet)
        if sourceGroup == 'equipment' and targetGroup == 'other' then
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
    local function moveItemSameGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, targetSlot)
        if sourceGroup ~= targetGroup then
            return {
                status = false,
                message = 'Source group and target group are different!',
            }
        end

        if sourceGroup == 'inventory' then
            local result = player.inventory:moveItem(sourceItem, targetSlot)
            print('[TPN][SERVER] moveItemSameGroup - result: ', JSON.stringify(result))
            return result
        elseif sourceGroup == 'equipment' then
            return {
                status = false,
                message = 'Equipment does not support swapping items!',
            }
        elseif sourceGroup == 'other' then
            -- TODO: Handle other inventory types (ground, other player, etc.)
            return {
                status = false,
                message = 'Other does not support swapping items yet!',
            }
        end

        return {
            status = true,
            message = 'Item moved successfully!',
        }
    end

    ---On move inventory item
    ---@param source PlayerController player controller
    ---@param data {sourceSlot: number; targetSlot: number; sourceGroup: string; targetGroup: string} data
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
        local sourceItem = getItemFromGroup(player, sourceGroup, sourceSlot)
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

        local targetItem = getItemFromGroup(player, targetGroup, targetSlot)
        local result = nil
        if sourceGroup == targetGroup then
            -- Same group => Move item to target slot
            result = moveItemSameGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, targetSlot)
        else
            -- Different group => Move item to target slot
            result = moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup, sourceSlot, targetSlot)
        end
        
        -- Return the result from the move function
        return result or {
            status = false,
            message = 'Move operation failed!',
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SInventoryManager

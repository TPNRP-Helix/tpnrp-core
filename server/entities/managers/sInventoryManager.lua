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

    local function moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup)
        -- TODO: Move item to target slot
    end

    local function moveItemSameGroup(player, sourceItem, targetItem, sourceGroup, targetGroup)
        -- TODO: Move item to target slot
        if sourceGroup ~= targetGroup then
            return {
                status = false,
                message = 'Source group and target group are different!',
            }
        end

        if sourceGroup == 'inventory' then
            if not targetItem then
                -- No target item => Move item to target slot
                player.inventory:moveItem(sourceItem, targetSlot)
            else
                -- Have target item => Swap slot
                player.inventory:swapItem(sourceItem, targetItem)
            end
        elseif sourceGroup == 'equipment' then

        end
    end

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
        if sourceGroup == targetGroup then
            -- Same group => Move item to target slot
            moveItemSameGroup(player, sourceItem, targetItem, sourceGroup, targetGroup)
        else
            -- Different group => Move item to target slot
            moveItemDifferentGroup(player, sourceItem, targetItem, sourceGroup, targetGroup)
        end
        
        
        return {
            status = true,
            message = 'Item moved successfully!',
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SInventoryManager

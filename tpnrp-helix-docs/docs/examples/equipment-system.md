# Equipment System Examples

Examples of how to work with the equipment system.

## Getting Backpack Capacity

```lua
local player = TPNRPServer:getPlayerBySource(source)
if player and player.equipment then
    -- Get backpack capacity
    local capacity = player.equipment:getBackpackCapacity()
    if capacity.status then
        print("Inventory slots: " .. capacity.slots)
        print("Weight limit: " .. capacity.weightLimit .. " grams")
    else
        print("No backpack equipped")
    end
end
```

## Using Capacity for Inventory Checks

```lua
-- Check if can add item based on backpack capacity
local capacity = player.equipment:getBackpackCapacity()
if capacity.status then
    local canAdd = player.inventory:canAddItem('bread', 5)
    if canAdd.status then
        -- Backpack has capacity
        player.inventory:addItem('bread', 5)
    else
        print("Cannot add: " .. canAdd.message)
    end
end
```

## Equipment Integration with Inventory

```lua
-- When player equips a bag, it affects inventory capacity
function onPlayerEquipBag(player, bagItem)
    -- Equipment is already updated
    
    -- Get new capacity
    local capacity = player.equipment:getBackpackCapacity()
    if capacity.status then
        print("New inventory capacity:")
        print("- Slots: " .. capacity.slots)
        print("- Weight: " .. capacity.weightLimit .. " grams")
    end
    
    -- Save equipment
    player.equipment:save()
end
```

## Saving Equipment

```lua
-- Save equipment changes
local success = player.equipment:save()
if success then
    print("Equipment saved")
else
    print("Failed to save equipment")
end
```

## Complete Example: Equipment Check

```lua
-- Check player's equipment status
RegisterCommand('checkequipment', function(source, args)
    local player = TPNRPServer:getPlayerBySource(source)
    if not player then return end
    
    local capacity = player.equipment:getBackpackCapacity()
    if capacity.status then
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            multiline = true,
            args = {"Equipment", 
                "Backpack Capacity:\n" ..
                "Slots: " .. capacity.slots .. "\n" ..
                "Weight: " .. capacity.weightLimit .. " grams"
            }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = true,
            args = {"Equipment", "No backpack equipped"}
        })
    end
end)
```


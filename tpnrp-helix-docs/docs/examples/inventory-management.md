# Inventory Management Examples

Examples of how to work with the inventory system.

## Adding Items

### Basic Add

```lua
local player = TPNRPServer:getPlayerBySource(source)
if player and player.inventory then
    -- Add item (automatically finds slot)
    local result = player.inventory:addItem('bread', 5)
    if result.status then
        print("Item added to slot: " .. result.slot)
    else
        print("Failed: " .. result.message)
    end
end
```

### Add with Slot Number

```lua
-- Add item to specific slot
local result = player.inventory:addItem('bread', 5, 1)
if result.status then
    print("Item added to slot: " .. result.slot)
end
```

### Add with Metadata

```lua
-- Add item with custom info/metadata
local result = player.inventory:addItem('bread', 5, nil, {
    quality = 'fresh',
    expiry = os.time() + 86400
})
if result.status then
    print("Item added with metadata")
end
```

## Removing Items

### Basic Remove

```lua
-- Remove item (finds item automatically)
local result = player.inventory:removeItem('bread', 2)
if result.status then
    print("Item removed from slot: " .. result.slot)
end
```

### Remove from Specific Slot

```lua
-- Remove from specific slot
local result = player.inventory:removeItem('bread', 2, 1)
if result.status then
    print("Item removed from slot: " .. result.slot)
end
```

## Checking Items

### Check if Has Item

```lua
-- Check if player has item
if player.inventory:hasItem('bread', 5) then
    print("Player has at least 5 bread")
end
```

### Get Item Count

```lua
-- Get total count of item
local count = player.inventory:getItemCount('bread')
print("Player has " .. count .. " bread")
```

### Get Item by Slot

```lua
-- Get item from specific slot
local item = player.inventory:getItem(1)
if item then
    print("Slot 1: " .. item.name .. " x" .. item.amount)
end
```

## Inventory Capacity

### Check if Can Add Item

```lua
-- Check if item can be added
local canAdd = player.inventory:canAddItem('water', 10)
if canAdd.status then
    -- Safe to add item
    player.inventory:addItem('water', 10)
else
    print("Cannot add: " .. canAdd.message)
end
```

### Calculate Total Weight

```lua
-- Get total inventory weight
local totalWeight = player.inventory:calculateTotalWeight()
print("Total weight: " .. totalWeight .. " grams")

-- Check against limit
local capacity = player.equipment:getBackpackCapacity()
if capacity.status then
    local availableWeight = capacity.weightLimit - totalWeight
    print("Available weight: " .. availableWeight .. " grams")
end
```

### Get Empty Slot

```lua
-- Find empty slot
local emptySlot = player.inventory:getEmptySlot()
if emptySlot then
    print("Empty slot found: " .. emptySlot)
else
    print("No empty slots available")
end
```

## Saving Inventory

```lua
-- Save inventory to database
local success = player.inventory:save()
if success then
    print("Inventory saved")
else
    print("Failed to save inventory")
end
```

## Complete Example: Give Item Command

```lua
-- Server command to give item
RegisterCommand('giveitem', function(source, args)
    local player = TPNRPServer:getPlayerBySource(source)
    if not player then return end
    
    local itemName = args[1]
    local amount = tonumber(args[2]) or 1
    
    -- Check if can add
    local canAdd = player.inventory:canAddItem(itemName, amount)
    if not canAdd.status then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", canAdd.message}
        })
        return
    end
    
    -- Add item
    local result = player.inventory:addItem(itemName, amount)
    if result.status then
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            multiline = true,
            args = {"System", "You received " .. amount .. "x " .. itemName}
        })
        
        -- Save inventory
        player.inventory:save()
    end
end, true)
```


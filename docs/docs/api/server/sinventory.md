# SInventory API

The `SInventory` entity manages player inventory on the server-side.

## Class Definition

```lua
---@class SInventory
---@field player SPlayer
---@field items table<number, SInventoryItemType>
---@field type 'player' | 'stack' | ''
```

## Constructor

### `SInventory.new(player)`

Creates a new SInventory instance.

**Parameters:**
- `player` (SPlayer): Owner player entity

**Returns:**
- `SInventory`: New SInventory instance

**Example:**
```lua
local inventory = SInventory.new(player)
```

## Methods

### `save()`

Saves inventory to the database.

**Returns:**
- `boolean`: True if save successful, false otherwise

**Example:**
```lua
local success = inventory:save()
```

### `load(type)`

Loads inventory from the database by type.

**Parameters:**
- `type` ('player' | 'stack' | ''): Inventory type to load

**Returns:**
- `boolean`: True if load successful, false otherwise

**Note:** If type is empty string, the function returns false and doesn't load.

**Example:**
```lua
local success = inventory:load('player')
```

### `calculateTotalWeight()`

Calculates the total weight of all items in the inventory.

**Returns:**
- `number`: Total inventory weight in grams

**Example:**
```lua
local totalWeight = inventory:calculateTotalWeight()
print("Total weight: " .. totalWeight .. " grams")
```

### `canAddItem(itemName, amount)`

Checks if an item can be added to the inventory.

**Parameters:**
- `itemName` (string): Item name
- `amount` (number): Item amount

**Returns:**
- `table`: `{status=boolean, message=string}` - Result of the check

**Checks:**
- Item exists in item definitions
- Weight limit (based on backpack capacity)
- Slot limit (based on backpack capacity)

**Example:**
```lua
local result = inventory:canAddItem('bread', 5)
if result.status then
    print("Can add item")
else
    print("Cannot add: " .. result.message)
end
```

### `getEmptySlot()`

Finds an empty slot in the inventory.

**Returns:**
- `number | nil`: Slot number if found, nil otherwise

**Example:**
```lua
local slot = inventory:getEmptySlot()
if slot then
    print("Empty slot found: " .. slot)
end
```

### `findItemSlot(itemName)`

Finds the slot number of an item by name.

**Parameters:**
- `itemName` (string): Item name to search for

**Returns:**
- `number | nil`: Slot number if found, nil otherwise

**Note:** Case-insensitive search.

**Example:**
```lua
local slot = inventory:findItemSlot('bread')
if slot then
    print("Bread found in slot: " .. slot)
end
```

### `addItem(itemName, amount, slotNumber, info)`

Adds an item to the inventory.

**Parameters:**
- `itemName` (string): Item name
- `amount` (number): Item amount
- `slotNumber` (number | nil): Optional slot number
- `info` (table | nil): Optional item info/metadata

**Returns:**
- `table`: `{status=boolean, message=string, slot=number}` - Result of adding item

**Behavior:**
- If slot is provided and empty, uses that slot
- If slot is provided but occupied by same item (non-unique), stacks the item
- If slot is provided but occupied by different item, finds empty slot
- If no slot provided, finds existing item slot (non-unique) or empty slot
- Unique items always use empty slots

**Example:**
```lua
local result = inventory:addItem('bread', 5, nil, {quality = 'fresh'})
if result.status then
    print("Item added to slot: " .. result.slot)
end
```

### `removeItem(itemName, amount, slotNumber)`

Removes an item from the inventory.

**Parameters:**
- `itemName` (string): Item name
- `amount` (number): Amount to remove
- `slotNumber` (number | nil): Optional slot number

**Returns:**
- `table`: `{status=boolean, message=string, slot=number}` - Result of removing item

**Behavior:**
- If slot is provided, removes from that slot
- If no slot provided, finds item by name
- If amount exceeds item amount, removes all of that item
- If amount equals item amount, removes the entire item
- If amount is less than item amount, reduces the item amount

**Example:**
```lua
local result = inventory:removeItem('bread', 2, nil)
if result.status then
    print("Item removed from slot: " .. result.slot)
end
```

### `getItem(slotNumber)`

Gets an item from the inventory by slot number.

**Parameters:**
- `slotNumber` (number): Slot number

**Returns:**
- `SInventoryItemType | nil`: Item if found, nil otherwise

**Example:**
```lua
local item = inventory:getItem(1)
if item then
    print("Item: " .. item.name .. ", Amount: " .. item.amount)
end
```

### `hasItem(itemName, amount)`

Checks if the inventory has a specific item.

**Parameters:**
- `itemName` (string): Item name
- `amount` (number): Minimum amount required

**Returns:**
- `boolean`: True if item exists with sufficient amount, false otherwise

**Example:**
```lua
if inventory:hasItem('bread', 5) then
    print("Has enough bread")
end
```

### `getItemCount(itemName)`

Gets the total count of a specific item in the inventory.

**Parameters:**
- `itemName` (string): Item name

**Returns:**
- `number`: Total count of the item (0 if not found)

**Example:**
```lua
local count = inventory:getItemCount('bread')
print("Bread count: " .. count)
```

## Properties

### `player`
Reference to the owner player entity (`SPlayer`).

### `items`
Table containing inventory items, indexed by slot number.

### `type`
Inventory type: `'player'`, `'stack'`, or `''` (empty).

## Item Structure

```lua
{
    name = string,        -- Item name
    label = string,       -- Item label
    weight = number,      -- Item weight in grams
    type = string,        -- Item type
    image = string,       -- Item image path
    unique = boolean,     -- Is item unique?
    useable = boolean,    -- Is item useable?
    shouldClose = boolean, -- Should close UI when used?
    description = string, -- Item description
    amount = number,      -- Item amount
    slot = number,        -- Slot number
    info = table          -- Item metadata/info
}
```

## Usage Example

```lua
-- Create inventory
local inventory = SInventory.new(player)

-- Load inventory
inventory:load('player')

-- Add item
local result = inventory:addItem('bread', 10)
if result.status then
    print("Added bread to slot: " .. result.slot)
end

-- Check if can add more
local canAdd = inventory:canAddItem('water', 5)
if canAdd.status then
    inventory:addItem('water', 5)
end

-- Get item count
local breadCount = inventory:getItemCount('bread')
print("Bread count: " .. breadCount)

-- Remove item
inventory:removeItem('bread', 3)

-- Save inventory
inventory:save()
```


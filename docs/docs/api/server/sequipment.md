# SEquipment API

The `sEquipment` entity manages player equipment and clothing on the server-side.

## Class Definition

```lua
---@class sEquipment
---@field player SPlayer
---@field items table<EEquipmentClothType, sEquipmentItemType>
---@field type 'player' | 'stack' | ''
```

## Constructor

### `sEquipment.new(player)`

Creates a new sEquipment instance.

**Parameters:**
- `player` (SPlayer): Owner player entity

**Returns:**
- `sEquipment`: New sEquipment instance

**Initialization:**
- Automatically loads player equipment from database

**Example:**
```lua
local equipment = sEquipment.new(player)
```

## Methods

### `save()`

Saves equipment to the database.

**Returns:**
- `boolean`: True if save successful, false otherwise

**Example:**
```lua
local success = equipment:save()
```

### `getBackpackCapacity()`

Gets the backpack capacity (slots and weight limit) from the equipped bag.

**Returns:**
- `table`: `{status=boolean, slots=number, weightLimit=number}` - Backpack capacity

**Behavior:**
- Checks for bag item in equipment (`EEquipmentClothType.Bag`)
- Returns slots and weight limit from bag item info
- Returns `status=false` if no bag is equipped

**Example:**
```lua
local capacity = equipment:getBackpackCapacity()
if capacity.status then
    print("Slots: " .. capacity.slots)
    print("Weight limit: " .. capacity.weightLimit .. " grams")
end
```

## Properties

### `player`
Reference to the owner player entity (`SPlayer`).

### `items`
Table containing equipment items, indexed by equipment cloth type (`EEquipmentClothType`).

### `type`
Equipment type: `'player'`, `'stack'`, or `''` (empty).

## Equipment Cloth Types

Equipment items are organized by cloth types. Common types include:

- `Head`: Head equipment
- `Mask`: Mask
- `HairStyle`: Hair style
- `Torso`: Torso clothing
- `Leg`: Leg clothing
- `Bag`: Backpack/bag (affects inventory capacity)
- `Shoes`: Footwear
- `Accessories`: Accessories
- `Undershirts`: Undershirts
- `Armor`: Body armor
- `Decal`: Decals
- `Top`: Top clothing
- `Hat`: Hat
- `Glasses`: Glasses
- `Ears`: Ear accessories
- `Watch`: Watch
- `Bracelets`: Bracelets
- And more...

## Bag Capacity

The bag equipment item affects inventory capacity. The bag item should have the following structure in its `info`:

```lua
{
    slotCount = number,      -- Number of inventory slots
    WeightLimit = number     -- Weight limit in grams
}
```

## Usage Example

```lua
-- Create equipment (automatically loaded)
local equipment = sEquipment.new(player)

-- Get backpack capacity
local capacity = equipment:getBackpackCapacity()
if capacity.status then
    print("Inventory can hold:")
    print("- Slots: " .. capacity.slots)
    print("- Weight: " .. capacity.weightLimit .. " grams")
else
    print("No backpack equipped")
end

-- Save equipment changes
equipment:save()
```

## Integration with Inventory

The equipment system integrates with the inventory system:

```lua
-- When checking inventory capacity
local capacity = player.equipment:getBackpackCapacity()

-- Use in inventory operations
if capacity.status then
    local canAdd = inventory:canAddItem('bread', 5)
    -- Checks against capacity.slots and capacity.weightLimit
end
```


# Equipment API

The EquipmentDAO provides database operations for equipment data.

## Methods

### `DAO.equipment.get(citizenId)`

Gets equipment data from the database.

**Parameters:**
- `citizenId` (string): Citizen ID

**Returns:**
- `table | nil`: Equipment items if found, nil otherwise

**Example:**
```lua
local equipment = DAO.equipment.get("ABC12345")
if equipment then
    print("Equipment loaded")
end
```

### `DAO.equipment.save(equipment)`

Saves equipment data to the database.

**Parameters:**
- `equipment` (sEquipment): Equipment entity to save

**Returns:**
- `boolean`: True if save successful, false otherwise

**Saves:**
- All equipped items
- Equipment metadata

**Example:**
```lua
local success = DAO.equipment.save(equipment)
if success then
    print("Equipment saved successfully")
end
```

## Equipment Data Structure

Equipment items are stored by cloth type:

```lua
{
    [EEquipmentClothType.Head] = {
        name = string,        -- Item name
        -- ... item data
        info = table          -- Equipment metadata
    },
    [EEquipmentClothType.Bag] = {
        name = string,
        info = {
            slotCount = number,      -- Inventory slots
            WeightLimit = number     -- Weight limit
        }
    },
    -- ... more equipment items
}
```

## Usage in sEquipment

The sEquipment entity uses EquipmentDAO:

```lua
-- In constructor
local equipment = DAO.equipment.get(citizenId)

-- In save()
DAO.equipment.save(self)
```

## Database Schema

The equipment table typically stores:
- Citizen ID
- Cloth type
- Item data (JSON or separate columns)
- Metadata


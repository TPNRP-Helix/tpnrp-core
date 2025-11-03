# InventoryDAO API

The InventoryDAO provides database operations for inventory data.

## Methods

### `DAO.inventory.get(citizenId, type)`

Gets inventory data from the database.

**Parameters:**
- `citizenId` (string): Citizen ID
- `type` (string): Inventory type ('player', 'stack', etc.)

**Returns:**
- `table | nil`: Inventory items if found, nil otherwise

**Example:**
```lua
local items = DAO.inventory.get("ABC12345", "player")
if items then
    print("Inventory loaded: " .. #items .. " items")
end
```

### `DAO.inventory.save(inventory)`

Saves inventory data to the database.

**Parameters:**
- `inventory` (SInventory): Inventory entity to save

**Returns:**
- `boolean`: True if save successful, false otherwise

**Saves:**
- All items in the inventory
- Item metadata (slot, amount, info, etc.)

**Example:**
```lua
local success = DAO.inventory.save(inventory)
if success then
    print("Inventory saved successfully")
end
```

## Inventory Data Structure

Inventory items are stored with the following structure:

```lua
{
    [slot] = {
        name = string,        -- Item name
        label = string,       -- Item label
        weight = number,      -- Item weight
        type = string,        -- Item type
        image = string,       -- Item image
        unique = boolean,     -- Is unique?
        useable = boolean,   -- Is useable?
        shouldClose = boolean, -- Should close UI?
        description = string, -- Description
        amount = number,      -- Amount
        slot = number,        -- Slot number
        info = table          -- Metadata
    },
    -- ... more items
}
```

## Usage in SInventory

The SInventory entity uses InventoryDAO:

```lua
-- In load()
local items = DAO.inventory.get(citizenId, type)

-- In save()
DAO.inventory.save(self)
```

## Database Schema

The inventory table typically stores:
- Citizen ID
- Inventory type
- Slot number
- Item data (JSON or separate columns)
- Metadata


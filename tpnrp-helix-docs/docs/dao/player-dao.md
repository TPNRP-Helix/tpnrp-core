# Player API

The PlayerDAO provides database operations for player data.

## Methods

### `DAO.player.get(citizenId)`

Gets player data from the database by citizen ID.

**Parameters:**
- `citizenId` (string): Citizen ID

**Returns:**
- `PlayerData | nil`: Player data if found, nil otherwise

**Example:**
```lua
local playerData = DAO.player.get("ABC12345")
if playerData then
    print("Player found: " .. playerData.name)
end
```

### `DAO.player.save(player)`

Saves player data to the database.

**Parameters:**
- `player` (SPlayer): Player entity to save

**Returns:**
- `boolean`: True if save successful, false otherwise

**Saves:**
- Player data (citizen_id, license, name, money, etc.)
- Character information
- Job and gang data
- Position and metadata

**Example:**
```lua
local success = DAO.player.save(player)
if success then
    print("Player saved successfully")
end
```

### `DAO.player.create(playerData)`

Creates a new player in the database.

**Parameters:**
- `playerData` (table): Player data to create

**Returns:**
- `boolean`: True if creation successful, false otherwise

**Example:**
```lua
local newPlayer = {
    citizen_id = "ABC12345",
    license = "license:xxx",
    name = "John Doe",
    -- ... other fields
}
local success = DAO.player.create(newPlayer)
```

## Player Data Structure

```lua
---@class PlayerData
---@field character_id number
---@field citizen_id string
---@field license string
---@field name string
---@field money table
---@field character_info table
---@field job table
---@field gang table
---@field position Vector3
---@field metadata table
---@field netId number|nil
---@field source number|nil
```

## Usage in SPlayer

The SPlayer entity uses PlayerDAO:

```lua
-- In login()
local playerData = DAO.player.get(citizenId)

-- In save()
DAO.player.save(self)
```


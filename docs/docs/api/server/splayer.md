# SPlayer API

The `SPlayer` entity represents a player on the server-side and manages player state and data.

## Class Definition

```lua
---@class SPlayer
---@field playerSource number
---@field playerData PlayerData|nil
---@field inventory SInventory|nil
---@field equipment sEquipment|nil
```

## Constructor

### `SPlayer.new(playerSource)`

Creates a new SPlayer instance.

**Parameters:**
- `playerSource` (number): The player source

**Returns:**
- `SPlayer`: New SPlayer instance

**Initialization:**
- Automatically loads player data from database
- Initializes inventory and equipment entities

**Example:**
```lua
local player = SPlayer.new(source)
```

## Methods

### `save()`

Saves player data to the database.

**Returns:**
- `boolean`: True if save was successful, false otherwise

**What it saves:**
- Player data via `DAO.player.save()`
- Inventory data via `inventory:save()`
- Equipment data via `equipment:save()`

**Example:**
```lua
local success = player:save()
if success then
    print("Player saved successfully")
else
    print("Failed to save player")
end
```

### `getCoords()`

Gets the player's current coordinates.

**Returns:**
- `vector3`: Player's coordinates (x, y, z)
- Falls back to `SHARED.CONFIG.DEFAULT_SPAWN.POSITION` if ped is not available

**Example:**
```lua
local coords = player:getCoords()
print("X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z)
```

### `getHeading()`

Gets the player's current heading (rotation on Y-axis).

**Returns:**
- `number`: Player's heading in degrees (0-360)
- Falls back to `SHARED.CONFIG.DEFAULT_SPAWN.HEADING` if ped is not available

**Example:**
```lua
local heading = player:getHeading()
print("Heading: " .. heading)
```

### `updatePlayerData()`

Synchronizes player data to the client-side.

**Triggers:**
- `TPN:player:updatePlayerData` event on client with current player data

**Example:**
```lua
-- Update player data and sync to client
player.playerData.money = 5000
player:updatePlayerData()
```

### `login()`

Handles player login process.

**What it does:**
- Loads player data from database via `DAO.player.get()`
- Sets player source and network ID
- Extracts license and name from Helix player state

**Returns:**
- `boolean`: True if login successful, false otherwise

**Example:**
```lua
local success = player:login()
if success then
    print("Player logged in: " .. player.playerData.name)
end
```

### `logout()`

Handles player logout process.

**What it does:**
- Triggers `TPN:client:onPlayerUnloaded` event on client
- Triggers `TPN:server:onPlayerUnloaded` event on server
- Saves player data to database
- Removes player from TPNRPServer.players table

**Example:**
```lua
-- Called automatically on player disconnect
player:logout()
```

## Properties

### `playerSource`
The player source identifier.

### `playerData`
Player data containing:
- `character_id`: Character ID
- `citizen_id`: Citizen ID
- `license`: Player license
- `name`: Player name
- `money`: Money data
- `character_info`: Character information
- `job`: Job data
- `gang`: Gang data
- `position`: Player position
- `metadata`: Additional metadata
- `netId`: Network ID
- `source`: Player source

### `inventory`
Reference to the player's inventory entity (`SInventory`).

### `equipment`
Reference to the player's equipment entity (`sEquipment`).

## Usage Example

```lua
-- Create player
local player = SPlayer.new(source)

-- Login player
player:login()

-- Access player data
print("Citizen ID: " .. player.playerData.citizen_id)
print("Player name: " .. player.playerData.name)

-- Update player data
player.playerData.money = 5000
player:updatePlayerData()

-- Save player
player:save()

-- Logout player (on disconnect)
player:logout()
```


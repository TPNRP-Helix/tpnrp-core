# CPlayer API

The `CPlayer` entity represents a player on the client-side.

## Class Definition

```lua
---@class CPlayer
---@field playerSource number
---@field license string
---@field playerData PlayerData|nil
---@field inventories SInventory|nil
```

## Constructor

### `CPlayer.new(playerSource, playerLicense)`

Creates a new CPlayer instance.

**Parameters:**
- `playerSource` (number): The player source
- `playerLicense` (string): Player license identifier

**Returns:**
- `CPlayer`: New CPlayer instance

**Example:**
```lua
local player = CPlayer.new(source, license)
```

## Methods

### `getCoords()`

Gets the player's current coordinates.

**Returns:**
- `Vector3`: Player's coordinates (x, y, z)
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

## Events

### `TPN:player:updatePlayerData`

Triggered when player data is updated from the server.

**Parameters:**
- `playerData` (PlayerData): Updated player data

**Example:**
```lua
RegisterClientEvent('TPN:player:updatePlayerData', function(playerData)
    -- Handle player data update
    print("Player data updated")
end)
```

## Properties

### `playerSource`
The player source identifier.

### `license`
The player's license identifier.

### `playerData`
Player data received from the server. Updated via `TPN:player:updatePlayerData` event.

### `inventories`
Reference to inventory entities (if any).


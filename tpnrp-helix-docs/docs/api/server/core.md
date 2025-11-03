# Server Core API

The `TPNRPServer` is the main server-side instance of TPNRP Core.

## Class Definition

```lua
---@class TPNRPServer
---@field players table<number, SPlayer>
---@field shared table Shared module (exported)
---@field useableItems table<string, function> Useable items registry
```

## Access

```lua
local TPNRP = exports['tpnrp-core']:core()
```

## Properties

### `players`
Table containing all active players, indexed by player source.

### `shared`
Reference to the shared module, exported for other resources.

### `useableItems`
Registry of useable items and their callbacks.

## Methods

### `getPlayerBySource(source)`

Gets a player by their source identifier.

**Parameters:**
- `source` (number): Player source identifier

**Returns:**
- `SPlayer | nil`: Player entity if found, nil otherwise

**Example:**
```lua
local player = TPNRPServer:getPlayerBySource(source)
if player then
    print("Player found: " .. player.playerData.name)
end
```

### `getPlayerByLicense(license)`

Gets a player by their license identifier.

**Parameters:**
- `license` (string): Player license identifier

**Returns:**
- `SPlayer | nil`: Player entity if found, nil otherwise

**Example:**
```lua
local player = TPNRPServer:getPlayerByLicense(license)
if player then
    print("Player found: " .. player.playerData.name)
end
```

### `getPlayerByCitizenId(citizenId)`

Gets a player by their citizen ID.

**Parameters:**
- `citizenId` (string): Citizen ID

**Returns:**
- `SPlayer | nil`: Player entity if found, nil otherwise

**Example:**
```lua
local player = TPNRPServer:getPlayerByCitizenId("ABC12345")
if player then
    print("Player found: " .. player.playerData.name)
end
```

### `createCitizenId()`

Creates a new unique citizen ID.

**Returns:**
- `string`: New citizen ID (format: ABC12345 - 3 letters, 5 numbers)

**Example:**
```lua
local citizenId = TPNRPServer:createCitizenId()
print("New citizen ID: " .. citizenId)
```

### `createUseableItem(itemName, callback)`

Registers a useable item with a callback function.

**Parameters:**
- `itemName` (string): Item name to register
- `callback` (function): Callback function when item is used
  - `callback(source, itemData)`: Called with player source and item data

**Example:**
```lua
TPNRPServer:createUseableItem('bread', function(source, itemData)
    local player = TPNRPServer:getPlayerBySource(source)
    if player then
        -- Handle item usage
        print("Player " .. player.playerData.name .. " used bread")
    end
end)
```

### `canUseItem(itemName)`

Checks if an item is registered as useable.

**Parameters:**
- `itemName` (string): Item name to check

**Returns:**
- `boolean`: True if item is useable, false otherwise

**Example:**
```lua
if TPNRPServer:canUseItem('bread') then
    print("Bread is useable")
end
```

## Events

### `HEvent:PlayerUnloaded`

Server event triggered when a player unloads/disconnects.

**Parameters:**
- `source` (number): Player source

**Example:**
```lua
-- Handled automatically by TPNRPServer
-- Automatically calls player:logout() when triggered
```


---
sidebar_position: 3
---

# Basic Usage

This guide shows you how to use TPNRP Core in your resources.

## Accessing TPNRP Core

TPNRP Core can be accessed through exports:

### Server-Side

```lua
-- Get the TPNRPServer instance
local TPNRP = exports['tpnrp-core']:core()

-- Access server methods
local player = TPNRP:getPlayerBySource(source)
if player then
    print("Player found: " .. player.playerData.name)
end
```

### Client-Side

```lua
-- Get the TPNRPClient instance
local TPNRP = exports['tpnrp-core']:core()

-- Access client methods
local coords = TPNRP:getCoords()
print("Player coords: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
```

## Getting a Player

### Server-Side

```lua
-- By source (player ID)
local player = TPNRP:getPlayerBySource(source)

-- By license
local player = TPNRP:getPlayerByLicense(license)

-- By citizen ID
local player = TPNRP:getPlayerByCitizenId(citizenId)
```

### Client-Side

The client-side player is automatically managed. Access it through the CPlayer entity.

## Working with Player Data

```lua
-- Server-side example
local player = TPNRP:getPlayerBySource(source)
if player and player.playerData then
    -- Access player data
    local citizenId = player.playerData.citizen_id
    local money = player.playerData.money
    local job = player.playerData.job
    
    -- Save player
    player:save()
    
    -- Update player data (syncs to client)
    player:updatePlayerData()
end
```

## Inventory Management

```lua
-- Server-side inventory access
local player = TPNRPServer:getPlayerBySource(source)
if player and player.inventory then
    -- Inventory operations
    -- See inventory documentation for details
end
```

## Creating Useable Items

```lua
-- Register a useable item
TPNRPServer:createUseableItem('bread', function(source, itemData)
    local player = TPNRPServer:getPlayerBySource(source)
    if player then
        -- Handle item usage
        print("Player used bread item")
    end
end)
```

## Next Steps

- Check out the [API Reference](../api/server/core.md) for detailed method documentation
- See [Examples](../examples/getting-player.md) for more code samples


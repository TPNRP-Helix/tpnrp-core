# Client-Server Architecture

TPNRP Core uses a client-server architecture where different components run on the client or server.

## Client-Side

Client-side code runs in the player's game client and has access to:
- Player's local data
- Client-side events
- UI rendering
- Local entity interactions

### Client Entities

**CPlayer**
- Represents the player on the client
- Has access to player coordinates and heading
- Receives player data updates from server

### Client Events

```lua
-- Receives player data updates from server
RegisterClientEvent('TPN:player:updatePlayerData', function(playerData)
    -- Handle player data update
end)
```

## Server-Side

Server-side code runs on the server and has:
- Authority over game state
- Database access
- Player management
- Server-side validation

### Server Entities

**SPlayer**
- Manages player state on the server
- Handles login/logout
- Manages player data persistence
- Coordinates with inventory and equipment

**SInventory**
- Manages player inventory on server
- Validates inventory operations
- Handles weight calculations

**SEquipment**
- Manages player equipment/clothing
- Handles equipment changes

### Server Events

```lua
-- Handles player unloaded event
RegisterServerEvent('HEvent:PlayerUnloaded', function(source)
    local player = TPNRPServer:getPlayerBySource(source)
    if player then
        player:logout()
    end
end)
```

## Communication

### Server → Client

The server can trigger client events:

```lua
-- Server triggers client event
TriggerClientEvent('TPN:player:updatePlayerData', source, playerData)
```

### Client → Server

The client can call server callbacks:

```lua
-- Client calls server callback
TriggerCallback('callbackName', function(result)
    -- Handle result
end, arg1, arg2)
```

## Synchronization

Player data is synchronized from server to client:

1. Server updates player data
2. Server calls `player:updatePlayerData()`
3. Client receives the update via event
4. Client updates local player data

## Best Practices

- **Server Authority**: Always validate important operations on the server
- **Client Optimization**: Keep client-side code lightweight
- **Event Naming**: Use consistent naming convention (e.g., `TPN:module:action`)
- **Data Sync**: Only sync necessary data to clients


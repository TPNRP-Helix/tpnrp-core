# Getting Player Examples

Examples of how to get and work with player entities.

## Server-Side: Get Player

### By Source

```lua
-- Get player by source (player ID)
local player = TPNRPServer:getPlayerBySource(source)
if player then
    print("Player found: " .. player.playerData.name)
else
    print("Player not found")
end
```

### By License

```lua
-- Get player by license
local player = TPNRPServer:getPlayerByLicense(license)
if player then
    print("Citizen ID: " .. player.playerData.citizen_id)
end
```

### By Citizen ID

```lua
-- Get player by citizen ID
local player = TPNRPServer:getPlayerByCitizenId("ABC12345")
if player then
    print("Player name: " .. player.playerData.name)
end
```

## Accessing Player Data

```lua
local player = TPNRPServer:getPlayerBySource(source)
if player and player.playerData then
    -- Access player properties
    local citizenId = player.playerData.citizen_id
    local name = player.playerData.name
    local money = player.playerData.money
    local job = player.playerData.job
    
    -- Access player entities
    local inventory = player.inventory
    local equipment = player.equipment
    
    -- Use player methods
    local coords = player:getCoords()
    local heading = player:getHeading()
end
```

## Updating Player Data

```lua
local player = TPNRPServer:getPlayerBySource(source)
if player then
    -- Update player data
    player.playerData.money = 5000
    
    -- Sync to client
    player:updatePlayerData()
    
    -- Save to database
    player:save()
end
```

## Player Login Flow

```lua
-- Create player entity
local player = SPlayer.new(source)

-- Login player
local success = player:login()
if success then
    print("Player logged in: " .. player.playerData.name)
    
    -- Add to players table
    TPNRPServer.players[source] = player
else
    print("Failed to login player")
end
```

## Player Logout Flow

```lua
-- Get player
local player = TPNRPServer:getPlayerBySource(source)
if player then
    -- Logout player (saves data and cleans up)
    player:logout()
    
    -- Player is automatically removed from TPNRPServer.players
end
```


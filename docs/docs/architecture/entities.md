# Entities

Entities are the core building blocks of TPNRP Core. They encapsulate game objects with state and behavior.

## Entity Pattern

Entities follow a class-like pattern using Lua metatables:

```lua
MyEntity = {}
MyEntity.__index = MyEntity

function MyEntity.new(...)
    local self = setmetatable({}, MyEntity)
    -- Initialize properties
    -- Define methods
    return self
end
```

## Client Entities

### CPlayer

Represents a player on the client-side.

**Properties:**
- `playerSource`: The player source
- `license`: Player license identifier
- `playerData`: Player data received from server
- `inventories`: Inventory reference

**Methods:**
- `getCoords()`: Get player coordinates
- `getHeading()`: Get player heading

**Usage:**
```lua
local player = CPlayer.new(source, license)
local coords = player:getCoords()
```

## Server Entities

### SPlayer

Manages player state and data on the server.

**Properties:**
- `playerSource`: The player source
- `playerData`: Player data
- `inventory`: Inventory entity
- `equipment`: Equipment entity

**Methods:**
- `save()`: Save player data to database
- `getCoords()`: Get player coordinates
- `getHeading()`: Get player heading
- `updatePlayerData()`: Sync player data to client
- `login()`: Handle player login
- `logout()`: Handle player logout

**Usage:**
```lua
local player = SPlayer.new(source)
player:login()
player:save()
```

### SInventory

Manages player inventory on the server.

**Properties:**
- `owner`: Owner entity (usually SPlayer)
- Inventory state and items

**Methods:**
- `load(type)`: Load inventory by type
- `save()`: Save inventory to database
- Inventory manipulation methods (add, remove, etc.)

### SEquipment

Manages player equipment and clothing.

**Properties:**
- `owner`: Owner entity (usually SPlayer)
- Equipment state

**Methods:**
- `save()`: Save equipment to database
- Equipment manipulation methods

## Entity Lifecycle

1. **Creation**: `Entity.new(...)` creates a new instance
2. **Initialization**: Constructor sets up initial state
3. **Usage**: Methods interact with entity
4. **Persistence**: `save()` methods persist state
5. **Cleanup**: Entity is garbage collected when no longer referenced

## Best Practices

- **Single Responsibility**: Each entity should have one clear purpose
- **Encapsulation**: Keep entity state internal, expose through methods
- **Type Annotations**: Use type annotations for better IDE support
- **Error Handling**: Validate inputs and handle errors gracefully


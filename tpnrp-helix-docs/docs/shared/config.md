# Shared Configuration

The shared configuration file (`shared/config.lua`) contains settings accessible to both client and server.

## Configuration Structure

```lua
SHARED.CONFIG = {
    DEFAULT_SPAWN = {
        POSITION = { x = -274.27, y = 6641.01, z = 7.45 },
        HEADING = 270.0,
    },
    INVENTORY = {
        WEIGHT_LIMIT = 80000, -- 80kg
        SLOTS = 64,
    },
}
```

## Configuration Options

### DEFAULT_SPAWN

Controls the default spawn location for players.

#### POSITION
- **Type:** `Vector3` (`{x, y, z}`)
- **Default:** `{ x = -274.27, y = 6641.01, z = 7.45 }`
- **Description:** Default spawn coordinates

#### HEADING
- **Type:** `number` (0-360)
- **Default:** `270.0`
- **Description:** Default player heading/rotation

### INVENTORY

Controls inventory behavior.

#### WEIGHT_LIMIT
- **Type:** `number` (grams)
- **Default:** `80000` (80kg)
- **Description:** Maximum inventory weight in grams

#### SLOTS
- **Type:** `number`
- **Default:** `64`
- **Description:** Maximum number of inventory slots

## Usage

Access configuration from any script:

```lua
-- Get default spawn position
local spawnPos = SHARED.CONFIG.DEFAULT_SPAWN.POSITION
print("Spawn X: " .. spawnPos.x)

-- Get inventory weight limit
local weightLimit = SHARED.CONFIG.INVENTORY.WEIGHT_LIMIT
print("Weight limit: " .. weightLimit .. " grams")
```

## Fallback Values

Configuration values are used as fallbacks in entities:

```lua
-- In CPlayer:getCoords()
return SHARED.CONFIG.DEFAULT_SPAWN.POSITION

-- In SPlayer:getCoords()
return SHARED.CONFIG.DEFAULT_SPAWN.POSITION
```

## Customization

To customize the configuration, edit `shared/config.lua`:

```lua
SHARED.CONFIG = {
    DEFAULT_SPAWN = {
        POSITION = { x = 0.0, y = 0.0, z = 72.0 }, -- Custom spawn
        HEADING = 0.0,
    },
    INVENTORY = {
        WEIGHT_LIMIT = 50000, -- 50kg
        SLOTS = 32,            -- 32 slots
    },
}
```

**Note:** Changes require a resource restart to take effect.


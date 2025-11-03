---
sidebar_position: 2
---

# Configuration

TPNRP Core configuration is managed through the `shared/config.lua` file.

## Default Configuration

The configuration file is located at `shared/config.lua`:

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

### Default Spawn

Controls the default spawn location for players:

- `POSITION`: Vector3 coordinates `{x, y, z}`
- `HEADING`: Player heading in degrees (0-360)

### Inventory Settings

Controls inventory behavior:

- `WEIGHT_LIMIT`: Maximum weight in grams (default: 80000 = 80kg)
- `SLOTS`: Maximum number of inventory slots (default: 64)

## Customizing Configuration

To modify the configuration, edit `shared/config.lua` directly:

```lua
SHARED.CONFIG = {
    DEFAULT_SPAWN = {
        POSITION = { x = 0.0, y = 0.0, z = 72.0 }, -- Custom spawn
        HEADING = 0.0,
    },
    INVENTORY = {
        WEIGHT_LIMIT = 50000, -- 50kg limit
        SLOTS = 32, -- Fewer slots
    },
}
```

After making changes, restart the resource for changes to take effect.


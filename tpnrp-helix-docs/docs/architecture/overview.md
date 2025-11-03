# Architecture Overview

TPNRP Core follows a modular, entity-based architecture designed for scalability and maintainability.

## Directory Structure

```
tpnrp-core/
├── client/              # Client-side code
│   ├── entities/       # Client entities
│   │   ├── core.lua   # Client core (TPNRPClient)
│   │   └── cPlayer.lua # Client player entity
│   └── main.lua        # Client entry point
│
├── server/             # Server-side code
│   ├── entities/       # Server entities
│   │   ├── core.lua   # Server core (TPNRPServer)
│   │   ├── sPlayer.lua # Server player entity
│   │   ├── sInventory.lua # Inventory entity
│   │   └── sEquipment.lua # Equipment entity
│   ├── services/       # Data Access Layer
│   │   ├── baseDAO.lua # Base DAO
│   │   ├── playerDAO.lua
│   │   ├── inventoryDAO.lua
│   │   └── equipmentDAO.lua
│   ├── types/          # Type definitions
│   │   ├── player.lua
│   │   ├── inventory.lua
│   │   ├── equipment.lua
│   │   └── game.lua
│   └── main.lua        # Server entry point
│
└── shared/             # Shared code
    ├── config.lua      # Configuration
    ├── items.lua       # Item definitions
    └── index.lua       # Shared utilities
```

## Core Concepts

### Entities

Entities are the core building blocks of TPNRP Core. Each entity represents a game object with its own state and methods.

**Client Entities:**
- `CPlayer`: Represents a player on the client-side

**Server Entities:**
- `SPlayer`: Represents a player on the server-side
- `SInventory`: Manages player inventory
- `SEquipment`: Manages player equipment/clothing

### Services (DAO)

Data Access Objects (DAOs) provide database abstraction:

- `baseDAO`: Base class for all DAOs
- `playerDAO`: Player data operations
- `inventoryDAO`: Inventory data operations
- `equipmentDAO`: Equipment data operations

### Shared Module

The `shared` directory contains code accessible to both client and server:

- Configuration (`config.lua`)
- Utility functions (`index.lua`)
- Item definitions (`items.lua`)

## Data Flow

```
Client Request
    ↓
Server Handler
    ↓
Entity Method
    ↓
DAO Service
    ↓
Database
```

## Entity Lifecycle

1. **Creation**: Entity is created when needed (e.g., player connects)
2. **Initialization**: Entity loads data from database
3. **Usage**: Entity methods handle game logic
4. **Update**: Entity state is updated during gameplay
5. **Saving**: Entity data is saved to database
6. **Destruction**: Entity is cleaned up when no longer needed

## Type System

TPNRP Core uses Lua annotations (similar to TypeScript) for type safety:

```lua
---@class PlayerData
---@field citizen_id string
---@field license string
---@field name string
```

These annotations help with:
- IDE autocompletion
- Type checking
- Documentation generation


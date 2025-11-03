# Data Access Layer (DAO) Overview

TPNRP Core uses a Data Access Object (DAO) pattern for database operations.

## Architecture

The DAO layer provides abstraction over database operations, making it easy to:
- Switch database backends
- Maintain consistent data access patterns
- Separate business logic from data access

## Base DAO

All DAOs extend from `baseDAO` which provides common functionality:

```lua
Database.Initialize('TPNRP.db')
DAO = {}
DAO.DB = Database
```

## DAO Services

### PlayerDAO
Manages player data operations:
- Get player by citizen ID
- Save player data
- Create new player

### InventoryDAO
Manages inventory data operations:
- Get inventory by citizen ID and type
- Save inventory data
- Update inventory items

### EquipmentDAO
Manages equipment data operations:
- Get equipment by citizen ID
- Save equipment data
- Update equipment items

## Usage Pattern

```lua
-- Get player data
local playerData = DAO.player.get(citizenId)

-- Save player
DAO.player.save(player)

-- Get inventory
local inventory = DAO.inventory.get(citizenId, 'player')

-- Save inventory
DAO.inventory.save(inventory)
```

## Database

TPNRP Core uses SQLite by default:
- Database file: `TPNRP.db`
- Automatically initialized when the resource starts


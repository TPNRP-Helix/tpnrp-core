## TPNRP Core

Core gameplay systems for TPNRP, organized as a Helix package written in Lua. This module provides player, inventory, and equipment primitives plus data access objects and shared configuration.

**Documentation**: https://tpnrp.thientd.dev

### Features
- **Player core**: basic player entity and persistence
- **Inventory**: item storage and manipulation
- **Equipment**: equip/unequip handling
- **DAO layer**: simple SQLite-backed data access
- **Shared config and item registry**

### Requirements
TBU

### Installation
1. Place the `tpnrp-core` folder inside your server's `resources` directory.
2. Ensure the resource on server start by adding the following to `config.json`:

```
{
  "packages": [
      "tpnrp-core"
  ]
}
```

3. Database:
   - This resource ships with `tpnrp_database.db` at the project root and uses SQLite for persistence.
   - Make sure the server process has read/write permissions to this file (or move it to a writable path and update the DAO code if needed).

### Configuration
- Edit `shared/config.lua` for global settings.
- Items are defined in `shared/items.lua`.

### Project layout
- `client/`: Client-side Lua scripts and entities
- `server/`: Server-side entities, services (DAO), types, and entrypoint
- `shared/`: Shared configuration and item registry
- `tpnrp_database.db`: SQLite database file used by DAOs

### Entrypoints
- Client: `client/main.lua`
- Server: `server/main.lua`

### Development
- Client/server code communicates via Helix events (add your own as needed).
- Keep shared logic in `shared/` to avoid duplication.
- DAO modules in `server/services/` encapsulate database access; prefer going through them from server entities.

### Contributing
1. Fork and create a feature branch.
2. Follow existing code style and structure.
3. Include concise descriptions in commits and PRs.

### License
TBD.



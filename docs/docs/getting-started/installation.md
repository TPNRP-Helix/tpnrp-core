# Installation

This guide will help you install and set up TPNRP Core for your FiveM server.

## Prerequisites

- FiveM Server
- Helix Framework
- Database system (SQLite is used by default)

## Installation Steps

### 1. Download the Resource

Clone or download the TPNRP Core resource to your server's `resources` directory:

```bash
cd resources
git clone https://github.com/TPNRP/tpnrp-core.git
```

### 2. Configure Your Server

Add the resource to your `server.cfg`:

```cfg
ensure tpnrp-core
```

The resource structure follows FiveM's standard format with `fxmanifest.lua` or `package.json` for file loading.

### 3. Database Setup

TPNRP Core uses SQLite by default. The database file `tpnrp_database.db` will be created automatically when the resource starts.

### 4. Start the Server

Restart your FiveM server or use the following command in your server console:

```
restart tpnrp-core
```

## Verify Installation

After starting the resource, check your server console for any errors. The resource should initialize without errors.

## Next Steps

- Read the [Configuration Guide](./configuration.md) to customize TPNRP Core for your server
- Check out [Basic Usage](./basic-usage.md) to see how to use the framework in your scripts


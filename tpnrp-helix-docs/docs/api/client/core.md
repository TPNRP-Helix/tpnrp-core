# Client Core API

The `TPNRPClient` is the main client-side instance of TPNRP Core.

## Access

```lua
local TPNRP = exports['tpnrp-core']:core()
```

## Properties

### `tpnrp-core()`
Returns the TPNRPClient instance.

**Returns:**
- `TPNRPClient`: The client instance

**Example:**
```lua
local TPNRP = exports['tpnrp-core']:core()
```

## Notes

The client core is automatically initialized when the resource starts. Access it through exports to use in other resources.


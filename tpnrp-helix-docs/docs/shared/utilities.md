# Shared Utilities

The shared utilities (`shared/index.lua`) provide common functions accessible to both client and server.

## String Utilities

### `SHARED.randomStr(length)`

Generates a random alphabetic string of the given length.

**Parameters:**
- `length` (number): String length

**Returns:**
- `string`: Random string (empty if length is invalid)

**Example:**
```lua
local str = SHARED.randomStr(5) -- e.g., "AbCdE"
```

### `SHARED.randomInt(min, max)`

Generates a random integer in the inclusive range [min, max].

**Parameters:**
- `min` (number): Minimum value
- `max` (number): Maximum value

**Returns:**
- `number | nil`: Random integer (nil if invalid)

**Example:**
```lua
local num = SHARED.randomInt(1, 100) -- Random number between 1 and 100
```

### `SHARED.splitString(str, delimiter)`

Splits a string by a plain-text delimiter.

**Parameters:**
- `str` (string): String to split
- `delimiter` (string): Delimiter

**Returns:**
- `table`: Array of string parts

**Example:**
```lua
local parts = SHARED.splitString("apple,banana,cherry", ",")
-- Returns: {"apple", "banana", "cherry"}
```

### `SHARED.joinString(table, delimiter)`

Joins an array-like table into a string with a delimiter.

**Parameters:**
- `table` (table): Array to join
- `delimiter` (string): Delimiter

**Returns:**
- `string`: Joined string

**Example:**
```lua
local str = SHARED.joinString({"apple", "banana", "cherry"}, ",")
-- Returns: "apple,banana,cherry"
```

### `SHARED.trimString(str)`

Trims leading and trailing whitespace.

**Parameters:**
- `str` (string): String to trim

**Returns:**
- `string`: Trimmed string

**Example:**
```lua
local trimmed = SHARED.trimString("  hello world  ")
-- Returns: "hello world"
```

### `SHARED.replaceString(str, old, new)`

Replaces all occurrences of a plain-text substring with another.

**Parameters:**
- `str` (string): String to replace in
- `old` (string): Substring to replace
- `new` (string): Replacement string

**Returns:**
- `string`: String with replacements

**Example:**
```lua
local replaced = SHARED.replaceString("hello world", "world", "universe")
-- Returns: "hello universe"
```

### `SHARED.toUpper(str)`

Converts a string to uppercase.

**Parameters:**
- `str` (string): String to convert

**Returns:**
- `string`: Uppercase string

**Example:**
```lua
local upper = SHARED.toUpper("hello")
-- Returns: "HELLO"
```

### `SHARED.toLower(str)`

Converts a string to lowercase.

**Parameters:**
- `str` (string): String to convert

**Returns:**
- `string`: Lowercase string

**Example:**
```lua
local lower = SHARED.toLower("HELLO")
-- Returns: "hello"
```

### `SHARED.startsWith(str, prefix)`

Checks if a string starts with a prefix.

**Parameters:**
- `str` (string): String to check
- `prefix` (string): Prefix to check

**Returns:**
- `boolean`: True if string starts with prefix

**Example:**
```lua
local starts = SHARED.startsWith("hello world", "hello")
-- Returns: true
```

### `SHARED.endsWith(str, suffix)`

Checks if a string ends with a suffix.

**Parameters:**
- `str` (string): String to check
- `suffix` (string): Suffix to check

**Returns:**
- `boolean`: True if string ends with suffix

**Example:**
```lua
local ends = SHARED.endsWith("hello world", "world")
-- Returns: true
```

## Table Utilities

### `SHARED.contains(tbl, val)`

Checks if a table contains a value.

**Parameters:**
- `tbl` (table): Table to check
- `val` (any): Value to search for

**Returns:**
- `boolean`: True if value is found

**Example:**
```lua
local has = SHARED.contains({1, 2, 3}, 2)
-- Returns: true
```

## Clothing Utilities

### `SHARED.getClothItemTypeByName(itemName)`

Gets cloth item type by item name.

**Parameters:**
- `itemName` (string): Item name (must start with "cloth_")

**Returns:**
- `EEquipmentClothType | nil`: Cloth type if found, nil otherwise

**Example:**
```lua
local clothType = SHARED.getClothItemTypeByName("cloth_head_helmet")
-- Returns: EEquipmentClothType.Head
```

**Supported Prefixes:**
- `cloth_head_` → `EEquipmentClothType.Head`
- `cloth_mask_` → `EEquipmentClothType.Mask`
- `cloth_hairstyle_` → `EEquipmentClothType.HairStyle`
- `cloth_torso_` → `EEquipmentClothType.Torso`
- `cloth_leg_` → `EEquipmentClothType.Leg`
- `cloth_bag_` → `EEquipmentClothType.Bag`
- `cloth_shoes_` → `EEquipmentClothType.Shoes`
- `cloth_accessories_` → `EEquipmentClothType.Accessories`
- And more...

## Usage Examples

```lua
-- Generate random ID
local randomId = SHARED.randomStr(3) .. SHARED.randomInt(10000, 99999)

-- String manipulation
local parts = SHARED.splitString("item1,item2,item3", ",")
local joined = SHARED.joinString(parts, " | ")

-- Check clothing type
local clothType = SHARED.getClothItemTypeByName("cloth_bag_backpack")
if clothType == EEquipmentClothType.Bag then
    print("This is a bag item")
end
```


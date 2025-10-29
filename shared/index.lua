SHARED = {}

---Generate a random alphabic string of the given length
---@param length number
---@return string
SHARED.randomStr = function(length)
	if type(length) ~= "number" or length <= 0 then
		return ""
	end

	local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	local result = {}
	for i = 1, length do
		local idx = math.random(#charset)
		result[i] = string.sub(charset, idx, idx)
	end
	return table.concat(result)
end

---Generate a random integer in the inclusive range [min, max]
---@param min number
---@param max number
---@return number | nil
SHARED.randomInt = function(min, max)
    -- min or max is not a number
	if type(min) ~= "number" or type(max) ~= "number" then
		return nil
	end
    -- Generate a random integer in the inclusive range [min, max]
	if min > max then
		min, max = max, min
	end
    -- Convert to integer
    min = math.floor(min)
    max = math.floor(max)
    -- Return random integer
    return math.random(min, max)
end

----------------------------------------------------------------------
--- Split String
----------------------------------------------------------------------
---Split a string by a plain-text delimiter (no Lua pattern matching)
---@param str string
---@param delimiter string
---@return table
SHARED.splitString = function(str, delimiter)
	if type(str) ~= "string" then return {} end
	if delimiter == nil or delimiter == "" then return { str } end

	local result = {}
	local startIndex = 1
	while true do
		local delimStart, delimEnd = string.find(str, delimiter, startIndex, true)
		if not delimStart then
			result[#result + 1] = string.sub(str, startIndex)
			break
		end
		result[#result + 1] = string.sub(str, startIndex, delimStart - 1)
		startIndex = delimEnd + 1
	end
	return result
end

----------------------------------------------------------------------
--- Join an array
----------------------------------------------------------------------
---Join an array-like table into a string with a delimiter
---@param table table
---@param delimiter string
---@return string
SHARED.joinString = function(table, delimiter)
	-- Join an array-like table into a string with a delimiter
	if type(table) ~= "table" then return "" end
	local sep = delimiter or ""
	local parts = {}
	for i = 1, #table do
		parts[i] = tostring(table[i])
	end
	return table.concat(parts, sep)
end

----------------------------------------------------------------------
--- Trim String
----------------------------------------------------------------------
---Trim leading and trailing whitespace
---@param str string
---@return string
SHARED.trimString = function(str)
	-- Trim leading and trailing whitespace
	if type(str) ~= "string" then return "" end
	return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

----------------------------------------------------------------------
--- Replace String
----------------------------------------------------------------------
---Replace all occurrences of a plain-text substring with another
---@param str string
---@param old string
---@param new string
---@return string
SHARED.replaceString = function(str, old, new)
	-- Replace all occurrences of a plain-text substring with another
	if type(str) ~= "string" then return "" end
	if old == nil or old == "" then return str end

	-- Escape Lua pattern characters in 'old'
	local function escapePattern(s)
		return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
	end

	local escapedOld = escapePattern(old)
	-- Ensure replacement treats % literally
	local safeNew = tostring(new or ""):gsub("%%", "%%%%")
	return (str:gsub(escapedOld, safeNew))
end

----------------------------------------------------------------------
--- String to Upper
----------------------------------------------------------------------
---Convert a string to uppercase
---@param str string
---@return string
SHARED.toUpper = function(str)
	if type(str) ~= "string" then return tostring(str) end
	return string.upper(str)
end

----------------------------------------------------------------------
--- String to Lower
----------------------------------------------------------------------
---Convert a string to lowercase
---@param str string
---@return string
SHARED.toLower = function(str)
	if type(str) ~= "string" then return tostring(str) end
	return string.lower(str)
end

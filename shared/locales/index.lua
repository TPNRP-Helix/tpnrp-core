local EN = require('shared/locales/en')
local VI = require('shared/locales/vi')

-- Load your language here
local LANGUAGES = {
    en = EN or {},
    vi = VI or {},
    -- Add more languages by appending here, e.g.:
    -- es = require('shared/locales/es'),
}

local function deepFlatten(prefix, tbl, out)
    for k, v in pairs(tbl or {}) do
        local key = prefix and (prefix .. "." .. k) or k
        if type(v) == 'table' then
            deepFlatten(key, v, out)
        else
            out[key] = v
        end
    end
end

local function buildLookup(lang)
    local lookup = {}
    -- Always start with English as base if available
    local base = LANGUAGES['en']
    if type(base) == 'table' then
        deepFlatten(nil, base, lookup)
    end
    -- Overlay selected language if provided and known
    local sel = LANGUAGES[lang]
    if type(sel) == 'table' and sel ~= base then
        local override = {}
        deepFlatten(nil, sel, override)
        for k, v in pairs(override) do
            lookup[k] = v
        end
    end
    -- Any other lang falls back to English only
    return lookup
end

local function interpolate(str, params)
    if type(str) ~= 'string' or type(params) ~= 'table' then return str end
    return (str:gsub('%b{}', function(m)
        local key = m:sub(2, -2)
        local val = params[key]
        if val == nil then return m end
        return tostring(val)
    end))
end

LANGUAGE_LOADER = {}

function LANGUAGE_LOADER.load(lang)
    local selected = buildLookup(lang or 'en')
    local fallback = buildLookup('en')
    local function t(key, params)
        local value = selected[key] or fallback[key]
        if value == nil then
            return interpolate(key, params)
        end
        return interpolate(value, params)
    end
    return selected, t
end

return LANGUAGE_LOADER



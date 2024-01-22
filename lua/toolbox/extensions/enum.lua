local Array = require 'toolbox.core.array'
local Iter = require 'toolbox.utils.iter'
local String = require 'toolbox.core.string'
local Table = require 'toolbox.core.table'

local ternary = require('toolbox.core.bool').ternary

--- Models a single enum entry.
---
---@class Entry
---@field key string
---@field value any
local Entry = {}
Entry.__index = Entry

--- Constructor
---
---@param key string: uniquely identifies the entry
---@param value any: the data value for the entry
---@return Entry: a new instance
function Entry.new(key, value)
  return setmetatable({
    key = key,
    value = value,
  }, Entry)
end

function Entry:__tostring()
  return self.value
end

--- Attempts to model something like Java's enums.
---
---@class Enum<T>
---@field private entries { [string]: `T` }
---@field private by_value { [`T`]: string }: a mapping of entry values to keys
---@field private default string
---@field [any] any
local Enum = {}
Enum.__index = Enum

local function is_valid_table_value(val)
  return Table.is(val) and val.key ~= nil
end

local function is_sortable_table_value(val)
  return Table.is(val) and val.i ~= nil
end

local function make_by_values(entries)
  local by_value = {}

  for key, val in pairs(entries) do
    if Table.is(val) and not is_valid_table_value(val) then
      error 'Enum: non-primitive enum values must have a "key" field'
    elseif Table.is(val) then
      by_value[val.key] = val
    else
      by_value[val] = key
    end
  end

  return by_value
end

local function valkey(val)
  return ternary(is_valid_table_value(val), function()
    return val.key
  end, val)
end

--- Constructor
---
---@generic T
---@param entries { [string]: T }: a dict of string keys to enum entry values
---@param default string|nil: optional; the key of the default enum value
---@return Enum: a new entry
function Enum.new(entries, default)
  if Table.is_empty(entries) then
    error 'Enum: an enum must have at least one entry'
  end

  return setmetatable({
    entries = entries,
    by_value = make_by_values(entries),
    default = default,
  }, Enum)
end

---@return boolean: true if this enum has a default value, false otherwise
function Enum:has_default()
  return self:get_default() ~= nil
end

---@generic T
---@return T|nil: the enum's default entry, if it has one
function Enum:get_default()
  return self.entries[self.default]
end

--- Checks if the provided value corresponds any of the enum's keys or values.
---
---@generic T
---@param entry string|T: the key/value to check
---@return boolean: true if the provided value corresponds to any of the enum's keys or
--- values, false otherwise
function Enum:is_valid(entry)
  return self:is_key(entry) or self:is_value(entry)
end

--- Checks if the provided key corresponds to an enum entry.
---
---@param key string: the key to check
---@return boolean: true if the provided key corresponds to an enum entry, false otherwise
function Enum:is_key(key)
  return self.entries[key] ~= nil
end

--- Checks if the provided value corresponds to an enum entry.
---
---@generic T
---@param val T|{ key: string }: the value to check
---@return boolean: true if the provided value corresponds to an enum entry, false otherwise
function Enum:is_value(val)
  return self.by_value[valkey(val)] ~= nil
end

--- Checks if the provided value corresponds to any of the enum's keys or values and
--- returns that entry if so; otherwise, returns the default, if one exists.
---
---@generic T
---@param entry string|T: a value that may or may not correspond to one of the enum's keys
--- or values
---@return T|nil: the enum entry's value that corresponds to the provided key/value, if
--- one exists, otherwise, default or nil
function Enum:or_default(entry)
  if self:is_key(entry) then
    return self.entries[entry]
  end

  if self:is_value(entry) then
    local val = self.by_value[valkey(entry)]
    return ternary(Table.is(val), val, entry)
  end

  return self:get_default()
end

---@return string[]: the keys of the enum's entries, in no particular order
function Enum:keys()
  return Table.keys(self.entries)
end

---@generic T
---@return T[]: the values of the enum's entries, in no particular order
function Enum:values()
  return Table.values(self.entries)
end

---@generic T
---@return T[]: the sorted values of the enum's entries; sorting uses either natural sort,
--- or the value.i, if present in dict values
function Enum:sorted()
  local values = Table.values(self.entries)
  local key = nil

  if is_sortable_table_value(values[1]) then
    key = function(v)
      return v.i
    end
  end

  return Array.sorted(values, { key = key })
end

function Enum:__tostring()
  local str_keys = String.join(self:keys())
  return String.fmt('Enum(%s)', str_keys)
end

--- Custom index metamethod that allow callers to reference enum value by indexing the
--- enum.
---
---@generic T
---@param key string: the key for which to retrieve an enum entry
---@return T|nil: the entry that corresponds to key, if one exists
function Enum:__index(key)
  local raw = rawget(Enum, key)

  if raw ~= nil then
    return raw
  end

  return self.entries[key] or self.by_value[valkey(key)]
end

--- Custom ipairs metamethod that allows callers to iterate over enum values like arrays.
---
---@generic T
---@return (fun(): string, T), { [integer]: T }, nil: a "next" function that returns
--- successive index/value pairs from the enum, the enum values, and the first index (nil)
function Enum:__ipairs()
  local values = Table.values(self.entries)
  return Iter.array(values), { values }, nil
end

--- Custom pairs metamethod that allows callers to iterate over enums like dicts.
---
---@generic T
---@return (fun(): string, T), { [string]: T }, nil: a "next" function that returns
--- successive key/value pairs from the enum, the enum dict, and the first index (nil)
function Enum:__pairs()
  return Iter.dict(self.entries), { self.entries }, nil
end

--- Constructs an enum entry from the provided key and value.
---
---@param key string: uniquely identifies the entry
---@param value any: the data value for the entry
---@return Entry: an entry constructed from key and value
local function entry(key, value)
  return Entry.new(key, value)
end

--- Constructs an enum from a dict of key/value entry pairs or an array of entries.
---
---@generic T
---@param entries { string: T }|Entry[]: the keys/values from which to construct entries
--- and the enum
---@param default string|nil: optional; the key of the default entry, if one exists
---@return Enum: a new instance
local function enum(entries, default)
  if not Table.is_empty(entries) and #entries == 0 then
    return Enum.new(entries, default)
  end

  entries = Table.to_dict(entries, function(e, _)
    return e.key, e.value
  end)
  return Enum.new(entries, default)
end

return {
  Enum = Enum,
  Entry = Entry,
  enum = enum,
  entry = entry,
}

local Bool = require 'toolbox.core.bool'
local Err = require 'toolbox.error.error'
local Table = require 'toolbox.core.table'
local Type = require 'toolbox.meta.type'

--- Contains utilities for looking into/manipulating an object's/class's meta properties.
---
---@class Introspect
local Introspect = {}

--- Gets the metatable of the provided object, if it exists.
---
---@param obj any|nil: the object who's metatable we want
---@param strict boolean|nil: optional, defaults to true; if true and obj == nil, raise
--- an error
---@return table|nil: the metatable of the provided object, if it exists
---@error if obj is nil and strict == true
function Introspect.mt(obj, strict)
  strict = Bool.or_default(strict, true)

  if obj ~= nil then
    return getmetatable(obj)
  end

  if strict then
    Err.raise "Introspect.mt: can't retrieve metatable of nil"
  end
end

--- Attempts to get the property "metafield" from obj's metatable.
---
---@param obj table: the object from which to extract a property
---@param metafield string: the name of the property to extract
---@return any|nil: the value associated w/ the associated metafield, if any
function Introspect.get_from_metatable(obj, metafield)
  local mt = Introspect.mt(obj, false)

  -- if the metatable isn't actually a table there's nothing in which to search
  if mt == nil or not Table.is(mt) then
    return nil
  end

  if mt[metafield] ~= nil then
    return mt[metafield]
  end

  -- if we're here, we haven't found a match, but it's possible there's a match in a
  -- "parent" metatable (TODO: I'm not really sure if this logic really holds up against
  -- real world lua inheritance)
  if Table.is(mt.__index) then
    return Introspect.get_from_metatable(mt.__index, metafield)
  end
end

--- Checks if the provided object has the metatable property "metafield".

---@generic S, T
---@param obj { [S]: T }: the object to check
---@param metafield S: the property to check for
---@return boolean: true if obj's metatable has property "metafield", either in its
--- metatable or an inherited metatable
---@return T|nil: the property value, if it exists
function Introspect.in_metatable(obj, metafield)
  local val = Introspect.get_from_metatable(obj, metafield)
  return val ~= nil, val
end

--- Checks if the provided object has property "prop", either directly or via metatable.
---
---@generic S, T
---@param obj { [S]: T }: the object to check
---@param prop S: the property to check for
---@return boolean: true if obj has property "prop", directly or via metatable, othwerise
--- false
---@return T|nil: the property value, if it exists
function Introspect.has_property(obj, prop)
  local val = rawget(obj, prop)

  if val ~= nil then
    return true, val
  end

  return Introspect.in_metatable(obj, prop)
end

function Introspect.get_property(obj, prop)
  if obj[prop] ~= nil then
    return obj[prop]
  end

  return Introspect.get_from_metatable(obj, prop)
end

function Introspect.is_mt_callable(obj, prop)
  local in_mt, val = Introspect.in_metatable(obj, prop)
  return in_mt and Type.isfunc(val)
end

function Introspect.mt_callable(obj, mthd_name)
  local mt = Introspect.mt(obj, false)

  if mt == nil then
    return false
  end

  return function(...)
    return mt[mthd_name](obj, ...)
  end
end

--- Checks if o is callable.
---
---@param o any: the object to check
---@return boolean: true if o is callable, false otherwise
function Introspect.is_callable(o)
  return Type.isfunc(o) or Introspect.in_metatable(o, '__call')
end

return Introspect

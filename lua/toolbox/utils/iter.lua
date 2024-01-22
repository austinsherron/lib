local Bool = require 'toolbox.core.bool'

---@alias Iterable { __mt: { __ipairs: (fun(...): integer, any)|nil, __pairs: (fun(...): any, any)|nil }}

--- Contains iterator "next" helper functions.
--
---@class Iter
local Iter = {}

---@private
function Iter.iter(len)
  -- start at nil as that's what standard next function expects
  local i = nil

  return function()
    -- termination condition
    if i ~= nil and i >= len then
      return -1
    end

    local ret = i
    -- increment; using ternary to deal w/ nil
    i = Bool.ternary(i == nil, 1, function()
      return i + 1
    end)
    return ret
  end
end

--- Constructs and returns a next function that returns successive values from the provided
--  array-like table. This utility is useful for implementing iterators via the __ipairs
--  metamethod.
--
---@generic T
---@param arr { [integer]: T}: an array-like table over which to iterate
---@return fun(): (number, T): a next function for iterating over arbitrary array-like
-- tables
function Iter.array(arr)
  local curr = nil

  return function()
    local idx, val = next(arr, curr)
    curr = idx

    return idx, val
  end
end

--- Constructs and returns a function that successively returns values in the range
--- [1, n], and resets to 1 after returning n. For example:
---
---  local iter = Iter.circular(2)
---
---  iter() == 1
---  iter() == 2
---  iter() == 1
---
---@param n integer: the upper limit of range of the iter's return values
---@return fun(): r: integer a function that successively returns values in the range
--- [1, n], and resets to 1 after returning n
function Iter.circular(n)
  local i = 0

  return function()
    i = Bool.ternary(i == n, 1, i + 1)

    return i
  end
end

--- Constructs and returns a next function that returns successive key/value pairs from
--- the provided dict-like table. This utility is useful for implementing iterators via
--- the __pairs metamethod.
---
---@generic K, V
---@param dict { [K]: V }: a dict-like table over which to iterate
---@return fun(): (K, V): a next function for iterating over arbitrary dict-like tables
function Iter.dict(dict)
  local curr = nil

  return function()
    local k, v = next(dict, curr)

    if k == nil then
      return
    end

    curr = k
    return k, v
  end
end

--- Contains utilities for interacting w/ iterables.
---
---@class IterUtils
IterUtils = {}

---@note: to expose IterUtils
Iter.Utils = IterUtils

--- Converts an iterable to a collection (i.e.: array, set, etc.).
---
---@generic C, T
---@param it Iterable: the iterable to convert
---@param collection C: the initial collection to which to add iterable entries; this
--- function mutates collection
---@param add fun(collection: C, entry: T) function that adds iterable entries to
--- collection (mutates collection)
---@return C: collection, w/ iterable entries added to it according to add
function IterUtils.to_collection(it, collection, add)
  for _, entry in ipairs(it) do
    add(collection, entry)
  end

  return collection
end

--- Converts an iterable to a dict.
---
---@generic K, V, S, T
---@param it Iterable: the iterable to convert
---@param map fun(k: K, v: V): S, T optional; a function that transforms k, v before
--- adding it to the dict
---@return { [S]: T }: a dict comprised of key/value pairs from it, optionally transformed
--- by map
function IterUtils.to_dict(it, map)
  map = map or function(k, v)
    return k, v
  end

  local dict = {}

  for k, v in pairs(it) do
    k, v = map(k, v)
    dict[k] = v
  end

  return dict
end

--- Converts an iterable to a string, joined by sep. Individual elements will be converted
--- to strings via tostring.
---
---@param it Iterable: the iterable to convert
---@param sep string: the string to use to join elements of it
function IterUtils.joining(it, sep)
  local str = ''

  for i, entry in ipairs(it) do
    if i > 1 then
      str = str .. sep
    end

    str = str .. tostring(entry)
  end

  return str
end

--- Gets the only item from the iterable.
---
---@generic T
---@param it Iterable: the iterable from which to retrieve the only value
---@param strict boolean|nil: optional, defaults to true; if true, raises an error if the
--- iterable is empty or contains more than one entry
---@return T|nil: the only item from it, or nil if strict is false and it is empty
function IterUtils.get_only(it, strict)
  strict = Bool.or_default(strict, true)

  local i, only = next(it)

  if not strict then
    return only
  end

  if only == nil then
    error 'IterUtils.get_only: iterable is empty'
  end

  if next(it, i) ~= nil then
    error 'IterUtils.get_only: #iterable > 1'
  end

  return only
end

return Iter

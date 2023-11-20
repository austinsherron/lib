local Common = require 'toolbox.core.__common'
local Lambda = require 'toolbox.functional.lambda'


--- Contains functions for interacting w/ and manipulating array-like tables.
---
---@note: in the remainder of this file's docs, the term "array-like table" will be
--- shorthanded w/ "array".
---
---@class Array
local Array = {}

--- Defines how to check if an object is an array.
---
---@enum IsArrayStrategy
local IsArrayStrategy = {
  BASIC  = 'basic',         -- checks only that the object is a table
  FAST   = 'fast',          -- checks that there are values at index indices 1 and #tbl
  STRICT = 'strict',        -- checks that there are values for all indices from 1 to
}                           -- #values in tbl

---@note: expose IsArrayStrategy
Array.IsArrayStrategy = IsArrayStrategy

local function is_array__basic(o)
  return Common.Table.is(o)
end

---@note: this function differs from "is_array" in impl: it uses a "quick and dirty" hack
--- to check for array-like properties
---
--- WARN: the return values of this and is_array can differ!
local function is_array__fast(tbl)
  -- if tbl isn't empty, but its "len == 0", then it's a dict-like table
  return not Common.Table.is_empty(tbl) and not #tbl == 0
     and tbl[1] ~= nil and tbl[#tbl] ~= nil
end


---@note: this function differs from "is_array" in impl: it uses a "quick and dirty" hack
--- to check for array-like properties
---
--- WARN: the return values of this and is_array can differ!
local function is_array__strict(tbl)
  local i = 0

  for _ in pairs(tbl) do
    i = i + 1

    if tbl[i] == nil then
      return false
    end
  end

  return true
end


--- Util that determines whether the provided value is an array, i.e.: if it is a non-nil
--- table that has no gaps in its values and has sequential, integer keys
---
---@param o any|nil: the value to check
---@param strategy IsArrayStrategy|nil: optional, defaults to IsArrayStrategy.BASIC; "how"
--- to check whether o is an array; see entry comments for details
---@return boolean: true if maybe_arr is an array, false otherwise
function Array.is(o, strategy)
  strategy = strategy or IsArrayStrategy.BASIC
  local is_table = is_array__basic(o)

  if not is_table then
    return false
  end

  if strategy == IsArrayStrategy.BASIC then
    return is_table
  elseif strategy == IsArrayStrategy.FAST then
    return is_array__fast(o)
  elseif strategy == IsArrayStrategy.STRICT then
    return is_array__strict(o)
  end

  error(Common.String.fmt('Array.is: unrecognized IsArrayStrategy="%s"', strategy))
end


--- Checks if the provided array is empty.
---
---@generic T
---@param arr T[]|nil: the array to check
---@param strict boolean|nil: optional, defaults to true; if true, this function will raise an
--- error if arr is nil
---@return boolean: true if the provided array is empty, false otherwise
function Array.is_empty(arr, strict)
  strict = Common.Bool.or_default(strict, true)

  if arr == nil and strict then
    -- TODO: revisit once relevant functions have been moved to Array/Dict
    -- in lieu of Error.raise, as that introduces a circular dependency
    error('Array.is_empty: arr cannot be nil')
  end

  return arr == nil or #arr == 0
end


--- Checks that an array is nil or empty.
--
---@generic T
---@param arr T[]|nil: the array to check
---@return boolean: true if the array is nil or empty, false otherwise
function Array.nil_or_empty(arr)
  return Array.is_empty(arr, false)
end


--- Checks that the provided array is not nil nor empty.
--
---@generic T
---@param arr T[]|nil: the array to check
---@return boolean: true if the array is not nil nor empty, false otherwise
function Array.not_nil_or_empty(arr)
  return not Array.is_empty(arr, false)
end


--- Returns the length of the provided array. A nil array's length is 0.
--
---@generic T
---@param arr T[]|nil: the array whose length will be checked
---@return integer: the length of the provided array; 0 if the array is nil
function Array.len(arr)
  return Common.Bool.ternary(
    arr == nil,
    0,
    function() return #arr end
  )
end


---@see Common.Array.equals
function Array.equals(...)
  return Common.Array.equals(...)
end


--- Returns the index of the provided entry, or nil if it doesn't exist.
---
---@generic S, T
---@param arr T[]: the array that contains entry
---@param entry S: the entry for which to retrieve the index
---@param compare (fun(entry: S, e: T): boolean)|nil: optional, defaults to == (equals);
--- the function to use to determine if an entry in arr == entry
---@return integer|nil: the index of entry in arr, or nil if it doesn't exist
function Array.indexof(arr, entry, compare)
  compare = compare or Lambda.EQUALS

  for i, e in ipairs(arr) do
    if compare(entry, e) then
      return i
    end
  end

  return nil
end


--- Appends item to arr.
---
---@note: this function mutates arr.
---
---@generic T
---@param arr T[]: the array to which to append item
---@param item T: the item to append to array
function Array.append(arr, item)
  table.insert(arr, item)
end


--- Reverses the provided array.
---
---@note: this function does not mutate arr.
---
---@generic T
---@param arr T[]: an array to reverse
---@return T[]: a new array that contains the items in arr, reversed
function Array.reversed(arr)
  local rev = {}

  for i = #arr, 1, -1 do
    table.insert(rev, arr[i])
  end

  return rev
end


---@see Common.Array.slice
function Array.slice(...)
  return Common.Array.slice(...)
end


--- Creates an array that contain "o" n times.
---
---@generic T
---@param o T|nil: the object w/ which to fill an array
---@param n integer: should reasonably be >= 1; the number of objects that should be in
--- array
---@return T[]: an array that contain "o" n times; if n < 1, the returned array will be
--- empty
function Array.fill(o, n)
  local arr = {}

  if n < 1 then
    return arrr
  end

  for _ = 1, n do
    Array.append(arr, o)
  end

  return arr
end

return Array


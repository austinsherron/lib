local Common = require 'toolbox.core.__common'
local Lambda = require 'toolbox.functional.lambda'

local or_default = Common.Bool.or_default
local ternary = Common.Bool.ternary

--- Parameterizes array sorting.
---
---@see Array.sorted
---
---@generic T
---@class SortOps
---@field key (fun(T): integer)|nil: takes an entry of the array to sort and converts it
--- to a value for use in a sort comparator
---@field reversed boolean|nil: optional, defaults to false; if true, the array will be
--- sorted in reverse

local DEF_SORT_OPTS = { reversed = false, key = Lambda.IDENTITY }

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
  BASIC = 'basic', -- checks only that the object is a table
  FAST = 'fast', -- checks that there are values at index indices 1 and #tbl
  STRICT = 'strict', -- checks that there are values for all indices from 1 to
} -- #values in tbl

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
  return not Common.Table.is_empty(tbl) and not #tbl == 0 and tbl[1] ~= nil and tbl[#tbl] ~= nil
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
  strict = or_default(strict, true)

  if arr == nil and strict then
    -- TODO: revisit once relevant functions have been moved to Array/Dict
    -- in lieu of Error.raise, as that introduces a circular dependency
    error 'Array.is_empty: arr cannot be nil'
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

---@see Common.Array.len
function Array.len(...)
  return Common.Array.len(...)
end

---@see Common.Array.equals
function Array.equals(...)
  return Common.Array.equals(...)
end

---@see Common.Array.index
function Array.index(...)
  return Common.Array.index(...)
end

--- Checks if entry is in arr. Optionally uses compare to check for equality.
---
---@generic S, T
---@param arr T[]: the array to check
---@param entry T: the entry to check for containment in arr
---@param compare (fun(entry: S, e: T): boolean)|nil: optional, defaults to == (equals);
--- the function to use to determine if an entry in arr == entry
---@return boolean: true if entry is in arr, false otherwise
function Array.contains(arr, entry, compare)
  return Array.indexof(arr, entry, compare) ~= nil
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

local function make_sort_key(opts)
  if not opts.reversed then
    return opts.key
  end

  return function(num)
    return Lambda.NEGATIVE(opts.key(num))
  end
end

--- Sorts arr and returns it.
---
---@note: This function mutates arr.
---
---@generic T
---@param arr T[]: the array to sort
---@param opts SortOps|nil: parameterizes array sorting
---@return T[]: arr (mutated) sorted according to opts
function Array.sorted(arr, opts)
  opts = Common.Table.combine(DEF_SORT_OPTS, opts or {})

  local key = make_sort_key(opts)
  local cmp = function(l, r)
    return key(l) < key(r)
  end

  table.sort(arr, cmp)
  return arr
end

---@see Common.Array.append
function Array.append(...)
  Common.Array.append(...)
end

--- Copies arr and appends item to it.
---
---@generic T
---@param arr T[]: the array to copy and append to
---@param item T: the item to append
---@return T[]: a copy of arr w/ item appended to it
function Array.appended(arr, item)
  local copy = Array.copy(arr)

  Array.append(copy, item)
  return copy
end

--- Appends all entries in append to arr.
---
---@note: This function mutates arr.
---
---@generic T
---@param arr T[]: the array to which to append entries in append
---@param append T[]: the array whose entries will be appended to arr
function Array.appendall(arr, append)
  for _, entry in ipairs(append) do
    Array.append(arr, entry)
  end
end

--- Prepends item to arr.
---
---@generic T
---@param arr T[]: the array to which to prepend item
---@param item T: the item to prepend to array
function Array.prepend(arr, item)
  table.insert(arr, 1, item)
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

--- Creates an array that contains "o" n times. If o is a table, each entry in the output
--- array will be a separate copy.
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
    return arr
  end

  for _ = 1, n do
    if Common.Table.is(o) then
      ---@diagnostic disable-next-line: param-type-mismatch
      o = Array.copy(o)
    end

    Array.append(arr, o)
  end

  return arr
end

--- Recursively copies the provided array.
---
---@note: This is not a true "deep-copy", as it doesn't consider metatables or cycles in
--- the input array.
---
---@generic T
---@param arr T[]: the array to copy
---@return T[]: a recursive copy of arr
function Array.copy(arr)
  local copy = {}

  for _, e in ipairs(arr) do
    if Common.Table.is(e) then
      e = Array.copy(e)
    end

    Array.append(copy, e)
  end

  return copy
end

--- Uses mapper to convert the provided dict to an array.
---
---@generic K, V, T
---@param dict { [K]: V }: the dict to convert to an array
---@param mapper fun(k: K, v: V): T a function that maps from key/value pairs in dict to
--- entries in the output array
---@return T[]: an array comprised of items created by application of mapper to key/value
--- pairs in dict
function Array.from_dict(dict, mapper)
  local arr = {}

  for k, v in pairs(dict) do
    Array.append(arr, mapper(k, v))
  end

  return arr
end

return Array

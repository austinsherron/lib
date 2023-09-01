local Num    = require 'toolbox.core.num'
local Lambda = require 'toolbox.functional.lambda'


--- Contains functions for interacting w/ and manipulating array-like tables.
---
---@note: in the remainder of this file's docs, the term "array-like table" will be
--- shorthanded w/ "array".
---
---@class Array
local Array = {}

--- Checks if two arrays are equal.
---
---@note: this function checks "shallow equality": it does not recur into nested tables,
--- nor does it check metatables, etc.
---
---@generic S, T (S ?= T)
---@param l S[]: an array to check for equality
---@param r T[]: an array to check for equality
---@return boolean: true if l shallow equals r, false otherwise
function Array.equals(l, r)
  if #l ~= #r then
    return false
  end

  for i = 1, #l do
    if l[i] ~= r[i] then
      return false
    end
  end

  return true
end


--- Returns the index of the provided entry, or nil if it doesn't exist.
---
---@generic T
---@param arr T[]: the array that contains entry
---@param entry T: the entry for which to retrieve the index
---@param compare (fun(l: T, r: T): boolean)|nil: optional, defaults to == (equals);
--- the function to use to determine if an entry in arr == entry
---@return integer|nil: the index of entry in arr, or nil if it doesn't exist
function Array.indexof(arr, entry, compare)
  compare = compare or Lambda.EQUALS

  for i, e in ipairs(arr) do
    if compare(e, entry) then
      return i
    end
  end

  return nil
end


--- Reverses the provided array.
---
---@note: this method does not modify arr.
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


--- Returns a "slice" of an array from start idx = s to end idx = e, inclusive. For
--- example:
---
---   local a = { 1, 2, 3, 4, 5 }
---   Array.slice(a, 2, 4) == { 2, 3, 4 }
---
--- If e < 1, it's treated as e < 1 + #arr. For example:
---
---   local a = { 1, 2, 3, 4, 5 }
---   Array.slice(a, 2, -1) == { 2, 3, 4 }
---   Array.slice(a, 1, -2) == { 1, 2, 3 }
---
--- Otherwise, s is bounded at 1, and e is bounded at #arr. If s > e, an empty array is
--- returned.
---
---@generic T
---@param arr T[]: the array from which to take a slice
---@param s integer: the lower bound of the slice
---@param e integer|nil: optional, defaults to #arr; the upper bound of the slice
---@return T[]: a slice of an array table, possibly an empty array if arr is empty or
--- s > e
function Array.slice(arr, s, e)
  if #arr == 0 then
    return {}
  elseif e == nil then
    e = #arr
  elseif e < 1 then
    e = e + #arr
  elseif s > #arr then
    return {}
  end

  s = Num.bounds(s, 1, #arr)
  e = Num.bounds(e or #arr, 1, #arr)

  local slice = {}

  if s > e then
    return slice
  end

  for i = s, e do
    local j = #slice + 1
    slice[j] = arr[i]
  end

  return slice
end

return Array



-- Contains utilities shared by test utils.
---
---@note: since these utilities are used to test shared code, this class contains
--- logic/functions duplicated in other shared utilities
---
---@class TestUtils
local TestUtils = {}

TestUtils.concat = table.insert
TestUtils.fmt = string.format
TestUtils.pack = table.pack
TestUtils.unpack = unpack or table.unpack


local function table_is_empty(tbl)
  for _, v in pairs(tbl) do
    if v ~= nil then
      return false
    end
  end

  return true
end


--- Checks if the provided object is a string or table that is empty.
---
---@param o string|table: the object to check
---@return boolean: true if the provided object is empty, false otherwise
function TestUtils.is_empty(o)
  local o_type = type(o)

  if o_type == 'string' then
    return o == ''
  elseif o_type == 'table' then
    return table_is_empty(o)
  else
    error(TestUtils.fmt('type(o) = %s must be "string" or "table"', o_type))
  end
end


--- Checks if the provided object is a string or table that is neither nil nor empty.
---
---@param o string|table|nil: the object to check
---@return boolean: true if the provided object is neither nil nor empty, false otherwise
function TestUtils.not_nil_or_empty(o)
  return o ~= nil and not TestUtils.is_empty(o)
end


--- Checks that all key/value pairs in table l exist in table r.
---
---@param l table: the table w/ key/value pairs to check for in r
---@param r table: the table w/ that's checked against key/value pairs in l
---@return boolean: true if all key/value pairs in table l exist in table r, false
--- otherwise
function TestUtils.table_contains(l, r)
  for k, v in pairs(l) do
    if r[k] == nil then
      return false
    end

    if v ~= r[k] then
      return false
    end
  end

  return true
end


--- Checks that table l "shallow equals" table r.
---
---@param l table: a table to check for equality
---@param r table: another table to check for equality
---@return boolean: true if l shallow equals r, false otherwise
function TestUtils.table_equals(l, r)
  return TestUtils.table_contains(l, r) and TestUtils.table_contains(r, l)
end


--- Computes the length of the provided table.
---
---@param tbl table: the table whose length will be computed
---@return integer: the length of the provided table
function TestUtils.table_len(tbl)
  local i = 0

  for _, e in pairs(tbl) do
    if e ~= nil then
      i = i + 1
    end
  end

  return i
end


--- Converts the provided array to a "set-like" table, in which each entry of arr is a
--- key that maps to true.
---
---@generic T
---@param arr T[]: the array to convert to a set-like table
---@return { [T]: boolean }: a set-like table in which in which each entry of arr is a
--- key that maps to true
function TestUtils.to_set(arr)
  local set = {}

  for _, e in ipairs(arr) do
    set[e] = true
  end

  return set
end

return TestUtils


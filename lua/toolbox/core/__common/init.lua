
--- Module for internal use that contains functions used in > 1 core class. Exists to
--- avoid cyclic dependencies.
---
---@class Common
local Common = {}

---@class Common.Array
Common.Array = {}

--- Recursively checks if two arrays are equal.
---
---@generic S, T (S ?= T)
---@param l S[]: an array to check for equality
---@param r T[]: an array to check for equality
---@return boolean: true if l shallow equals r, false otherwise
function Common.Array.equals(l, r)
  if #l ~= #r then
    return false
  end

  for i = 1, #l do
    -- TODO: refactor utils so toolbox.meta.type can be imported and used here
    if type(l[i]) ~= type(r[i]) then
      return false
    ---@note: no need to type check both thanks to first if/else case
    elseif Common.Table.is(l[i]) and not Common.Array.equals(l[i], r[i]) then
      return false
    elseif not Common.Table.is(l[i]) and l[i] ~= r[i] then
      return false
    end
  end

  return true
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
function Common.Array.slice(arr, s, e)
  if #arr == 0 then
    return {}
  end

  if e == nil then
    e = #arr
  elseif e < 1 then
    e = e + #arr
  end

  if s > #arr then
    return {}
  end

  s = Common.Num.bounds(s, 1, #arr)
  e = Common.Num.bounds(e or #arr, 1, #arr)

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

---@class Common.Bool
Common.Bool = {}

-- TODO: replace w/ Callable
local function func_or_val(ToF)
  if type(ToF) == 'function' then
    return ToF()
  end

  return ToF
end


--- Function that makes Lua ternary expressions more like those in other languages.
---
--- Note: to return functions, the functions themselves must be wrapped in functions.
---
---@generic TType, FType
---@param cond boolean: the condition to evaluate
---@param T TType|fun(...): t: TType: value if cond == true
---@param F (FType|fun(...): t: FType)?: optional, for cases in which false means a nil
-- value; value if cond == false
---@return TType|FType: T if cond evaluates to true, F otherwise
function Common.Bool.ternary(cond, T, F)
  -- TODO: replace "func_or_val" w/ toolbox.functional.callable.Callable
  if cond then return func_or_val(T) else return func_or_val(F) end
end


--- Returns bool if bool ~= nil, otherwise returns default.
---
---@param bool boolean|nil: the boolean to return if not nil
---@param default boolean: the value to return if bool is nil
---@return boolean: bool if bool ~= nil, otherwise default
function Common.Bool.or_default(bool, default)
  return Common.Bool.ternary(bool == nil, default, bool)
end

---@class Common.Num
Common.Num = {}

--- Returns the provided number n if it is min < n < max, otherwise, returns min if n < min
--- or max if n > max.
---
---@param n number: the number to bound
---@param min number: the minimum number that this function will return; must be < max
---@param max number: the maximum number that this function will return; must be > min
---@return number: n if min < n < max, otherwise min if n < min or max if n > max
---@error if min > max
function Common.Num.bounds(n, min, max)
  if min > max then
    error(string.format('Num.bounds: min (%s) must be <= max (%s)', min, max))
  end

  if n < min then
    return min
  end

  if n > max then
    return max
  end

  return n
end

---@class Common.String
Common.String = {}

--- Wrapper around string.format, in case there's any desire to change the templating
--- mechanism in the future.
---
--- TODO: replace in all projects uses of string.format w/ this function.
---
---@see string.format
function Common.String.fmt(base, ...)
  return string.format(base, ...)
end


--- Returns true if the provided string nil or empty.
---
---@param str string?: the string to check
---@return boolean: true if the provided string is nil or empty, false otherwise
function Common.String.nil_or_empty(str)
  return str == nil or str == ''
end

---@class Common.Table
Common.Table = {}

--- Util that determines whether the provided value is a table.
---
---@param o any?: the value to check
---@return boolean: true if o is a table, false otherwise
function Common.Table.is(o)
  return type(o) == 'table'
end


--- TODO: remove in favor of Dict function.
--- Checks if the provided table is empty.
---
--- Note: a table is still considered empty if it's comprised of any number of key-value
--- pairs (k, v) where all v == nil.
---
---@generic K, V
---@param tbl { [K]: V }: the table to check
---@return boolean: true if the provided table is empty, false otherwise
function Common.Table.is_empty(tbl)
  for _, v in pairs(tbl) do
    if v ~= nil then
      return false
    end
  end

  return true
end


--- TODO: remove in favor of Dict function.
--- Checks that an array-like table table is nil or empty.
--
---@generic K, V
---@param tbl { [K]: V }: the table to check
---@return boolean: true if the table is nil or empty, false otherwise
function Common.Table.nil_or_empty(tbl)
  return tbl == nil or Common.Table.is_empty(tbl)
end

return Common


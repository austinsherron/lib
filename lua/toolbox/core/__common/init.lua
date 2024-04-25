--- Module for internal use that contains functions used in > 1 core class. Exists to
--- avoid cyclic dependencies.
---
---@class Common
local Common = {}

---@class Common.Array
Common.Array = {}

--- Appends item to arr.
---
---@note: this function mutates arr.
---
---@generic T
---@param arr T[]: the array to which to append item
---@param item T: the item to append to array
function Common.Array.append(arr, item)
  table.insert(arr, item)
end

--- Returns the length of the provided array. A nil array's length is 0.
--
---@generic T
---@param arr T[]|nil: the array whose length will be checked
---@return integer: the length of the provided array; 0 if the array is nil
function Common.Array.len(arr)
  ---@diagnostic disable-next-line: return-type-mismatch
  return Common.Bool.ternary(arr == nil, 0, function()
    return #arr
  end)
end

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

--- Gets the value of arr at idx, or optionally sets it if val is non-nil.
---
---@note: Negative indices function like "#arr + idx + 1".
---
---@generic T
---@param arr T[]: the array from which to retrieve a value
---@param idx integer: the idx to retrieve
---@param val T|nil: an optional value to set at idx
---@return T: the value of arr at idx, or at "#arr + idx + 1" if idx < 0
function Common.Array.index(arr, idx, val)
  idx = Common.Bool.ternary(idx < 0, #arr + idx + 1, idx)

  if val ~= nil then
    arr[idx] = val
  end

  return arr[idx]
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
  if cond then
    return func_or_val(T)
  else
    return func_or_val(F)
  end
end

--- Returns bool if bool ~= nil, otherwise returns default.
---
---@param bool boolean|nil: the boolean to return if not nil
---@param default boolean: the value to return if bool is nil
---@return boolean: bool if bool ~= nil, otherwise default
function Common.Bool.or_default(bool, default)
  return Common.Bool.ternary(bool == nil, default, bool)
end

---@class Common.Dict
Common.Dict = {}

--- Checks that dict contains the provided key.
---
---@generic K, V
---@param dict { [K]: V }|nil: the dict to check
---@param key any: the key to check
---@return boolean: true if key is a key in dict (i.e.: maps to a non-nil value), false
--- otherwise
function Common.Dict.has_key(dict, key)
  return dict ~= nil and dict[key] ~= nil
end

--- Checks that dict contains all the provided keys.
---
---@generic K, V
---@param dict { [K]: V }|nil: the dict to check
---@param keys any[]: the keys to check
---@return boolean: true if every key in keys is a key in dict (i.e.: maps to a non-nil
--- value), false otherwise
function Common.Dict.has_keys(dict, keys)
  for _, key in ipairs(keys) do
    if not Common.Dict.has_key(dict, key) then
      return false
    end
  end

  return true
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

--- Joins an array of strings w/ sep.
---
---@param strs string[]: the strings to join
---@param sep string|nil: optional, defaults to ','; the char string w/ which to join strs
---@return string: a single string comprised of the elements of strs, joined by sep
function Common.String.join(strs, sep)
  sep = sep or ','

  if #strs == 0 then
    return ''
  end
  if #strs == 1 then
    return strs[1]
  end

  local out = ''

  for i, str in ipairs(strs) do
    out = Common.Bool.ternary(i == 1, str, out .. sep .. str)
  end

  return out
end

---@class Common.Table
Common.Table = {}

--- Util that determines whether the provided value is a table. Optionally checks that, if
--- the value is a table, it conforms to the provided spec.
---
---@param o any|nil: the value to check
---@param spec string[]|nil: optional; if o is a table, an array of fields it must have
---@return boolean: true if o is a table and optionally conforms to spec, false otherwise
function Common.Table.is(o, spec)
  if type(o) ~= 'table' then
    return false
  elseif spec == nil then
    return true
  end

  return Common.Dict.has_keys(o, spec)
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

--- Creates an array-like table from the keys of tbl. An optional transform function can
--- perform arbitrary transformations on extracted keys.
---
---@generic K, V, T
---@param tbl { [K]: V }: the table from which to extract keys
---@param transform (fun(k: K, v: V): m: T)|nil: an optional function to transform extracted
--- keys
---@return K[]|T[]: an array-like table that contains the keys of tbl, optionally transformed
-- by the provided transform function
function Common.Table.keys(tbl, transform)
  local out = {}
  transform = transform or function(k, _)
    return k
  end

  for k, v in pairs(tbl) do
    table.insert(out, transform(k, v))
  end

  return out
end

--- Home-baked "pack" table function.
---
---@see table.pack
---@param ... any: values to pack
---@return table: the values passed to pack into (i.e.: wrap in) a table
function Common.Table.pack(...)
  local pack = pack or table.pack

  if pack == nil then
    return { ... }
  end

  local packed = pack(...)
  -- pack seems to sometimes (always?) add a key-value pair n = #packed, which I don't
  -- want (or haven't found a reason to yet)
  packed.n = nil
  return packed
end

--- Consolidates table.unpack vs unpack check that's necessary in certain contexts.
---
---@see unpack
---@see table.unpack
---@param tbl table: the table to unpack
---@return ...: the elements of tbl
function Common.Table.unpack(tbl)
  unpack = unpack or table.unpack

  return unpack(tbl)
end

--- Creates a "shallow copy" of the provided table, i.e.: creates a new table to which
--- keys/values are assigned w/out any consideration of their types.
---
---@param tbl { [any]: any }: the table to shallow copy
---@return { [any]: any }: a "shallow copy" of the provided table
function Common.Table.shallow_copy(tbl)
  local new = {}

  for k, v in pairs(tbl) do
    new[k] = v
  end

  return new
end

--- Merges table r into table l. Note: this function can (read: likely will) mutate table l.
---
---@generic K, V, S, T
---@param l { [K]: V }: the table into which table r will be merged; colliding values are
--- overwritten in this table; this table can be mutated by this function
---@param r { [S]: T }: the table to merge into table l
function Common.Table.merge(l, r)
  for k, v in pairs(r) do
    l[k] = v
  end
end

--- Creates a new table by performing a shallow copy of table l and merging table r into
--- that copy.
---
---@param l { [any]: any }: the table whose copy will have table r merged into it; colliding values
--- from this table are overwritten
---@param r { [any]: any }: the table that will be merged into the copy of table l
---@return { [any]: any }: a new table created by performing a shallow copy of table l and
--- merging table r into that copy
function Common.Table.combine(l, r)
  local new = Common.Table.shallow_copy(l)
  Common.Table.merge(new, r)

  return new
end

return Common

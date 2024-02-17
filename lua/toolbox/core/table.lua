local Common = require 'toolbox.core.__common'

local stringify = require 'toolbox.common.stringify'

--- Contains functions for interacting w/ and manipulating tables, either array or
--- dict-like.
---
---@class Table
local Table = {}

---@see Common.Table.is
function Table.is(...)
  return Common.Table.is(...)
end

---@see Common.Table.is_empty
function Table.is_empty(...)
  return Common.Table.is_empty(...)
end

---@see Common.Table.nil_or_empty
function Table.nil_or_empty(...)
  return Common.Table.nil_or_empty(...)
end

--- TODO: remove in favor of Dict function.
--- Checks that the provided table is not nil nor empty.
---
---@generic K, V
---@param tbl { [K]: V }|nil: the table to check
---@return boolean: true if the table is not nil nor empty, false otherwise
function Table.not_nil_or_empty(tbl)
  return tbl ~= nil and not Table.is_empty(tbl)
end

--- Checks whether val is a value is in tbl.
---
---@note: this function uses "shallow equality" for its containment check, so it's only
--- guaranteed to work as expected w/ primitive (non-table) values or objects instantiated
--- from classes in which the "__eq" metamethod has been implemented.
---
---@generic K, V
---@param tbl { [K]: V }: the table to check
---@param val V: the value to check
---@return boolean: true if val is a value in tbl, false otherwise
function Table.contains(tbl, val)
  for _, v in pairs(tbl) do
    if v == val then
      return true
    end
  end

  return false
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
function Table.keys(tbl, transform)
  local out = {}
  transform = transform or function(k, _)
    return k
  end

  for k, v in pairs(tbl) do
    table.insert(out, transform(k, v))
  end

  return out
end

--- Creates an array-like table from the values of tbl. An optional transform function can
--- perform arbitrary transformations on extracted values.
---
---@generic K, V, T
---@param tbl { [K]: V }: the table from which to extract values
---@param transform (fun(v: V, k: K): m: T)|nil: an optional function to transform extracted
--- values
---@return V[]|T[]: an array-like table that contains the values of tbl, optionally transformed
-- by the provided transform function
function Table.values(tbl, transform)
  local out = {}
  transform = transform or function(v, _)
    return v
  end

  for k, v in pairs(tbl) do
    table.insert(out, transform(v, k))
  end

  return out
end

--- Recursively flattens the provided array-like table. The table can contain arbitrary
--- non-table elements as well as arbitrarily nested tables.
---
--- TODO: move to array.lua.
---
---@param arrs (any|any[])[]: a possibly arbitrarily nested array-like table
---@return any[]: a flat array comprised of the elements of arrs and its arbitrarily
--- nested sub-arrays
function Table.flatten(arrs)
  local out = {}

  for _, item in ipairs(arrs) do
    if Table.is(item) then
      local flat = Table.flatten(item)
      out = Table.concat({ out, flat })
    else
      table.insert(out, item)
    end
  end

  return out
end

---@see Common.Table.pack
function Table.pack(...)
  return Common.Table.pack(...)
end

--- Consolidates table.unpack vs unpack check that's necessary in certain contexts.
---
---@see unpack
---@see table.unpack
---@param tbl table: the table to unpack
---@return ...: the elements of tbl
function Table.unpack(tbl)
  unpack = unpack or table.unpack

  return unpack(tbl)
end

--- Returns the only key-value pair from tbl. If strict == false and #tbl ~= 1, returns:
---
---   * #tbl < 1 -> nil, nil
---   * #tbl > 1 -> random key, random value
---
---@generic K, V
---@param tbl { [K]: V } the table from which to extract the only value
---@param strict boolean?: if true, raise error if #tbl ~= 1; optional, defaults to true
---@return K|nil: the only key in tbl
---@return V|nil: the only value in tbl
---@error if strict == true and n < 1 or n > 1, where n = # key-value pairs in tbl
function Table.get_only(tbl, strict)
  strict = Common.Bool.or_default(strict, true)

  if tbl == nil and strict then
    error 'Tbl.get_only: tbl=nil'
  end

  local the_key, the_val = nil, nil

  for k, v in pairs(tbl) do
    if strict and the_key ~= nil then
      error 'Tbl.get_only: #tbl > 1'
    end

    the_key, the_val = k, v
  end

  if strict and the_key == nil then
    error 'Tbl.get_only: #tbl < 1'
  end

  return the_key, the_val
end

---@generic K, V, S
---@alias TableKeyMapper fun(k: K, v: V, i: integer): m: S
---@alias TableValueMapper fun(v: V, k: K, i: integer): m: S

--- Maps the provided table to a new table w/ keys/values transformed by the provided functions.
---
---@generic K, V, S, T
---@param tbl { [K]: V }: the table to transform
---@param xfms { keys: TableKeyMapper|nil, vals: TableValueMapper|nil }:
--- table of mapping functions
---@return { [K]: V }|{ [S]: V }|{ [K]: T }|{ [S]: T }: a table that contains the keys/values
-- of tbl, optionally transformed by the provided transform functions
function Table.map_items(tbl, xfms)
  xfms = xfms or {}

  local transform_k = xfms.keys or function(k, _, _)
    return k
  end
  local transform_v = xfms.vals or function(v, _, _)
    return v
  end

  local out = {}
  local i = 1

  for k, v in pairs(tbl) do
    out[transform_k(k, v, i)] = transform_v(v, k, i)
    i = i + 1
  end

  return out
end

---@generic E, K, V
---@alias ArrayToDictKeyMapper fun(e: E, i: integer): k: K
---@alias ArrayToDictValueMapper fun(e: E, i: integer): v: V
---@alias ArrayToDictItemMapper fun(e: E, i: integer): k: K, v: V

---@return ArrayToDictItemMapper
local function make_to_dict_xfm_fn(xfms)
  if type(xfms) == 'function' then
    return xfms
  end

  local xfrm_k = Table.safeget(xfms, 'keys') or function(k, _)
    return k
  end
  local xfrm_v = Table.safeget(xfms, 'vals') or function(v, _)
    return v
  end

  return function(v, i)
    return xfrm_k(v, i), xfrm_v(v, i)
  end
end

--- Transforms the provided array-like table to a dict like table.
---
---@generic E, K, V
---@param arr E[]: the array-like table to transform
---@param xfms { keys: ArrayToDictKeyMapper|nil, vals: (ArrayToDictValueMapper)|nil }|ArrayToDictItemMapper|nil:
--- table mapping of mapping functions, or single mapping function that returns both keys
--- and values
---@return { [K]: V }: a dict-like table constructed from the values of arr and the
--- provided mapping functions
function Table.to_dict(arr, xfms)
  local out = {}
  local xfm = make_to_dict_xfm_fn(xfms)

  for i, e in ipairs(arr) do
    local k, v = xfm(e, i)
    out[k] = v
  end

  return out
end

---@see Common.Table.shallow_copy
function Table.shallow_copy(...)
  return Common.Table.shallow_copy(...)
end

--- Converts arbitrary tables to human-readable strings.
---
---@see toolbox.common.stringify
function Table.tostring(...)
  return stringify(...)
end

--- Splits tbl into two tables: a table w/ key-value pairs w/ keys corresponding to
--- entries in "left", and a table w/ all other key-value pairs in tbl.
---
---@param tbl { [any]: any }: the table to split
---@param left any[]: an array-like table that specifies key-value pairs to pick from tbl
--- and include in the first return value
---@return { [any]: any }: a table w/ key-value pairs whose keys correspond to entries in left
---@return { [any]: any }: a table w/ key-value pairs whose keys don't correspond to entries
--- in left
function Table.split(tbl, left)
  local l, r = {}, {}

  for k, v in pairs(tbl) do
    if Table.contains(left, k) then
      l[k] = v
    else
      r[k] = v
    end
  end

  return l, r
end

--- Picks a single value of tbl and returns it + a new table w/out that key-value pair.
--- For example:
---
---    (Tbl.split_one({ a = 1, b = 2, c = 3 }, 'b')) == (2, { a = 1, c = 3 })
---
---@param tbl { [any]: any }: the table out of which to pick a value
---@param k any: the key that corresponds to the value to pick
---@return any|nil: the value that corresponds to the key = k in tbl, if any
---@return { [any]: any }: all values in tbl that don't correspond to key = k
function Table.split_one(tbl, k)
  local one, rest = Table.split(tbl, { k })
  local _, the_one = Table.get_only(one, false)

  return the_one, rest
end

--- Given an arbitrary dict-like table and an array-like table of keys, this function
--- picks from tbl the key-value pairs whose keys correspond to entries in keep. For
--- example:
---
---   Tbl.pick({ a = 1, b = 2, c = 3 }, { 'a', 'c', 'd' }) == { a = 1, c = 3 }
---
--- For clarity: this function's return value would be the same as the left return value
--- of a comparable Tbl.split call.
--=
---@generic K, V
---@param tbl { [K]: V }|K[]|nil: the table from which to pick values
---@param keep K[]: an array-like table that specifies key-value pairs to pick from tbl
---@param unpacked boolean|nil: optional; defaults to false; if true, return unpacked
--- picked values
---@return { [K]: V }|...: key-value pairs picked from tbl whose keys correspond to
--- entries in keep, or unpacked picked values if unpacked == true
function Table.pick(tbl, keep, unpacked)
  unpacked = unpacked or false

  local out = {}

  for _, key in ipairs(keep) do
    if tbl[key] ~= nil then
      out[key] = tbl[key]
    end
  end

  return Common.Bool.ternary(unpacked, function()
    return Table.unpack(Table.values(out))
  end, out)
end

--- The inverse of pick: given an arbitrary key-value table and a set "exclude", the
--- function picks from tbl the key-value pairs whose keys do not correspond to entries
--- in exclude. For example:
---
---   Tbl.pick_out({ a = 1, b = 2, c = 3 }, { 'b', 'd', 'e' }) == { a = 1, c = 3 }
---
--- For clarity: this function's return value would be the same as the right return value
--- of a comparable Tbl.split call.
---
---@generic K, V
---@param tbl { [K]: V }: the table out of which to pick
---@param exclude Set: the set of keys to exclude from the return value
---@param unpacked boolean|nil: optional; defaults to false; if true, return unpacked
--- picked out values
---@return { [K]: V }|...: a table comprised of the key-value pairs in tbl whose keys
--- aren't present in exclude, or unpacked picked out values if unpacked == true
function Table.pick_out(tbl, exclude, unpacked)
  unpacked = unpacked or false

  local out = {}

  for k, v in pairs(tbl) do
    if not exclude:contains(k) then
      out[k] = v
    end
  end

  return Common.Bool.ternary(unpacked, function()
    return Table.unpack(Table.values(out))
  end, out)
end

--- Attempts to retrieve a value from tbl "safely", i.e.: if tbl is nil, this function
--- returns nil instead of raising an error. The provided keys can be either a string or
--- an array of strings, in which case this function will attempt to recursively fetch the
--- value at keys[-1] in nested tables nested w/in tbl.
---
---@generic K, V
---@param tbl { [K|integer]: V }|nil: an array-like or dict-like table from which to retrieve
--- values
---@param keys string[]|integer[]|string|integer: a string\int key or a nested array of
--- keys to attempt to use to retrieve values from a table
---@return V|nil: the value at index "keys", or the value from recursively nested tables
--- at index "keys[-1]"
function Table.safeget(tbl, keys)
  if Table.nil_or_empty(tbl) then
    return nil
  end

  if not Table.is(keys) then
    ---@diagnostic disable-next-line: need-check-nil
    return Common.Bool.ternary(tbl ~= nil, function()
      return tbl[keys]
    end)
  end

  local key = keys[1]
  ---@diagnostic disable-next-line: param-type-mismatch
  keys = Common.Array.slice(keys, 2)

  ---@diagnostic disable-next-line: need-check-nil
  local val = tbl[key]

  if Table.nil_or_empty(keys) then
    return val
  end

  return Common.Bool.ternary(Table.is(val), function()
    return Table.safeget(val, keys)
  end)
end

function Table.safeset(tbl, keys, val, create)
  if Table.nil_or_empty(tbl) then
    return
  end

  if not Table.is(keys) or #keys == 1 then
    local key = ternary(Table.is(keys), function()
      return keys[1]
    end, keys)
    tbl[key] = val
    return tbl
  end

  local key = Common.Array.index(keys, -1)
  keys = Common.Array.slice(keys, 1, -1)
  local outer = Table.safeget(tbl, keys)

  if outer == nil then
    return tbl
  end

  outer[key] = val
  return tbl
end

---@see Common.Table.merge
function Table.merge(...)
  return Common.Table.merge(...)
end

--- Concatenates array-like tables into a single table.
---
--- TODO: move to array.lua.
---
---@generic T
---@param tbls T[][]: the tables to concatenate
---@return T[]: a single table w/ all values in all provided tables
function Table.concat(tbls)
  local out = {}

  for _, tbl in ipairs(tbls) do
    for _, v in ipairs(tbl) do
      table.insert(out, v)
    end
  end

  return out
end

---@see Common.Table.combine
function Table.combine(...)
  return Common.Table.combine(...)
end

--- Combine tables in tbls in to a single, new table by iteratively calling tbl.combine on
--- tables in tbls.
---
---@param tbls { [any]: any }[]: the tables to combine
---@return { [any]: any} : a single, new table w/ the combined values of the tables in tbls
function Table.combine_many(tbls)
  local combined = {}

  for _, tbl in ipairs(tbls) do
    Table.merge(combined, tbl)
  end

  return combined
end

--- Create and return a new table in which the keys/values in the provided table are swapped.
--- Note: this function will fail if tbl contains nil values.
---
---@generic K, V
---@param tbl { [K]: V }: the table for which to reverse keys/values
---@param fail_on_dup boolean|nil: optional, defaults to false; if true, the function will
--- throw an error if a duplicate value is found, i.e.: if a value will become a key that
--- will override another value/key pair
---@return { [V]: K }: a table constructed from the provided table, but w/ the keys/values swapped
---@error if fail_on_dup == false and there are duplicate values in tbl; if there's a nil
---       value in tbl
function Table.reverse_items(tbl, fail_on_dup)
  fail_on_dup = fail_on_dup or false
  local rev = {}

  for k, v in pairs(tbl) do
    if rev[v] ~= nil and fail_on_dup then
      error('duplicate value=' .. v .. ' encountered in table')
    end
    rev[v] = k
  end
  return rev
end

--- Creates a new table that is the concatenation of two array-like tables.
---
---@generic S, T
---@param l S[]: an array-like table to combine w/ r
---@param r T[]: an array-like table to combine w/ l
---@return (S|T)[]: a new table that is the concatenation of two array-like tables
function Table.array_combine(l, r)
  -- don't technically need the "or", but the lsp complains if we don't, as it's not smart
  -- enough to tell that new will never be nil here since l can't be
  local new = Table.shallow_copy(l)

  for _, item in ipairs(r) do
    table.insert(new, item)
  end

  return new
end

return Table

local num = require 'toolbox.core.num'


local Tbl = {}

--- Creates an array-like table from the keys of tbl. An optional transform function can
--  perform arbitrary transformations on extracted keys.
--
---@generic K, V, T
---@param tbl { [K]: V }: the table from which to extract keys
---@param transform (fun(k: K): m: T)?: an optional function to transform extracted keys
---@return K[]|T[]: an array-like table that contains the keys of tbl, optionally transformed
-- by the provided transform function
function Tbl.keys(tbl, transform)
  local out = {}
  transform = transform or function(k) return k end

  for k, _ in pairs(tbl) do
    table.insert(out, transform(k))
  end

  return out
end


--- Creates an array-like table from the values of tbl. An optional transform function can
--  perform arbitrary transformations on extracted values.
--
---@generic K, V, T
---@param tbl { [K]: V }: the table from which to extract values
---@param transform (fun(v: V): m: T)?: an optional function to transform extracted values
---@return V[]|T[]: an array-like table that contains the values of tbl, optionally transformed
-- by the provided transform function
function Tbl.values(tbl, transform)
  local out = {}
  transform = transform or function(v) return v end

  for _, v in pairs(tbl) do
    table.insert(out, transform(v))
  end

  return out
end


--- Maps the provided table to a new table w/ keys/values transformed by the provided functions.
--
---@generic K, V, S, T
---@param tbl { [K]: V }: the table to transform
---@param keys (fun(k: K): m: S)?: key mapping function
---@param vals (fun(v: V): m: T)?: value mapping function
---@return { [K]: V }|{ [S]: V }|{ [K]: T }|{ [S]: T }: a table that contains the keys/values
-- of tbl, optionally transformed by the provided transform functions
function Tbl.map_items(tbl, keys, vals)
  local transform_k = keys or function(k) return k end
  local transform_v = vals or function(v) return v end

  local out = {}

  for k, v in pairs(tbl) do
    out[transform_k(k)] = transform_v(v)
  end

  return out
end


--- Creates a "shallow copy" of the provided table, i.e.: creates a new table to which
--  keys/values are assigned w/out any consideration of their types.
--
---@generic K, V
---@param tbl { [K]: V }: the table to shallow copy
---@return { [K]: V }: a "shallow copy" of the provided table
function Tbl.shallow_copy(tbl)
  local new = {}

  for k, v in pairs(tbl) do new[k] = v end

  return new
end


local function tostring_can_be_table(maybe_tbl)
  if type(maybe_tbl) == 'table' then
    return Tbl.tostring(maybe_tbl)
  end

  return tostring(maybe_tbl)
end


--- Recursively constructs a string representation of the provided table. Non-table
--  constituents are "stringified" using the builtin "tostring" function.
--
---@generic K, V
---@param tbl { [K]: V }?: the table for which to construct a string representation
---@param o string?: the opening "brace" of the string representation
---@param c string?: the closing "brace" of the string representation
---@return string: a string representation of the provided table
function Tbl.tostring(tbl, o, c)
  if tbl == nil then
    return ''
  end

  local str = ''; local arr_str = ''
  local i = 1; local j = 1

  for k, v in pairs(tbl) do
    local nxt = (i == 1 and '' or ', ') .. tostring(k) .. ' = ' .. tostring_can_be_table(v)
    str = str .. nxt
    i = i + 1

    if arr_str ~= nil and tbl[j] ~= nil then
      nxt = (j == 1 and '' or ', ') .. tostring_can_be_table(v)
      arr_str = arr_str .. nxt
      j = j + 1
    elseif arr_str ~= nil then
      arr_str, j = nil, nil
    end
  end

  o = o or '{ '
  c = c or ' }'

  return o .. (arr_str or str) .. c
end


--- Returns true if the provided table is "array-like", i.e.: if it has no gaps in its
--  values and only numeric, sequential keys; false otherwise (or if tbl is nil).
--
---@generic K, V
---@param tbl { [K]: V }: the table to check
---@return boolean: true if the provided table is "array-like", false otherwise or if tbl
-- is nil
function Tbl.is_array(tbl)
  local i = 0

  for _ in pairs(tbl) do
    i = i + 1

    if tbl[i] == nil then
      return false
    end
  end

  return true
end


--- Returns true if the provided table is "array-like", i.e.: if it has no gaps in its
--  values and only numeric, sequential keys; false otherwise (or if tbl is nil).
--
--  This function differs from tbl.is_array in impl: this function uses a "quick and dirty"
--  hack to check for array-like properties. The return values of this and tbl.is_array can
--  differ!
--
---@generic K, V
---@param tbl { [K]: V }: the table to check
---@return boolean: true if the provided table is "array-like", false otherwise or if tbl
-- is nil
function Tbl.is_array__fast(tbl)
  if tbl == nil then
    return false
  end

  return tbl[1] ~= nil and tbl[#tbl] ~= nil
end


--- Merges table r into table l. Note: this function can (read: likely will) mutate table l.
--
---@generic K, V, S, T
---@param l { [K]: V }: the table into which table r will be merged; colliding values are
-- overwritten in this table; this table can be mutated by this function
---@param r { [S]: T }: the table to merge into table l
function Tbl.merge(l, r)
  for k, v in pairs(r) do
    l[k] = v
  end
end


--- Creates a new table by performing a shallow copy of table l and merging table r into
--  that copy.
--
---@generic K, V, S, T
---@param l { [K]: V }: the table whose copy will have table r merged into it; colliding values
-- from this table are overwritten
---@param r { [K]: V }: the table that will be merged into the copy of table l
---@return { [K|S]: V|T }: a new table created by performing a shallow copy of table l and
---merging table r into that copy
function Tbl.combine(l, r)
  local new = Tbl.shallow_copy(l)
  Tbl.merge(new, r)

  return new
end


--- Combine tables in tbls in to a single, new table by iteratively calling tbl.combine on
--  tables in tbls.
--
---@param tbls { [any]: any }[]: the tables to combine
---@return { [any]: any} : a single, new table w/ the combined values of the tables in tbls
function Tbl.combine_many(tbls)
  local combined = {}

  for _, tbl in ipairs(tbls) do
    Tbl.merge(combined, tbl)
  end

  return combined
end


--- Create and return a new table in which the keys/values in the provided table are swapped.
--  Note: this function will fail if tbl contains nil values.
--
---@generic K, V
---@param tbl { [K]: V }: the table for which to reverse keys/values
---@param fail_on_dup boolean?: if true, the function will throw an error if a duplicate value
-- is found, i.e.: if a value will become a key that will override another value/key pair.
---@return { [V]: K }: a table constructed from the provided table, but w/ the keys/values swapped
---@error if fail_on_dup == false and there are duplicate values in tbl; if there's a nil
--        value in tbl
function Tbl.reverse_items(tbl, fail_on_dup)
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


--- Returns a "slice" of an array-like table. For example:
--
--    local t = { 1, 2, 3, 4, 5 }
--    tbl.slice(t, 2, 4) == { 2, 3, 4 }
--
--  s is bounded at 1, and e is bounded at #tbl. If s > e, and error is thrown.
--
---@generic K, V
---@param tbl { [K]: V }: the table from which to take a slice
---@param s integer: the lower bound of the slice
---@param e integer: the upper bound of the slice
---@return { [K]: V }: a slice of an array-like table
function Tbl.slice(tbl, s, e)
  if #tbl == 0 then
    return {}
  end

  s = num.bounds(s, 1, #tbl)
  e = num.bounds(e, 1, #tbl)

  if s > e then
    error('Invalid params: start = ' .. tostring(s) .. ' > end = ' .. tostring(e))
  end

  local slice = {}

  for i = s or 1, e or #tbl, 1 do
    local j = #slice + 1
    slice[j] = tbl[i]
  end

  return slice
end


--- Creates a new table that is the concatenation of two array-like tables.
--
---@generic S, T
---@param l S[]: an array-like table to combine w/ r
---@param r T[]: an array-like table to combine w/ l
---@return (S|T)[]: a new table that is the concatenation of two array-like tables
function Tbl.array_combine(l, r)
  -- don't technically need the "or", but the ls complains if we don't, as it's not smart
  -- enough to tell that new will never be nil here since l can't be
  local new = Tbl.shallow_copy(l) or {}
  for _, item in ipairs(r) do
    table.insert(new, item)
  end

  return new
end

return Tbl


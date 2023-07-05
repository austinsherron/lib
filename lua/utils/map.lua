require 'lib.lua.core.table'


local Map = {}

--- Filters items in tbl according to the provided filter function.
--
---@param tbl table: the table to filter; if not array-like, keys will not be inserted into
-- the returned table; not modified
---@param filter function: used to test each item in tbl; if filter returns true for an item,
-- that item will be included in the return value
---@return table: a new table that contains values filtered by filter
function Map.filter(tbl, filter)
  local out = {}

  for _, item in ipairs(tbl) do
    if (filter(item)) then
      table.insert(out, item)
    end
  end

  return out
end


--- transforms items in tbl according to mapper.
--
---@param tbl table: the table to map; if not array-like, keys will not be inserted into
-- returned table; not modified
---@param mapper function: called on each item in tbl; the return table is comprised of the
-- return values of this function from each item in the original tbl
---@return table: a table comprised of the return value of mapper called on each item in the
-- original tbl
function Map.map(tbl, mapper)
  local out = {}

  for _, item in ipairs(tbl) do
    table.insert(out, mapper(item))
  end

  return out
end


--- Reduces items in tbl based on the provided reducer function and initial value.
---@param tbl table the table to reduce; if not array-like, keys will not be inserted into
-- returned table; not modified
---@param reducer function: a function that takes and "combines" in arbitrary ways two
-- values: the combined value so far (or init, before any values have been "reduced") and
-- the "Nth" value of table
---@param init any or nil: the initial reduced value
---@return any: return value of the "reducer" function after having been called on every
-- element of tbl
function Map.reduce(tbl, reducer, init)
  local out = init

  for _, item in ipairs(tbl) do
    out = reducer(item, out)
  end

  return out
end

return Map


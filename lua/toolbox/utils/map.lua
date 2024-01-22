--- A simple implementation of map, filter, reduce.
---
---@class Map
local Map = {}

--- Filters items in arr according to the provided filter function.
--
---@generic T
---@param arr T[]: the array to filter; if not array-like, keys will not be inserted
-- into the returned table; not modified
---@param filter fun(e: T, i: integer): f: boolean: used to test each item in arr; if
--- filter returns true for an item, that item will be included in the return value
---@return T[]: a new table that contains values filtered by filter
function Map.filter(arr, filter)
  local out = {}

  for i, item in ipairs(arr) do
    if filter(item, i) then
      table.insert(out, item)
    end
  end

  return out
end

--- Transforms items in arr according to mapper.
---
---@generic T, M
---@param arr T[]: the array to map; if not array-like, keys will not be inserted into
--- returned table; not modified
---@param mapper fun(e: T, i: integer): m: M: called on each item in arr; the returned
--- array is comprised of the return values of this function from each item in the
--- original arr
---@return M[]: an array comprised of the return value of mapper called on each item in
--- the original array
function Map.map(arr, mapper)
  local out = {}

  for i, item in ipairs(arr) do
    table.insert(out, mapper(item, i))
  end

  return out
end

--- Reduces items in arr based on the provided reducer function and initial value.
---
---@generic T
---@param arr T[]: the array to reduce; if not array-like, keys will not be inserted into
--- returned table; not modified
---@param reducer fun(l: T|nil, r: T, i: integer): c: T: a function that takes and
--- "combines" in arbitrary ways two values: the combined value so far (or init, before
--- any values have been "reduced") and the nth value of table
---@param init T|nil: the initial "reduced" value
---@return T: value of the "reducer" function after having been called on every element of arr
function Map.reduce(arr, reducer, init)
  local out = init

  for i, item in ipairs(arr) do
    out = reducer(item, out, i)
  end

  return out
end

--- Call func on each item in arr.
---
---@generic T
---@param arr T[]: the array whose contents will be arguments to successive calls to func
---@param func fun(e: T, i: integer) the function to call on individual items in arr
function Map.foreach(arr, func)
  for i, item in ipairs(arr) do
    func(item, i)
  end
end

return Map

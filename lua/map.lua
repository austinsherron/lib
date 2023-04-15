require 'lib.lua.table'


function filter(tbl, filter)
  local out = {}

  for _, item in ipairs(tbl) do
    if (filter(item)) then
      table.insert(out, item)
    end
  end

  return out
end


function map(tbl, mapper)
  local out = {}

  for _, item in ipairs(tbl) do
    table.insert(out, mapper(item))
  end

  return out
end


function reduce(tbl, reducer, init)
  local out = init

  for _, item in ipairs(tbl) do
    out = reducer(item, out)
  end

  return out
end


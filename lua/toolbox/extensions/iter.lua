local Bool  = require 'toolbox.core.bool'


--- Contains iterator "next" helper functions.
--
---@class Iter
local Iter = {}

---@private
function Iter.iter(len)
  -- start at nil as that's what standard next function expects
  local i = nil

  return function()
    -- termination condition
    if i ~= nil and i >= len then
      return -1
    end

    local ret = i
    -- increment; using ternary to deal w/ nil
    i = Bool.ternary(i == nil, 1, function() return i + 1 end)
    return ret
  end
end


--- Constructs and returns a next function that returns successive values from the provided
--  array-like table. This utility is useful for implementing iterators via the __ipairs
--  metamethod.
--
---@generic T
---@param arr { [integer]: T}: an array-like table over which to iterate
---@return fun(): (number, T): a next function for iterating over arbitrary array-like
-- tables
function Iter.array(arr)
  local nxt = Iter.iter(#arr)
  local idx = 0

  return function()
    local i = nxt()
    idx = idx + 1

    if #arr == 0 then
      return nil, nil
    end

    if i == -1 then
      return nil
    end

    local _, v = next(arr, i)
    return idx, v
  end
end


-- TODO: WIP
-- function Next.table(tbl)
--   local keys = Table.keys(tbl)
--   local nxt = Next.array(keys, true)
--
--   return function()
--     local k, v = nxt()
--
--     if k == nil then
--       return
--     end
--
--     local val, _ = next(tbl, k)
--     return val
--   end
-- end

return Iter


local Common = require 'toolbox.core.__common'

--- Contains utilities for interacting w/ function args.
---
---@class Args
local Args = {}

--- Packs the provided vararg, filters nil values from it, and returns it as an array.
---
---@generic T
---@param ... T: vararg
---@return T[]: the vararg, packed and w/ nil values filtered from it; if vararg is
--- "empty", an empty array
function Args.filter_nil(...)
  local args = Common.Table.pack(...) or {}
  local out = {}

  for _, arg in ipairs(args) do
    if arg ~= nil then
      table.insert(out, arg)
    end
  end

  return out
end

--- Returns the provided arguments as an array. If only a single array argument was
--- provided, the array will be returned.
---
---@generic T
---@param ... T|T[]: vararg or single array of arguments
---@return T[]: the provided arguments as an array, or the single array argument, if
--- provided
function Args.vararg_to_arr(...)
  local args = Common.Table.pack(...)

  if Common.Array.len(args) == 1 and Common.Table.is(args[1]) then
    args = args[1]
  end

  return args
end

return Args

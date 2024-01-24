local Common = require 'toolbox.core.__common'

--- Contains utilities for interacting w/ function args.
---
---@class Args
local Args = {}

--- Returns the provided arguments as an array. If only a single array argument was
--- provided, the array will be returned.
---
---@generic T
---@vararg ... T|T[]:  vararg or single array of arguments
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

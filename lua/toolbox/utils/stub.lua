--- A "stub" class on which any method can be called w/o error.
---
---@class Stub
local Stub = {}
Stub.__index = Stub

--- Constructor
---
---@return Stub: a new instance
function Stub.new()
  return setmetatable({}, Stub)
end

--- A custom __index function that always returns a no-op function.
---
---@return fun(): n: nil: a no-op function
function Stub:__index()
  return function()
    return Stub.new()
  end
end

return Stub

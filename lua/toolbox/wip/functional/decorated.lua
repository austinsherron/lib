local Decorator = require 'toolbox.functional.decorator'

--- Utility that ensures that functions/methods created on a "decorated" object are
--- decorated w/ a function.
---
--- @class Decorated<T>
--- @field private decorator Decorator
--- @field private instance `T`
local Decorated = {}
Decorated.__index = Decorated

--- Constructor
---
---@generic T
---@param fn fun(...: any|nil): r: T: the function w/ which to decorate an object's
--- functions/methods
---@return T
function Decorated.new(fn)
  local this = {
    decorator = Decorator.new(fn),
    instance = {},
  }
  return setmetatable(this, Decorated)
end

function Decorated:__index(k)
  return rawget(rawget(self, 'instance'), k)
  -- return self.instance[k]
end

function Decorated:__newindex(k, v)
  if type(v) == 'function' then
    v = self.decorator:decorate(v)
  end

  local instance = rawget(self, 'instance')
  rawset(instance, k, v)
end

return Decorated

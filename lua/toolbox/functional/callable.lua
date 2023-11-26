local Introspect = require 'toolbox.meta.introspect'


--- A class whose instances can be either values or functions.
---
---@class Callable<T>
---@field private val (`T`|fun(): `T`)
local Callable = {}
Callable.__index = Callable

--- Constructor
--
---@generic T
---@param val T|fun(): T
---@return Callable: a new instance
function Callable.new(val)
  return setmetatable({ val = val }, Callable)
end


--- Constructor for a callable that returns nil.
---
---@return Callable: a new instances that simply returns nil
function Callable.empty()
  return setmetatable({ val = nil }, Callable)
end


--- Enables calling instances as functions. This method returns either the value w/ which
--- the instance was constructed, or the return value of the function w/ which it was
--- constructed.
---
---@generic T
---@return T: value of the return value of value (who wrote this??)
function Callable:__call()
  if Introspect.is_callable(self.val) then
    return self:val()
  end

  return self.val
end

return Callable


local Bool       = require 'toolbox.core.bool'
local Table      = require 'toolbox.core.table'


--- A simple decorator class.
---
---@class Decorator<T>
---@field private fn fun(...: any|nil): `T`
local Decorator = {}
Decorator.__index = Decorator

--- Constructor

---@generic T
---@param fn fun(...: any|nil): r: T: the function w/ which to decorate (i.e.: additional
--- functionality)
---@return Decorator: a new instance
function Decorator.new(fn)
    return setmetatable({ fn = fn }, Decorator)
end


--- Implements function-like "callability" for Decorator instances.
---
---@param ... any|nil: args passed to the call that should be passed through
---@return any|nil: the values(s) returned by the decorator's function, if any
function Decorator:__call(...)
  return self.fn(...)
end


--- Decorates the provided function w/ the decorator's function.
---
---@return function: a function that decorates fn w/ the decorator's function
function Decorator:decorate_one(fn)
  return function(...)
      return self(fn(...))
  end
end


--- Recursively decorates functions and classes in the provided class.
---
--- !! WARNING: This method mutates class !!
---
---@param class table: the class to recursively decorate
---@param recursively boolean|nil: optional, defaults to false; if true, functions in
--- arbitrarily nested tables in class will also be decorated
---@return table: the decorated, mutated class
function Decorator:decorate_all(class, recursively)
  recursively = Bool.or_default(recursively, false)

  for key, prop in pairs(class) do
    if type(prop) == 'function' then
      class[key] = self:decorate(prop, recursively)
    elseif Table.is(prop) and recursively then
      class[key] = self:decorate_all(prop, recursively)
    end
  end

  return class
end


--- Decorates either a single function, or recursively decorate a class, depending on the
--- value provided.
---
--- !! WARNING: This method mutates to_decorate if to_decorate is a class !!
---
---@param to_decorate table|function: the function/table to decorate
---@param recursively boolean|nil: optional, defaults to false; if true and to_decorate is
--- a class (table), functions in arbitrarily nested tables in to_decorate will also be
--- decorated
---@return table|function: the decorated function/table
function Decorator:decorate(to_decorate, recursively)
  if type(to_decorate) == 'function' then
    return self:decorate_one(to_decorate)
  elseif Table.is(to_decorate) then
    return self:decorate_all(to_decorate, recursively)
  else
    error('Decorator.decorate: invalid type(to_decorate)=' .. type(to_decorate))
  end
end


--- Syntactic sugar for Decorator:decorate.
---@see Decorator.decorate
function Decorator:__concat(to_decorate)
  return self:decorate(to_decorate)
end

return Decorator


local String = require 'toolbox.core.string'

--- A "higher-order" class: when instantiated, this class is lua class.
--
---@class Class
local Class = {}

--- Makes the provided class callable.
---
---@generic T
---@param clazz T: the class to make callable
---@param fn string|nil: optional, defaults to "new", the name of the class function to
--- use for calls
---@return T: a callable version of the provided class
function Class.callable(clazz, fn)
  fn = fn or 'new'

  return setmetatable(clazz, {
    __call = function(_, ...)
      return clazz[fn](...)
    end,
  })
end

--- A "constructor" for a class w/ a constructor. The return value of this function can be
--  used for method and property definition, etc., just like a regular lua "class".
--
---@param constructor (fun(...): any|nil)|nil: constructor for the class
---@return table: a lua "class"
function Class.new(constructor)
  constructor = constructor or function()
    return {}
  end

  local Clazz = {}
  Clazz.__index = Clazz

  Clazz = setmetatable(Clazz, {
    __call = function(self, ...)
      return self.new(...)
    end,
  })

  --- Constructor
  function Clazz.new(...)
    local this = constructor(...)
    return setmetatable(this, Clazz)
  end

  --- Custom index metamethod that enables the use of getters for all instance attributes.
  --- Getters are of the form "instance.get[attr]", i.e.: attr == "value", getter ==
  --- "instance.getvalue()".
  function Clazz:__index(k)
    if not String.startswith(k, 'get') then
      return rawget(self, k)
    end

    local attr = String.index(k, 4)
    return function()
      return self[attr]
    end
  end

  return Clazz
end

return {
  Class = Class.new,
  callable = Class.callable,
}

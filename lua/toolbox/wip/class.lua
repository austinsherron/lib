local tbl = require 'toolbox.core.table'


---@alias ClassParams { static_members: table?, constructor: (fun(any?): this: table)? }

--- A "higher-order" class: when instantiated, this class is lua class.
--
---@class Class
local Class = {}

-- class -----------------------------------------------------------------------

--- A "constructor" for a class w/ a constructor. The return value of this function can be
--  used for method and property definition, etc., just like a regular lua "class".
--
---@param class_params ClassParams?: static members and constructor for the class
---@return table: a lua "class"
function Class.class(class_params)
    class_params = class_params or {}

    local static_members = class_params.static_members or {}
    local constructor = class_params.constructor or function(params) return params end

    local Clazz = {}
    Clazz.__index = Clazz
    tbl.merge(Clazz, static_members)

    function Clazz.new(params)
        return setmetatable(constructor(params or {}), Clazz)
    end

    return Clazz
end


---@see Class.class
return function(class_params)
  return Class.class(class_params)
end


--!/usr/bin/lua

-- require 'lib.lua.functions'
require 'lib.lua.table'


-- Class -----------------------------------------------------------------------

function class(class_params)
    local class_params = class_params or {}

    local static_members = class_params.static_members or {}
    local constructor = class_params.constructor or function(params) return params end

    local Class = {}
    Class.__index = table.shallow_copy(static_members)

    function Class.new(params)
        local this = constructor(params)
        params_obj = type(params) == 'table' and params or table.pack(params)

        setmetatable(this, Class)

        return this
    end


    return Class
end

-- Callable --------------------------------------------------------------------

Callable = class({
    constructor = function(val) 
        return { val = val }
    end
})


function Callable:__call()
    return self.val
end


function callable(val)
    return Callable.new(val)
end


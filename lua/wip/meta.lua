local tbl = require 'lib.lua.core.table'


local Meta = {}

-- class -----------------------------------------------------------------------

function Meta.class(class_params)
    class_params = class_params or {}

    local static_members = class_params.static_members or {}
    local constructor = class_params.constructor or function(params) return params end

    local Class = {}
    Class.__index = tbl.shallow_copy(static_members)

    function Class.new(params)
        local this = constructor(params)
        local params_obj = type(params) == 'table' and params or table.pack(params)

        setmetatable(this, Class)

        return this
    end


    return Class
end

-- Callable --------------------------------------------------------------------

local Callable = Meta.class({
    constructor = function(val)
        return { val = val }
    end
})


function Callable:__call()
    return self.val
end


function Meta.callable(val)
    return Callable.new(val)
end

return Meta


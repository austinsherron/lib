local Set = require 'toolbox.extensions.set'

--- Contains utilities for interacting w/ types.
---
---@class Type
local Type = {}

--- Returns the type of "thing".
---
---@param thing any|nil: the thing who's type to return
---@return string: thing's type
function Type.of(thing)
  return type(thing)
end

--- Checks if the provided "thing" is of type the_type. This method considers a thing to
--- have a type if its metatable == the_type.
---
---@param thing any|nil: the thing to check
---@param the_type string|table: the type to check
---@return boolean: true if thing is of type the_type, false otherwise
function Type.is(thing, the_type)
  if Type.of(thing) == the_type then
    return true
  end

  return thing ~= nil and getmetatable(thing) == the_type
end

function Type.are(things, the_type)
  for _, thing in ipairs(things) do
    if not Type.is(thing, the_type) then
      return false
    end
  end

  return true
end

local function mt(thing)
  return getmetatable(thing)
end

--- Creates a function that takes one argument and checks whether it's one of the type
--- supplied to this function.
---
---@param ... string|table:
---@return fun(thing: any|nil): r: boolean: a function that returns true if thing is of one
--- of the string or metatable types provided as arguments to this function
function Type.oneof(...)
  local types = Set.of(...)

  return function(thing)
    return types:contains(Type.of(thing)) or types:contains(mt(thing))
  end
end

--- Checks if the provided "thing" is a function.
---
---@param thing any|nil: the thing to check
---@return boolean: true if thing is a function, false otherwise
function Type.isfunc(thing)
  return Type.is(thing, 'function')
end

return Type

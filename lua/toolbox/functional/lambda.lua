local Common = require 'toolbox.core.__common'

--- Contains function constants and utilities for constructing small functions that are
--- commonly passed as data.
---
---@class Lambda
local Lambda = {}

---@note: a function that does nothing and returns no value (nil)
Lambda.NOOP = function() end
---@note: a function that returns true
Lambda.TRUE = function()
  return true
end
---@note: a function that returns false
Lambda.FALSE = function()
  return false
end
---@note: a function that returns whether a value is nil
Lambda.NIL = function(val)
  return val == nil
end
---@note: a function that returns its first argument
Lambda.IDENTITY = function(val)
  return val
end
---@note: a function that negates the provided function
Lambda.NOT = function(func)
  return function(...)
    return not func(...)
  end
end
---@note: a function that returns whether l == r
Lambda.EQUALS = function(l, r)
  return l == r
end
---@note: a function that returns whether l == r
Lambda.EQUALS_THIS = function(this)
  return function(that)
    return this == that
  end
end
---@note: a function that returns the negative of a number
Lambda.NEGATIVE = function(num)
  return -num
end

--- Function that creates a single function by iteratively passing the output of functions
--- as input to the next.
---
---@param fns function[]:
---@return function
function Lambda.combine(fns)
  if #fns == 0 then
    return Lambda.NOOP
  end

  local final = fns[1]
  fns = Common.Array.slice(fns, 2)

  for _, fn in ipairs(fns) do
    final = function()
      return fn(final())
    end
  end

  return final
end

return Lambda

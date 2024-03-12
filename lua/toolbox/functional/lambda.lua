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
Lambda.ADD = function(l, r)
  return l + r
end
Lambda.SUB = function(l, r)
  return l - r
end

--- Creates a single function in which the provided functions are iteratively called w/
--- the args passed to the outer function.
---
---@param ... function: functions to combine
---@return function: a single function in which the provided functions are iteratively
--- called w/ the args passed to the outer function; returns Lambda.NOOP if no functions
--- are provided
function Lambda.combine(...)
  local fns = Common.Table.pack(...)

  if Common.Table.nil_or_empty(fns) then
    return Lambda.NOOP
  end

  return function(...)
    for _, fn in ipairs(fns) do
      fn(...)
    end
  end
end

--- Returns a function that calls fn w/ the provided arguments.
---
---@param fn function: the function to call
---@param ... any: arguments w/ which to call fn
---@return function: a function that calls fn w/ the provided arguments
function Lambda.make(fn, ...)
  local args = Common.Table.pack(...)

  return function()
    fn(Common.Table.unpack(args))
  end
end

--- Returns a functional version of an object method.
---
---@generic O, R
---@param fn fun(O, ...): R the method
---@param obj R: the object w/ which to call the method (i.e.: self)
---@return fun(...): R a functional version of an object method
function Lambda.method(fn, obj)
  return function(...)
    return fn(obj, ...)
  end
end

return Lambda

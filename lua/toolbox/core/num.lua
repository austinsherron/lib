local Args = require 'toolbox.utils.args'
local Common = require 'toolbox.core.__common'

--- Contains utilities for interacting w/ and manipulating numerical values, measurements,
--- and limits
---
---@class Num
local Num = {}

--- Checks if x is a number.
---
---@param x any|nil: the value to check
---@return boolean: true if x is a number, false otherwise
function Num.is(x)
  return type(x) == 'number'
end

--- Checks if x is an integer.
---
---@param x any|nil: the value to check
---@return boolean: true if x is an integer, false otherwise
function Num.isint(x)
  return Num.is(x) and x % 1 == 0
end

--- Checks if str is a string representation of a number.
---
---@param str string: the string to check
---@return boolean: true if str is a string representation of a number, false otherwise
function Num.isstrnum(str)
  return Num.as(str) ~= nil
end

--- Checks if str is a string representation of an int.
---
---@param str string: the string to check
---@return boolean: true if str is a string representation of an int, false otherwise
function Num.isstrint(str)
  return Num.isint(Num.as(str))
end

--- Returns a numeric representation of num, if possible.
---
---@param o any: an object to convert to a number, if possible.
---@return number|nil: a numeric representation of num, or nil if o can't be converted to
--- a number
function Num.as(o)
  return tonumber(o)
end

--- Returns the absolute value of num.
---
---@see math.abs
---@param num number: the number for which to return an absolute value
---@return number: the absolute value of num
function Num.abs(num)
  return math.abs(num)
end

--- Returns the first integer smaller than num.
---
---@see math.floor
---@param num number: the number to "round down"
---@return integer: the first integer smaller than num
function Num.floor(num)
  return math.floor(num)
end

--- Returns the largest of the provided values.
---
---@param ... number|number[]: vararg or array of numbers of which to find the max
---@return number: the largest of the provided values
function Num.max(...)
  local vals = Args.vararg_to_arr(...)
  local max = nil

  for _, val in ipairs(vals) do
    if max == nil or max < val then
      max = val
    end
  end

  return max
end

--- Returns the smallest of the provided values.
---
---@param ... number|number[]: vararg or array of numbers of which to find the min
---@return number: the smallest of the provided values
function Num.min(...)
  local vals = Args.vararg_to_arr(...)
  local min = nil

  for _, val in ipairs(vals) do
    if min == nil or min > val then
      min = val
    end
  end

  return min
end

--- Checks if n is bounded by l and u, i.e. if: l < n < u. "li" and "ui" control the
--- inclusivity of the test at either bound.
---
---@param n number: the number to check
---@param l number: the lower bound
---@param u number: the upper bound
---@param li boolean|nil: optional, defaults to true; if true the lower bound is
--- inclusive, i.e.: the result is true if n == l
---@param ui boolean|nil: optional, defaults to true; if true the upper bound is
--- inclusive, i.e.: the result is true if n == u
---@return boolean: true if n is numerically "between" l and u, where "between" is
--- optionally inclusive on the lower bound if li == true, and optionally inclusive on the
--- upper bound if ui == true
function Num.bounded(n, l, u, li, ui)
  if l > u then
    error(Common.String.fmt('Num.bounded: l=%s cannot be > u=%s', l, u))
  end

  li = Common.Bool.or_default(li, true)
  ui = Common.Bool.or_default(ui, false)

  local in_l = Common.Bool.ternary(li, function()
    return n >= l
  end, function()
    return n > l
  end)

  local in_u = Common.Bool.ternary(ui, function()
    return n <= u
  end, function()
    return n < u
  end)

  return in_l and in_u
end

--- "Inclusive" bounded.
---
---@see Num.bounded
function Num.ibounded(n, l, u)
  return Num.bounded(n, l, u, true, true)
end

--- "Exclusive" bounded.
---
---@see Num.bounded
function Num.ebounded(n, l, u)
  return Num.bounded(n, l, u, false, false)
end

---@see Common.Num.bounds
function Num.bounds(...)
  return Common.Num.bounds(...)
end

return Num

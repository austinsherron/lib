local Bool = require 'toolbox.core.bool'


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
---@return
function Num.bounded(n, l, u, li, ui)
  li = Bool.or_default(li, true)
  ui = Bool.or_default(ii, false)

  in_l = Bool.ternary(
    li,
    function() return n >= l end,
    function() return n > l end
  )

  in_u = Bool.ternary(
    ui,
    function() return n >= u end,
    function() return n > u end
  )

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


--- Returns the provided number n if it is min < n < max, otherwise, returns min if n < min
--- or max if n > max.
---
---@param n number: the number to bound
---@param min number: the minimum number that this function will return; must be < max
---@param max number: the maximum number that this function will return; must be > min
---@return number: n if min < n < max, otherwise min if n < min or max if n > max
---@error if min > max
function Num.bounds(n, min, max)
  if min > max then
    error(string.format('Num.bounds: min (%s) must be <= max (%s)', min, max))
  end

  if n < min then
    return min
  end

  if n > max then
    return max
  end

  return n
end

return Num


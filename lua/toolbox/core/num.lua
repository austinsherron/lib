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

  local in_l = Common.Bool.ternary(
    li,
    function() return n >= l end,
    function() return n > l end
  )

  local in_u = Common.Bool.ternary(
    ui,
    function() return n <= u end,
    function() return n < u end
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


---@see Common.Num.bounds
function Num.bounds(...)
  return Common.Num.bounds(...)
end

return Num


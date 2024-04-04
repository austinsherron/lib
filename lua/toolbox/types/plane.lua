local Class = require('toolbox.meta.class').Class

local fmt = require('toolbox.core.string').fmt

local Plane = {}

--- Defines a two-dimensional plane.
---
---@class Dimensions
---@field x integer: upper bound of x dimension
---@field y integer: upper bound of y dimension
Plane.Dimensions = Class(function(x, y)
  return { x = x, y = y }
end)

---@return string: a string representation of the instance
function Plane.Dimensions:__tostring()
  return fmt('%sx%s', self.x, self.y)
end

return Plane

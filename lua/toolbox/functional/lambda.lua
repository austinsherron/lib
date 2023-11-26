
--- Contains function constants and utilities for constructing small functions that are
--- commonly passed as data.
---
---@class Lambda
local Lambda = {}

---@note: a function that does nothing and returns no value (nil)
Lambda.NOOP = function() end
---@note: a function that returns true
Lambda.TRUE = function() return true end
---@note: a function that returns false
Lambda.FALSE = function() return false end
---@note: a function that returns its first argument
Lambda.IDENTITY = function(val) return val end
---@note: a function that returns whether l == r
Lambda.EQUALS = function(l, r) return l == r end

return Lambda


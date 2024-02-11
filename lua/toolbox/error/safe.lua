local OnErr = require 'toolbox.error.onerr'

---@alias ErrorHandlerOpts { prefix: string|nil }

--- Provides methods for "safely" performing various actions. In this context, "safely"
--- means "w/ error handling".
---
---@class Safe
local Safe = {}

--- Basically pcall w/ mandatory error handling.
---
---@see OnErr
---
---@generic T
---@param fn fun(...): T|nil: the function to call
---@param opts ErrorHandlerOpts|nil: optional, defaults to { handler = 'notify' }; handler
--- specifies how to handle errors; prefix is an optional prefix for error messages
---@param ... any: args to pass to to_call
---@return T|nil: the return value of to_call
function Safe.call(fn, opts, ...)
  opts = opts or {}

  return OnErr.log(fn, opts.prefix, ...)
end

--- "Safe-ify" a function. Basically a wrapper around Safe.call that returns a callable
--- instead of calling directly.
---
---@see Safe.call
---
---@generic T
---@param fn fun(...): T|nil
---@param opts ErrorHandlerOpts|nil
---@return fun(...): T|nil
function Safe.ify(fn, opts)
  return function(...)
    return Safe.call(fn, opts, ...)
  end
end

--- Standard lua require wrapped w/ mandatory error handling.
---
---@see OnErr
---
---@param module string: import string that references a lua module to require (import)
---@param and_then (fun(m: any|nil): r: any|nil)|nil: optional function to call on the
--- result of the require
---@param opts ErrorHandlerOpts|nil: optional, defaults to { handler = 'notify' }; handler
--- specifies how to handle errors; prefix is an optional prefix for error messages
---@return any?: the value returned by the required module, or nil if there's an error
function Safe.require(module, and_then, opts)
  local to_call = function()
    return require(module)
  end

  local m = Safe.call(to_call, opts)

  if not and_then then
    return m
  end

  return Safe.call(function()
    return and_then(m)
  end, opts)
end

return Safe

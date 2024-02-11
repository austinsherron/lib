local Error = require 'toolbox.error.error'

local ternary = require('toolbox.core.bool').ternary

--- Contains utility methods that wrap function calls and perform specific actions when
--- those calls raise errors.
---
---@class OnErr
local OnErr = {}

local function make_err_msg(err_res, prefix)
  err_res = err_res or ''

  prefix = ternary(prefix == nil, '', function()
    return prefix .. ': '
  end)
  return prefix .. err_res
end

---@return AppLogger
local function get_logger()
  if GetLogger ~= nil then
    return GetLogger()
  end

  error 'OnErr.log: no log provider in scope (GetLogger == nil)'
end

--- On error, logs the error message.
---
---@param f function: the function that might throw an error
---@param prefix string?: optional prefix for error msg
---@param ... any?: args to pass to f
function OnErr.log(f, prefix, ...)
  local ok, res = xpcall(f, debug.traceback, ...)

  if ok then
    return res
  end

  local err_msg = make_err_msg(res, prefix)
  get_logger():error(err_msg, {}, { user_facing = false })
end

--- On error, returns false.
---
---@param f fun(): any|nil: the function that might throw an error
---@param ... any|nil: args to pass to f
---@return boolean: true if the function completes w/out error, false otherwise
---@return any|nil: the result of f, if any
function OnErr.as_bool(f, ...)
  return pcall(f, ...)
end

--- On error, returns a substitute value.
---
---@generic T
---@param f fun(...): T|nil: the function that might throw an error
---@param sub Callable: the value to substitute on error
---@param ... any|nil: args to pass to f
---@return T: the return value of f, or the return value of sub, if f encounters errors
---@return string|nil: the response from any errors encountered calling f, if any
function OnErr.substitute(f, sub, ...)
  local ok, res = pcall(f, ...)

  if ok then
    return res
  end

  return sub(), res
end

--- On error, returns the error's message.
---
---@param f fun(...): any|nil: the function that might throw an error
---@param ... any|nil: args to pass to f
---@return ErrorMessage|nil: a parsed error message, if there was an error, nil otherwise
function OnErr.getmsg(f, ...)
  local ok, res = pcall(f, ...)

  if not ok then
    ---@diagnostic disable-next-line: param-type-mismatch
    return Error.parse(res)
  end
end

return OnErr

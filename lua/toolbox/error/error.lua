local Array = require 'toolbox.core.array'
local Stream = require 'toolbox.extensions.stream'
local String = require 'toolbox.core.string'
local Table = require 'toolbox.core.table'

local Class = require('toolbox.meta.class').Class

--- Convenience class that wraps basic errors.
---
---@class Error
local Error = {}

--- Models an error message.
---
---@class ErrorMessage
---@field msg string: an error message
---@field code string|nil: an error code
---
---@field getmsg fun(): string|nil getter for msg
---@field getcode fun(): string|nil getter for code

--- Constructor
---
---@param msg string|nil: see class docs
---@param code string|nil: see class docs
---@return ErrorMessage: a new instance
local ErrorMessage = Class(function(msg, code)
  return { msg = msg, code = code }
end)

---@return boolean: true if the message has neither a msg nor code, false otherwise
function ErrorMessage:empty()
  return self.msg == nil and self.code == nil
end

---@return string: a string representation of this instance
function ErrorMessage:__tostring()
  return String.fmt('msg=%s, code=%s', self.msg or '?', self.code or '?')
end

---@note: so ErrorMessage is publicly exposed
Error.ErrorMessage = ErrorMessage

local function make_msg(base_msg, ...)
  local args = Stream.new(Table.pack(...)):map(String.tostring):collect()
  return string.format(base_msg, Table.unpack(args))
end

--- Constructs an error msg by stringifying args, formatting them into base_msg, and
--- using it to raise an error.
---
---@param base_msg string: the base msg w/ which to raise an error
---@param ... any|nil: values to stringify and format into base_msg
---@error an error w/ a message formatted from the provided string and tokens
function Error.raise(base_msg, ...)
  error(make_msg(base_msg, ...))
end

--- Same as Error.raise, but also logs an error w/ the provided logger.
---
---@see Error.raise
---@param logger AbstractLogger: used to log an error
---@param base_msg string: the base msg w/ which to raise an error
---@param ... any|nil: values to stringify and format into base_msg
---@error an error w/ a message formatted from the provided string and tokens
function Error.log_and_raise(logger, base_msg, ...)
  local msg = make_msg(base_msg, ...)

  logger:error(msg)
  error(msg)
end

local function trim(str)
  return String.trim(str)
end

--- Parses the error msg and returns its parts.
---
---@param msg string|nil: the error message to parse
---@return ErrorMessage: the error message to parse
function Error.parse(msg)
  local parts = Stream.new(String.split(msg or '', ':', 1)):map(trim):collect()

  if Array.len(parts) == 2 then
    return ErrorMessage(parts[2], parts[1])
  elseif Array.len(parts) == 1 then
    return ErrorMessage(parts[1])
  else
    return ErrorMessage()
  end
end

return Error

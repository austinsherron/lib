local Bool = require 'lib.lua.core.bool'


--- Class used so we can attach methods to LogLevel enum entries.
--
---@class LogLevel
---@field level integer: the numeric level that corresponds to a LogLevel entry
---@field label string: the label of the LogLevel entry
local LogLevel = {}
LogLevel.__index = LogLevel

--- Constructor
--
---@param level integer: the numeric level that corresponds to a LogLevel entry
---@param label string: the label of the LogLevel entry
---@return LogLevel a new LogLevel instance
function LogLevel.new(level, label)
  local this = { level = level, label = label }
  setmetatable(this, LogLevel)
  return this
end


--- Checks if the provided log level is equal to this log level.
--
---@param o LogLevel: the other log level
---@return boolean: true if the provided log level is equal to this log level, false otherwise
function LogLevel:__eq(o)
  return self.level == o.level
end


--- Checks if this log level is < the provided log level.
--
---@param o LogLevel: the other log level
---@return boolean: true if this log level is < the provided log level, false otherwise
function LogLevel:__lt(o)
  return self.level < o.level
end


--- Checks if this log level is <= the provided log level.
--
---@param o LogLevel: the other log level
---@return boolean: true if this log level is <= the provided log level, false otherwise
function LogLevel:__le(o)
  return self.level <= o.level
end


--- Checks if a message should be logged based on the provided log level.
--
---@param level LogLevel: the log level to compare against
---@return boolean: true if a message should be logged based on comparing this log level
-- and the level provided, false otherwise
function LogLevel:should_log(level)
  return self >= level
end


--- Constructs and returns a string representation of the log level.
--
---@return string: a string representation of the log level
function LogLevel:tostring()
  return self.label
end

--- Specifies what kind of message is being logged, and its level of importance/visibility/urgency.
--
---@enum LogLevels
local LogLevels = {
  TRACE = LogLevel.new(0, 'TRACE'),
  DEBUG = LogLevel.new(1, 'DEBUG'),
  INFO  = LogLevel.new(2, 'INFO'),
  WARN  = LogLevel.new(3, 'WARN'),
  ERROR = LogLevel.new(4, 'ERROR'),
  OFF   = LogLevel.new(5, 'OFF'),
}

---@return LogLevel: the default LogLevel
function LogLevels.default()
  return LogLevels.WARN
end


--- Returns the provided log level if present, or default if nil.
--
---@param maybe_level LogLevel?: the level to return if not nil
---@return LogLevel: the provided log level if present, or default if nil
function LogLevels.or_default(maybe_level)
---@diagnostic disable-next-line: return-type-mismatch
  return Bool.ternary(maybe_level ~= nil, maybe_level, LogLevels.default())
end

return LogLevels


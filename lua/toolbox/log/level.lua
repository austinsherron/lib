local TermColor = require 'toolbox.system.color'
local Utils = require 'toolbox.log.utils'

local fmt = Utils.fmt
local isint = Utils.isint
local upper = Utils.upper

--- Class used so we can attach methods to LogLevel enum entries.
---
---@class LogLevel
---@field level integer: the numeric level that corresponds to a LogLevel entry
---@field label string: the label of the LogLevel entry
---@field color TermColor: the LogLevel entry's color in output files
local LogLevel = {}
LogLevel.__index = LogLevel

--- Constructor
---
---@param level integer: the numeric level that corresponds to a LogLevel entry
---@param label string: the label of the LogLevel entry
---@param color TermColor|nil: optional, defaults to normal; the LogLevel entry's color in
--- output files
---@return LogLevel a new LogLevel instance
function LogLevel.new(level, label, color)
  return setmetatable({
    level = level,
    label = label,
    color = color or TermColor.NORMAL,
  }, LogLevel)
end

local function compare_maybe_level(l, o, compare)
  if isint(o) then
    return compare(l.level, o)
  end

  if getmetatable(o) == LogLevel then
    return compare(l.level, o.level)
  end

  return nil
end

--- Checks if the provided object is equal to this log level.
---
---@param o any|nil: the other object
---@return boolean: true if the provided object is equal to this log level, false
--- otherwise
function LogLevel:__eq(o)
  return compare_maybe_level(self, o, function(l, r)
    return l == r
  end) or false
end

--- Checks if this log level is < the provided level.
---
---@param o LogLevel: the other object
---@return boolean: true if this log level is < the provided object, false otherwise
function LogLevel:__lt(o)
  local lt = compare_maybe_level(self, o, function(l, r)
    return l < r
  end)

  if lt ~= nil then
    return lt
  end

  ---@diagnostic disable-next-line: missing-return
  error(fmt('LogLevel.__lt: unable to compare o="%s" of type="%s" to LogLevel', o, type(o)))
end

--- Checks if this log level is <= the provided log level.
---
---@param o LogLevel: the other log level
---@return boolean: true if this log level is <= the provided log level, false otherwise
function LogLevel:__le(o)
  local lt = compare_maybe_level(self, o, function(l, r)
    return l <= r
  end)

  if lt ~= nil then
    return lt
  end

  ---@diagnostic disable-next-line: missing-return
  error(fmt('LogLevel.__le: unable to compare o="%s" of type="%s" to LogLevel', o, type(o)))
end

--- Checks if a message should be logged based on the provided log level.
---
---@param level LogLevel: the log level to compare against
---@return boolean: true if a message should be logged based on comparing this log level
-- and the level provided, false otherwise
function LogLevel:should_log(level)
  return self >= level
end

--- Constructs and returns a string representation of the log level.
---
---@return string: a string representation of the log level
function LogLevel:__tostring()
  -- TODO: finish impl for adding color to logs
  -- return self.color:wrap(self.label)
  return self.label
end

--- Specifies what kind of message is being logged, and its level of importance/visibility/urgency.
---
---@enum LogLevels
local LogLevels = {
  NIL = LogLevel.new(-1, ''),
  TRACE = LogLevel.new(0, 'TRACE', TermColor.MAGENTA),
  DEBUG = LogLevel.new(1, 'DEBUG', TermColor.GREEN),
  INFO = LogLevel.new(2, 'INFO', TermColor.BLUE),
  WARN = LogLevel.new(3, 'WARN', TermColor.YELLOW),
  ERROR = LogLevel.new(4, 'ERROR', TermColor.RED),
  OFF = LogLevel.new(5, 'OFF'),
}

local function map_num_to_levels()
  local out = {}

  for _, ll in pairs(LogLevels) do
    out[ll.level] = ll
  end

  return out
end

local NUM_TO_LEVEL = map_num_to_levels()

--- Converts to a LogLevel any valid representation of a log level.
---
---@param ll string|integer|LogLevel: the log level representation
---@param strict boolean|nil: optional, defaults to true; if true, the function will raise
--- an error if ll doesn't map to a log level
---@return LogLevel: the LogLevel that corresponds to ll, or nil if ll doesn't correspond
--- to a LogLevel and strict is false
---@error if ll doesn't correspond to a log level and strict is true
function LogLevels.as(ll, strict)
  strict = strict == nil and true or strict

  if isint(ll) then
    return NUM_TO_LEVEL[ll]
  elseif type(ll) == 'string' then
    return LogLevels[upper(ll)]
  elseif getmetatable(ll) == LogLevel then
    return ll --[[@as LogLevel]]
  end

  ---@diagnostic disable-next-line: missing-return
  error(fmt('LogLevels.as: invalid repr of log level; ll="%s", type(ll)="%s"', ll, type(ll)))
end

--- Checks if the provided object is nil or the LogLevel equivalent of nil.
---
---@param o any|nil: the object to check
---@return boolean: true if o is nil or LogLevel.NIL otherwise, false
function LogLevels.isnil(o)
  if o == nil then
    return true
  end

  local ll = LogLevels.as(o, false)
  return ll ~= nil and ll == LogLevels.NIL
end

--- Checks if the provided object maps to a log level.
---
---@param o any|nil: the object that might map to a log level
---@return boolean: true if o maps to a log level, false otherwise
function LogLevels.is_valid(o)
  return LogLevels.as(o, false) ~= nil
end

---@return LogLevel: the default LogLevel
function LogLevels.default()
  return LogLevels.WARN
end

--- Returns the provided log level if present, or default if nil.
---
---@param o any|nil: the object that might be a log level
---@return LogLevel: the provided log level if present, or default if nil
function LogLevels.or_default(o)
  return LogLevels.is_valid(o) and LogLevels.as(o) or LogLevels.default()
end

return LogLevels

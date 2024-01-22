local File = require 'toolbox.system.file'
local Formatter = require 'toolbox.log.formatter'
local LogLevel = require 'toolbox.log.level'
local Utils = require 'toolbox.log.utils'

-- local Introspect = require 'toolbox.meta.introspect'

local fmt = Utils.fmt

---@alias LogOpts { sep: string|nil, endln: string|nil }
--TODO: class should be strongly typed
---@alias LogMethod fun(class: table, l: any, a: any[]|nil, o: LogOpts|nil)

--- A logger that writes messages to arbitrary log files.
---
---@class Logger
---
---@field trace LogMethod: logs a "trace" level message
---@field debug LogMethod: logs a "debug" level message
---@field info LogMethod: logs an "info" level message
---@field warn LogMethod: logs a "warn" level message
---@field error LogMethod: logs an "error" level message
---
---@field private file file*: the file to which to write logs
---@field private level LogLevel: the current LogLevel (i.e.: only log events whose log level
---@field private type LoggerType: the logger's type (defines log file path)
---@field private label string: a label w/ which to prefix log messages; for enhanced
--- logging granularity; empty string indicates no-value
local Logger = {}
Logger.__index = Logger

--- Constructor
---
---@param type LoggerType: the type of the logger, i.e.: where logs are written, for which
--- component, etc.
---@param level LogLevel|string|integer|nil?: the current LogLevel (i.e.: only log events
--- whose log level exceeds this level)
---@param label string|nil: optional; see field docstring for description
---@return Logger: a new instances of Logger
function Logger.new(type, level, label)
  if type.external then
    error(fmt('Logger: cannot instantiate logger w/ an external type (%s)', type))
  end

  return setmetatable({
    file = File.open(type.log_path, 'a+'),
    level = LogLevel.or_default(level),
    type = type,
    label = label or '',
  }, Logger)
end

--- Creates a "sub-logger" of this logger. Sub-loggers have the same type and file, but a
--- different prefix.
---
---@param label string: optional; see field docstring for description
---@return Logger: a new sub-logger instance
function Logger:sub(label)
  return Logger.new(self.type, self.level, label)
end

---@return string: path to the log file
function Logger:log_path()
  return self.type.log_path
end

---@private
function Logger:log(to_log, level, args, opts)
  if not level:should_log(self.level) then
    return
  end

  to_log = Formatter.format(level, self.label, to_log, args, opts)
  local err = File.append(self.file, to_log)

  if err ~= nil and err ~= '' then
    error(fmt('Error encountered writing log: %s', err))
  end
end

function Logger:__index(k)
  local raw = rawget(self, k)

  if raw ~= nil then
    return raw
  end

  local mt_val = getmetatable(self)[k]

  if mt_val ~= nil then
    return mt_val
  end

  -- TODO: logs don't include the level or a timestamp since my recent refactor (I think);
  --       I suspect the issue is right around here somewhere...
  ---@note: this call will fail if fn_name doesn't refer to a valid log level
  local level = LogLevel.as(k)

  return function(_, to_log, args, opts)
    to_log = to_log or ''
    args = args or {}
    opts = opts or {}

    ---@note: using local function to avoid infinite recursion (i.e.: indexing in __index)
    self:log(to_log, level, args, opts)
  end
end

return Logger

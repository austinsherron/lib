local String    = require 'lib.lua.core.string'
local Formatter = require 'lib.lua.log.formatter'
local LogLevel  = require 'lib.lua.log.level'
local File      = require 'lib.lua.system.fs'


--- A logger that writes messages to arbitrary log files.
--
---@class Logger
---@field file file*: the file to which to write logs
---@field level LogLevel: the current LogLevel (i.e.: only log events whose log level
-- exceeds this level)
local Logger = {}
Logger.__index = Logger

--- Constructor
--
---@param path string: the file path to which to write logs
---@param level LogLevel?: the current LogLevel (i.e.: only log events whose log level
-- exceeds this level)
---@return Logger: a new instances of Logger
function Logger.new(path, level)
  local this = {
    file = File.open(path, 'a+'),
    level = LogLevel.or_default(level),
  }
  return setmetatable(this, Logger)
end


---@private
function Logger:log(msg, level)
  if not level:should_log(self.level) then
    return
  end

  msg = Formatter.format(level, msg)
  local err = File.append(self.file, msg)

  if String.not_nil_or_empty(err) then
    error('Error encountered writing log: ' .. tostring(err))
  end
end


--- Logs a "trace" level message.
--
---@param msg string: the message to log
function Logger:trace(msg)
  self:log(msg, LogLevel.TRACE)
end


--- Logs a "debug" level message.
--
---@param msg string: the message to log
function Logger:debug(msg)
  self:log(msg, LogLevel.DEBUG)
end


--- Logs an "info" level message.
--
---@param msg string: the message to log
function Logger:info(msg)
  self:log(msg, LogLevel.INFO)
end


--- Logs a "warn" level message.
--
---@param msg string: the message to log
function Logger:warn(msg)
  self:log(msg, LogLevel.WARN)
end


--- Logs an "error" level message.
--
---@param msg string: the message to log
function Logger:error(msg)
  self:log(msg, LogLevel.ERROR)
end

return Logger


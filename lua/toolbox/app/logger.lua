local LogLevel = require 'toolbox.log.level'
local Logger = require 'toolbox.log.logger'
local Notify = require 'toolbox.app.notify'
local Table = require 'toolbox.core.table'

---@alias AppLoggerOpts { persistent: boolean?, user_facing: boolean? }

---@type AppLoggerOpts
local DEFAULT_OPTS = { persistent = false, user_facing = false }

--- An app runtime file/notification logger.
---
---@class AppLogger
---@field private logger Logger: file logger
---@field private default_opts AppLoggerOpts: default logger options; can be overridden
---@field notify Notify: notification api
--- via method level options arguments
local AppLogger = {}
AppLogger.__index = AppLogger

local function current_level(config)
  return config:log_level() or LogLevel.default()
end

--- Constructor
---
---@param config AppConfig: an app config instance used to retrieve app specific log
-- level, etc.
---@param logger_type LoggerTypes: the logger's type
---@param default_opts AppLoggerOpts?: default logger options can be overridden
--- via method level options arguments
---@param label string|nil: optional; an optional prefix label for logged messages
---@return AppLogger: a new AppLogger instance
function AppLogger.new(config, logger_type, default_opts, label)
  local logger = Logger.new(logger_type, current_level(config), label)
  local notify = Notify.new(config)

  return setmetatable({
    logger = logger,
    notify = notify,
    default_opts = Table.combine(DEFAULT_OPTS, default_opts or {}),
  }, AppLogger)
end

--- Creates a new sub-logger from this instance using the provided label.
---
---@param label string: a prefix label for logged messages
---@return AppLogger: a new sub-logger instance w/ the provided label
function AppLogger:sub(label)
  return setmetatable({
    logger = self.logger:sub(label),
    default_opts = self.default_opts or {},
  }, AppLogger)
end

---@private
function AppLogger:do_log(method, to_log, args, opts)
  opts = Table.combine_many({ DEFAULT_OPTS, opts or {}, self.default_opts })

  self.logger[method](self.logger, to_log, args, opts)

  if opts.user_facing ~= true then
    return
  end

  opts = Table.combine(opts, self.default_opts)
  _, opts = Table.split_one(opts, 'user_facing')

  Notify[method](to_log, args, opts)
end

--- Logs a "trace" level message during neovim runtime.
---
---@param to_log any: the formattable string or object to log
---@param args any[]?: an array of objects to format into to_log
---@param opts AppLoggerOpts?: options that control logging behavior
function AppLogger:trace(to_log, args, opts)
  self:do_log('trace', to_log, args, opts)
end

--- Logs a "debug" level message during neovim runtime.
---
---@param to_log any: the formattable string or object to log
---@param args any[]?: an array of objects to format into to_log
---@param opts AppLoggerOpts?: options that control logging behavior
function AppLogger:debug(to_log, args, opts)
  self:do_log('debug', to_log, args, opts)
end

--- Logs an "info" level message during neovim runtime.
---
---@param to_log any: the formattable string or object to log
---@param args any[]?: an array of objects to format into to_log
---@param opts AppLoggerOpts?: options that control logging behavior
function AppLogger:info(to_log, args, opts)
  self:do_log('info', to_log, args, opts)
end

--- Logs a "warn" level message during neovim runtime.
---
---@param to_log any: the formattable string or object to log
---@param args any[]?: an array of objects to format into to_log
---@param opts AppLoggerOpts?: options that control logging behavior
function AppLogger:warn(to_log, args, opts)
  self:do_log('warn', to_log, args, opts)
end

--- Logs an "error" level message during neovim runtime.
---
---@param to_log any: the formattable string or object to log
---@param args any[]?: an array of objects to format into to_log
---@param opts AppLoggerOpts?: options that control logging behavior
function AppLogger:error(to_log, args, opts)
  self:do_log('error', to_log, args, opts)
end

---@return string: the path to the log file
function AppLogger:log_path()
  return self.logger:log_path()
end

return AppLogger

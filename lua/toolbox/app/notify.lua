local Introspect = require 'toolbox.meta.introspect'
local LogFormatter = require 'toolbox.log.formatter'
local String = require 'toolbox.core.string'
local Table = require 'toolbox.core.table'

local ternary = require('toolbox.core.bool').ternary

local fmt = String.fmt

--- Specifies what kind of message is being logged, and its level of
--- importance/visibility/urgency.
---
---@enum Urgency
local Urgency = {
  TRACE = vim.log.levels.TRACE,
  DEBUG = vim.log.levels.DEBUG,
  INFO = vim.log.levels.INFO,
  WARN = vim.log.levels.WARN,
  ERROR = vim.log.levels.ERROR,
}

---@alias NotifyFn fun(to_log: any, args: any[]|nil, opts: table|nil)

--- A basic wrapper around calls to the vim notify api.
---
---@class Notify
---@field private config AppConfig
---@field trace NotifyFn: sends a trace level notification
---@field debug NotifyFn: sends a debug level notification
---@field info NotifyFn: sends an info level notification
---@field warn NotifyFn: sends a warn level notification
---@field error NotifyFn: sends an error level notification
local Notify = {}
Notify.__index = Notify

--- Constructor
---
---@param config AppConfig: an app config instance used to retrieve app specific notify
--level, app title, etc.
---@return Notify: a new instance
function Notify.new(config)
  return setmetatable({ config = config }, Notify)
end

---@private
function Notify:current_level()
  local urgency = self.config:notify_level()
  return Urgency[urgency] or Urgency.WARN
end

---@private
function Notify:should_notify(level)
  return level >= self:current_level()
end

---@private
function Notify:do_log(level, to_log, args, opts)
  if not self:should_notify(level) then
    return
  end

  args = args or {}
  opts = opts or {}
  to_log = LogFormatter.notify_format(to_log, args, opts)

  -- persistent == true means timeout == false, i.e.: no timeout
  local persistent, rest = Table.split_one(opts, 'persistent')
  rest.timeout = ternary(persistent == true, false, rest.timeout)

  vim.notify(to_log, level, rest)
end

--- Custom index metamethod that returns a notify function. The returned function sends a
--- notification via the vim.notify api using the urgency that matches the method name
--- used.
---
---@param k string: a method name that should map to an Urgency entry; determines a
--- notification's urgency
---@return NotifyFn|any: a function that sends a notification via the vim.notify api;
--- params:
---  to_log any: the formattable string or object to log
---  args any[]|nil: an array of objects to format into to_log
---  opts table|nil: options that control logging behavior
function Notify:__index(k)
  local has, val = Introspect.in_metatable(self, k)

  if has then
    return val
  end

  local urgency = Urgency[String.upper(k)]

  if urgency == nil then
    error(fmt('Notify: unrecognized method=%s', k))
  end

  return function(to_log, args, opts)
    self:do_log(urgency, to_log, args, opts)
  end
end

return Notify

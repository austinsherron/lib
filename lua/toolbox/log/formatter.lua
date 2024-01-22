local Datetime = require 'toolbox.utils.datetime'
local LogLevel = require 'toolbox.log.level'
local Utils = require 'toolbox.log.utils'

local concat = Utils.concat
local fmt = Utils.fmt
local join = Utils.join
local nil_or_empty = Utils.nil_or_empty
local replace = Utils.replace
local stringify = Utils.tostring
local unpack = Utils.unpack

-- TODO: commented code is an attempt to get a reasonable approximation of the relevant
--       call site into the logs
--
-- local Path = require 'toolbox.system.path'
--
--
-- local function format_caller(depth)
--   depth = depth or 6
--
--   local info = debug.getinfo(depth)
--   if info == nil then return '' end
--
--   local name = info.name
--   local src = info.short_src
--   local line = info.currentline
--
--   if name == nil or src == nil or line == nil then
--     return ''
--   end
--
--   local file = Path.basename(src)
--   return string.format('(%s [%s: %d])', name, file, line)
-- end

--- Contains utilities for formatting lines for log files.
---
---@class LogFormatter
local LogFormatter = {}

local function stringify_args(args)
  local strings = {}

  for _, arg in ipairs(args) do
    concat(strings, stringify(arg))
  end

  return strings
end

local function get_level_string(level)
  if LogLevel.isnil(level) then
    return nil
  end

  return fmt('[%s] ', level)
end

local function get_label_string(label)
  if nil_or_empty(label) then
    return ''
  end

  return fmt('[%s] ', label)
end

local function get_msg_string(to_log, args)
  to_log = stringify(to_log)
  args = stringify_args(args)

  local ok, out = pcall(fmt, to_log, unpack(args))
  out = ok and out or replace(out, '%%s', '?')

  return out
end

-- local function get_caller_string()
--   local ok, caller = pcall(format_caller)
--   vim.notify(fmt('ok...? %s -> caller=%s', ok and 'yes' or 'no', caller))
-- end

local function get_date_string(opts)
  if opts.with_date ~= nil and not opts.with_date then
    return ''
  end

  return fmt(' [%s]', Datetime.now())
end

local function make_log_line(level, label, to_log, args, opts)
  local parts = {
    get_level_string(level),
    get_label_string(label),
    get_msg_string(to_log, args),
    get_date_string(opts),
  }

  return join(parts, '') .. (opts.endln or '\n')
end

--- Entry point for formatting lines for log files.
---
---@param level LogLevel: the log level to use, if any
---@param label string|nil: optional; the logger's label
---@param to_log any: a formattable log string, or an object to log
---@param args any[]|nil: objects to format into to_log
---@param opts table|nil: options that parameterize logging
---@return string: a formatted log string
function LogFormatter.format(level, label, to_log, args, opts)
  args = args or {}
  opts = opts or {}

  return make_log_line(level, label, to_log, args, opts)
end

--- Entry point for formatting lines for notifications.
---
---@param to_log any: a formattable log string, or an object to log
---@param args any[]|nil: objects to format into to_log
---@param opts table|nil: options that parameterize logging
---@return string: a formatted log string
function LogFormatter.notify_format(to_log, args, opts)
  args = args or {}
  opts = opts or {}

  opts.with_date = false
  return make_log_line(LogLevel.NIL, nil, to_log, args, opts)
end

return LogFormatter

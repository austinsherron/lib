local Env = require 'toolbox.system.env'
local Path = require 'toolbox.system.path'
local Shell = require 'toolbox.system.shell'

local fmt = require('toolbox.log.utils').fmt

local BASE_LOG_FILE_PATH = '%s/%s.log'
local DEFAULT_LOG_FILE = 'default'

local function getpath(path_type, default)
  if vim ~= nil then
    return vim.fn.stdpath(path_type)
  end

  local std_path = Path[path_type]()

  if std_path ~= nil then
    return std_path
  end

  return default
end

--- TODO: refactor code so that this can be shared w/ nvim.lua.utils.api.vim.path
--- TODO: figure out how to pass env vars to code paths that require the defaults
--- (i.e.: hammerspoon)

local function cachepath()
  return getpath('cache', Env.home() .. '/.cache')
end

local function logpath()
  return getpath('log', Env.home() .. '/.local/state')
end

--- Parameterizes LoggerType.
---
---@class LoggerTypeOpts
---@field log_path string|nil: optional; the absolute path to the file to which loggers of
--- this type will write messages; see LoggerType.log_path field docs for behavior if nil
---@field external boolean|nil: optional, defaults to false; see LoggerType field doc for
--- description
---@field file_per_prefix boolean|nil: optional, defaults to false; if true, log prefixes
--- map log lines to individual files
---@field default_file string|nil: optional, defaults to "default"; only relevant if
--- file_per_prefix == true; the filename to use for log messages w/out a prefix

--- Class used so we can use proper objects as LoggerType enum entries.
---
---@class LoggerType
---@field i integer: unique sort index
---@field key string: uniquely identifies the logger type
---@field binding string: unique, single char string used for log viewer key binding
---@field log_path string|nil|fun(pfx: string|nil): string the path to the file where
--- loggers of this type write messages, or a function that returns the same; if log_path
--- in the constructor is nil, this will be defaulted to `Path.log()/[key].log`
---@field external boolean: defaults to false; if true, indicates that the logger type
--- refers to an externally defined/implemented logger, and so cannot be used to
--- instantiate an internal logger
---@field opts LoggerTypeOpts|nil: optional; parameterizes logger type
local LoggerType = {}
LoggerType.__index = LoggerType

local function make_log_path(key, opts)
  if opts.file_per_prefix ~= true then
    return fmt(BASE_LOG_FILE_PATH, logpath(), key)
  end

  local dir = logpath() .. '/' .. key
  Shell.mkdir(dir, true)

  return function(pfx)
    local file = string.lower(pfx or (opts.default_file or DEFAULT_LOG_FILE))
    return fmt(BASE_LOG_FILE_PATH, dir, file)
  end
end

--- Constructor
---
---@param i integer: unique sort index
---@param key string: uniquely identifies the logger
---@param binding string: unique, single char string used for log viewer key binding
---@param opts LoggerTypeOpts|nil: optional; parameterizes logger type
---@return LoggerType: a new instance
function LoggerType.new(i, key, binding, opts)
  opts = opts or {}

  local external = opts.external or false
  local log_path = opts.log_path or make_log_path(key, opts)

  return setmetatable({
    i = i,
    key = key,
    binding = binding,
    log_path = log_path,
    external = external,
    opts = opts,
  }, LoggerType)
end

---@param pfx string|nil: optional; a prefix/logger label to use to retrieve the logger
--- path
---@return string: the path to the log file for this type and the provided prefix
function LoggerType:get_log_path(pfx)
  if type(self.log_path) == 'string' then
    return self.log_path --[[@as string]]
  end

  return self.log_path(pfx)
end

---@return string: a string representation of this instance
function LoggerType:__tostring()
  return self.key
end

--- Specifies a "type" of logger. One or more loggers should be of the same type if it
--- makes sense for them to write to the same file.
---
---@note: if multiple logger instances use the same type in different lua processes, no
--- guarantees can be made about the proper order of
---
--- TODO: convert to enum using toolbox.extensions.Enum.
---
---@enum LoggerTypes
local LoggerTypes = {
  -- internal
  NVIM = LoggerType.new(1, 'nvim', 'n', { file_per_prefix = true }),
  HAMMERSPOON = LoggerType.new(2, 'hammerspoon', 'h'),
  XPLR = LoggerType.new(3, 'xplr', 'x'),
  SNIPPET = LoggerType.new(4, 'luasnip', 's'),
  -- external
  LSP = LoggerType.new(5, 'lsp', 'l', { external = true }),
  DIFFVIEW = LoggerType.new(
    6,
    'diffview',
    'd',
    { log_path = cachepath() .. '/diffview.log', external = true }
  ),
}

local function make_types_by_keys()
  local out = {}

  for _, type in pairs(LoggerTypes) do
    out[type.key] = type
  end

  return out
end

LoggerTypes.ALL = make_types_by_keys()
LoggerTypes.DEFAULT = LoggerTypes.NVIM

--- Checks if the provided key maps to a LoggerType.
---
---@param key string|nil: the key to check
---@return boolean: true if key maps to a valid LoggerType, false otherwise
function LoggerTypes.is_valid(key)
  return LoggerTypes.ALL[key] ~= nil
end

--- Gets the LoggerType associated w/ the provided key, if any, or the default if the key
--- is invalid.
---
---@param key string|nil: the key for which to retrieve a logger type
---@return LoggerType: the LoggerType associated w/ the provided key, if any, or the
--- default if the key is invalid
function LoggerTypes.or_default(key)
  return LoggerTypes.is_valid(key) and LoggerTypes.ALL[key] or LoggerTypes.DEFAULT
end

---@return { [string]: LoggerType }: a map of all logger keys to types
function LoggerTypes.all()
  return LoggerTypes.ALL
end

return LoggerTypes

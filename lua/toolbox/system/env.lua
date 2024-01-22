local Callable = require 'toolbox.functional.callable'

local enum = require('toolbox.extensions.enum').enum

--- Enumerates known env vars.
---
---@enum EnvVar
local EnvVar = enum({
  CODE_ROOT = 'CODE_ROOT',
  CONFIG_ROOT_PUB = 'CONFIG_ROOT_PUB',
  DEV_ROOT = 'DEV_ROOT',
  EDITORS_ROOT = 'EDITORS_ROOT',
  EXTERNAL_PKGS = 'EXTERNAL_PKGS',
  HOME = 'HOME',
  LUA_PATH = 'LUA_PATH',
  NVIM_ROOT = 'NVIM_ROOT',
  NVIM_ROOT_PUB = 'NVIM_ROOT_PUB',
  NVIM_SUBMODULE = 'NVIM_SUBMODULE',
  NVUNDLE = 'NVUNDLE',
  PWD = 'PWD',
  TMUX_BUNDLE = 'TMUX_BUNDLE',
})

--- A util for retrieving environment values.
--
---@class Env
---@field [any] any
local Env = {}
Env.__index = {}

--- Constructor
--
---@return Env: a new instance
function Env.new()
  return setmetatable({}, Env)
end

--- A custom __index function that allows callers to retrieve env values using
--- functions named like lowercased versions of the variables being retrieved.
---
---@param envvar string: the lowercased name of the variable whose value is being
--- retrieved
---@return Callable<string|nil>: a function that returns the string env var value that
--- maps to the variable being retrieved, or nil if it doesn't exist
function Env:__index(envvar)
  return Callable.new(os.getenv(envvar:upper()))
end

--- Same as Env.__index, but directly return the value of the provided env var name (if it
--- exists) instead of a function.
---
---@param envvar string: the lowercased name of the variable whose value is being
--- retrieved
---@return string|nil: the string env var value that maps to the variable being retrieved,
--- or nil if it doesn't exist
function Env:get(envvar)
  return self[envvar]()
end

return Env.new()

local Bool = require 'toolbox.core.bool'
local Env = require 'toolbox.system.env'
local String = require 'toolbox.core.string'

--- Reads app configuration values from the environment. App config env vars are prefixed
--- w/ "[APP_PREFIX]_".
---
---@class AppConfig
---@field [any] any
---@field prefix string: an app specific prefix that distinguishes the app's config env
--- vars
local AppConfig = {}
AppConfig.__index = AppConfig

--- Constructor
---
---@return AppConfig: a new instance
function AppConfig.new(prefix)
  return setmetatable({ prefix = String.upper(prefix) }, AppConfig)
end

--- Custom index metamethod that permits the reading of app config env vars via function
--- calls of the following form:
---
---   local SuperDuperConfig = AppConfig.new('super_duper')
---
---  * SUPER_DUPER_LOG_LEVEL="info"    ->   SuperDuperConfig.log_level() == "info"
---  * SUPER_DUPER_EXTRA_DUPER="true"  ->   SuperDuperConfig.extra_duper() == true
---
---@param k string: a lowercased app env var key w/o the upper-case app prefix
---@return fun(): string|boolean|nil: a function that returns the string/boolean
--- representation of the env var at "[APP_PREFIX]_[upper(k)]", or nil if the env var
--- doesn't exist
function AppConfig:__index(k)
  return function()
    k = String.fmt('%s_%s', self.prefix, String.upper(k))
    --- FIXME: Env:get should work here, but it's not... 🙃
    return Bool.convert_if(Env[k]())
  end
end

return AppConfig

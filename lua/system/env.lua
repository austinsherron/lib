
--- A util for retrieving environment values.
--
---@class Env
---@field lua_path fun(): v: string|nil: lua "exec" path
---@field nvim_root fun(): v: string|nil: path to the root of the nvim home dir
---@field nvundle fun(): v: string|nil: path to the root of the nvim packages (plugins) dir
---@field projects_root fun(): v: string|nil: path to the root of the ""
local Env = {}
Env.__index = {}

--- Constructor
--
---@return Env: an instance of Env
function Env.new()
  local this = {}
  setmetatable(this, Env)
  return this
end


--- A custom __index function that allows callers to retrieve env values using
--  functions named like lowercased versions of the variables being retrieved.
--
---@param func string: the lowercase name of the variable whose value is being retrieved
---@return fun(k: string): v: (string?): a function that returns the string env var
-- value that maps to the variable being retrieved, or nil if it doesn't exist
function Env:__index(func)
  return function()
    return os.getenv(func:upper())
  end
end

return Env.new()


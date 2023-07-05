--- A util for retrieving environment values.
--
---@class Env
local Env = {}
Env.__index = {}

function Env.new()
  local this = {}

  setmetatable(this, Env)

  return this
end


--- A custom __index function that allows callers to retrieve env values using
--  functions named like lowercased versions of the variables being retrieved.
--
---@param func string: the lowercase name of the variable whose value is being retrieved
---@return function: a function that returns the string env var value that maps to the
-- variable being retrieved, or nil if it doesn't exist
function Env:__index(func)
    return function()
      return os.getenv(func:upper())
    end
end

return Env.new()


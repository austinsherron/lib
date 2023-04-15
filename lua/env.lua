local Env = {}
Env.__index = {}

function Env.new()
  local this = {}

  setmetatable(this, Env)

  return this
end


function Env:__index(func)
    return function()
      return os.getenv(func:upper())
    end
end


return Env.new()



-- Callable --------------------------------------------------------------------

--- A class whose instances wrap values that are referenced via function calls. For example:
--
--    local callable = Callable.new('not a function')
--    callable() .. 'but it acts like one' == 'not a function but it acts like one'
--
---@generic T
---@class Callable<T>
---@field private val T: the value returned by calling the instance
local Callable = {}
Callable.__index = Callable

--- Constructor
--
---@generic T
---@param val T: value to return when called
---@return Callable: a new Callable instance w/ the provided value
function Callable.new(val)
  return setmetatable({ val = val }, Callable)
end


---@generic T
---@return T: value the callable instance wraps
function Callable:__call()
  return self.val
end


---@see Callable.new
return function(val)
  return Callable.new(val)
end


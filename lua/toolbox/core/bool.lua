
--- Contains utilities for interacting w/ and manipulating boolean values.
--
---@class Bool
local Bool = {}

local function func_or_val(ToF)
  if type(ToF) == 'function' then
    return ToF()
  end

  return ToF
end


--- Function that makes Lua ternary expressions more like those in other languages.
---
--- Note: to return functions, the functions themselves must be wrapped in functions.
---
---@generic TType, FType
---@param cond boolean: the condition to evaluate
---@param T TType|fun(...): t: TType: value if cond == true
---@param F (FType|fun(...): t: FType)?: optional, for cases in which false means a nil
-- value; value if cond == false
---@return TType|FType: T if cond evaluates to true, F otherwise
function Bool.ternary(cond, T, F)
  if cond then return func_or_val(T) else return func_or_val(F) end
end


--- Converts to a true boolean a boolean value represented as a string.
--
---@param value string?: the value to convert to a boolean
---@return boolean: true if value == "true", false otherwise
function Bool.as_bool(value)
  return value == 'true'
end


--- Returns bool if bool ~= nil, otherwise returns default.
---
---@param bool boolean|nil: the boolean to return if not nil
---@param default boolean: the value to return if bool is nil
---@return boolean: bool if bool ~= nil, otherwise default
function Bool.or_default(bool, default)
  return Bool.ternary(bool == nil, default, bool)
end

return Bool


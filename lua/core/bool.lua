
local Bool = {}

local function func_or_val(ToF)
  if type(ToF) == 'function' then
    return ToF()
  end

  return ToF
end


--- Function that makes Lua ternary expressions more like those in other languages.
--
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

return Bool



local Bool = {}

--- Function that makes Lua ternary expressions more like those in other languages.
--
---@param cond boolean: the condition to evaluate
---@param T any: value if cond == true
---@param F any: value if cond == false
function Bool.ternary(cond, T, F)
    if cond then return T else return F end
end

return Bool;


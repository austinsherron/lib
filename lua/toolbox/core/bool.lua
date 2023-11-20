local Common = require 'toolbox.core.__common'


--- Contains utilities for interacting w/ and manipulating boolean values.
---
---@class Bool
local Bool = {}

---@see Common.Bool.ternary
function Bool.ternary(...)
  return Common.Bool.ternary(...)
end


--- Converts to a true boolean a boolean value represented as a string.
--
---@param value string?: the value to convert to a boolean
---@return boolean: true if value == "true", false otherwise
function Bool.as_bool(value)
  return value == 'true'
end


---@see Common.Bool.or_default
function Bool.or_default(...)
  return Common.Bool.or_default(...)
end

return Bool


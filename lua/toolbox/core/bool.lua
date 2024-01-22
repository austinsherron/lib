local Common = require 'toolbox.core.__common'

--- Contains utilities for interacting w/ and manipulating boolean values.
---
---@class Bool
local Bool = {}

---@see Common.Bool.ternary
function Bool.ternary(...)
  return Common.Bool.ternary(...)
end

--- Checks if the provided value is a boolean or a string representation of a boolean.
---
---@param value string|boolean|nil: the string/boolean to check
---@return boolean: true if value is a boolean or a string representation of a boolean
function Bool.is_bool(value)
  return value == true or value == false or value == 'true' or value == 'false'
end

--- Converts to a true boolean a boolean value represented as a string.
--
---@param value string|boolean|nil: the value to convert to a boolean
---@return boolean: true if value == "true", false otherwise
function Bool.as_bool(value)
  return tostring(value) == 'true'
end

--- Converts value to a bool if it is a bool according to Bool.is_bool, otherwise the
--- value is returned as is.
---
---@generic T
---@param value string|boolean|T|nil: the value to check
---@return boolean|T|nil: value as a bool if it is a bool according to Bool.is_bool, else
--- value
function Bool.convert_if(value)
  return Bool.ternary(Bool.is_bool(value), Bool.as_bool(value), value)
end

---@see Common.Bool.or_default
function Bool.or_default(...)
  return Common.Bool.or_default(...)
end

return Bool

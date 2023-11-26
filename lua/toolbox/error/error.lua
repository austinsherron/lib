local Table  = require 'toolbox.core.table'
local String = require 'toolbox.core.string'
local Stream = require 'toolbox.extensions.stream'


--- Convenience class that wraps basic errors.
---
---@class Error
local Error = {}

--- Constructs an error msg by stringifying args, formatting them into base_msg, and
--- using it to raise an error.
---
---@param base_msg string: the base msg w/ which to raise an error
---@param ... any|nil: values to stringify and format into base_msg
---@error an error w/ a message formatted from the provided string and tokens
function Error.raise(base_msg, ...)
  local args = Stream(Table.pack(...))
    :map(String.tostring)
    :collect()

  error(string.format(base_msg, Table.unpack(args)))
end

return Error


local String = 'toolbox.core.string'


--- Contains utilities for formatting lines for log files.
--
---@class LogFormatter
local LogFormatter = {}

--- Entry point for formatting lines for log files.
--
---@param level LogLevel: the level of the log line
---@param to_log any: the object or msg to log
---@return string: a formatted log string
function LogFormatter.format(level, to_log)
  -- pad to len == 8: '[' + ']' + ' ' + len max level == 8
  level = String.rpad('[' .. tostring(level) .. ']', ' ', 8)
  to_log = String.tostring(to_log)

  return level .. to_log
end

return LogFormatter


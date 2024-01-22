local stringify = require 'toolbox.common.stringify'

--- Contains utilities used by logger components.
---
---@note: Logger components should have very few external dependencies, as loggers should
--- be able to be used in any and all shared code. For this reason, this class contains
--- logic/functions duplicated in other shared utilities
---
---@class LoggerUtils
local LoggerUtils = {}

LoggerUtils.concat = table.insert
LoggerUtils.fmt = string.format
LoggerUtils.tostring = stringify
LoggerUtils.unpack = unpack or table.unpack
LoggerUtils.upper = string.upper

--- Checks if str is nil or empty.
---
---@param str string|nil: the string to check
---@return boolean: true if str is nil or empty, false otherwise
function LoggerUtils.nil_or_empty(str)
  return str == nil or str == ''
end

--- Checks if tbl is empty.
---
---@param tbl table: the table to check
---@return boolean: true if tbl is empty, false otherwise
function LoggerUtils.tbl_is_empty(tbl)
  for _, _ in ipairs(tbl) do
    return false
  end

  return true
end

--- Checks if tbl is nil or empty.
---
---@param tbl table|nil: the table to check
---@return boolean: true if tbl is nil or empty, false otherwise
function LoggerUtils.nil_or_empty_tbl(tbl)
  return tbl == nil or LoggerUtils.tbl_is_empty(tbl)
end

--- Checks if x is an integer.
---
---@see Num.isint
---@param x any|nil: the value to check
---@return boolean: true if x is an integer, false otherwise
function LoggerUtils.isint(x)
  return type(x) == 'number' and x % 1 == 0
end

--- Replaces all occurrences of to_replace in str w/ replace_with.
---
---@param str string: the string in which to replace occurrences
---@param to_replace string: the substring that will be replaced
---@param replace_with string: the substring w/ which to replace
---@return string: a string in which all occurrences of to_replace in str are replaced w/
--- replace_with
function LoggerUtils.replace(str, to_replace, replace_with)
  return (string.gsub(str, to_replace, replace_with))
end

--- Joins an array of strings w/ sep.
---
---@param strs string[]: the strings to join
---@param sep string|nil: optional, defaults to ','; the char string w/ which to join strs
---@return string: a single string comprised of the elements of strs, joined by sep
function LoggerUtils.join(strs, sep)
  sep = sep or ','

  if #strs == 0 then
    return ''
  end
  if #strs == 1 then
    return strs[1]
  end

  local out = ''

  for i, str in pairs(strs) do
    out = i == 1 and str or (out .. sep .. str)
  end

  return out
end

return LoggerUtils

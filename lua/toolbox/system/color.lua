--- Models a terminal color.
---
---@class TermColor
---@field code string: the color's terminal code
local TermColor = {}
TermColor.__index = TermColor

--- Constructor
---
---@param code string: a terminal color code
---@return TermColor: a new instance
function TermColor.new(code)
  return setmetatable({ code = code }, TermColor)
end

--- Wraps a string in terminal color codes.
---
---@param str string: the string to wrap in color codes
function TermColor:wrap(str)
  return str.format('\\033[%s%s\\033[0m', self.code, str)
end

--- Available terminal colors.
---
---@enum TermColors
local TermColors = {
  NORMAL = TermColor.new '0m',
  RED = TermColor.new '31m',
  YELLOW = TermColor.new '33m',
  GREEN = TermColor.new '32m',
  BLUE = TermColor.new '34m',
  MAGENTA = TermColor.new '35m',
}

return TermColors

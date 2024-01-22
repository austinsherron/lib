local Table = require 'toolbox.core.table'

local ternary = require('toolbox.core.bool').ternary

--- Contains simple utility methods for working w/ language.
---
---@class Grammar
local Grammar = {}

--- Checks if the provided lua object is singular or plural.
---
---@note: this function uses fallible heuristics, so it's very possible that some
--- sentences constructed w/ this utility will sound unnatural or just be plain wrong.
---
---@param object any|nil: the lua object to check
---@return boolean: true if object is plural, false otherwise
function Grammar.is_plural(object)
  return Table.is(object) and #Table.values(object) > 1
end

--- Returns the appropriate conjugation of the verb "to be" based on the number of "items"
---
---@param subject any: the subject for which to conjugate "to be"
---@return string: "is" if the subject is singular, "are" if plural
function Grammar.to_be(subject)
  return ternary(Grammar.is_plural(subject), 'are', 'is')
end

--- Returns "is" or its negative based on the value of the provided boolean.
---
---@param is_or_not boolean: determines the output string
---@return string: "is" if is_or_not == true, otherwise "is not"
function Grammar.is_or_not(is_or_not)
  return ternary(is_or_not, 'is', 'is not')
end

return Grammar

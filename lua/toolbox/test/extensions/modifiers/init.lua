local Modifier = require 'toolbox.test.extensions.modifier'

local ArrayHandler = require 'toolbox.test.extensions.modifiers.array'
local SetHandler = require 'toolbox.test.extensions.modifiers.set'
local StackHandler = require 'toolbox.test.extensions.modifiers.stack'

--- State modifiers for luassert.
---
---@enum Modifiers
local Modifiers = {
  ARRAY = Modifier.new('array', '__array_state', ArrayHandler),
  SET = Modifier.new('set', '__set_state', SetHandler),
  STACK = Modifier.new('stack', '__stack_state', StackHandler),
}

return Modifiers

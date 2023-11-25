local TestUtils = require 'toolbox.test.utils'

local assert = require 'luassert.assert'

local fmt = TestUtils.fmt


--- Defines an assertion modifier for use w/ luassert in lua unit tests.
---
---@class AssertModifier
---@field name string: the name of the modifier
---@field handler table: implements assertion logic for the modifier
---@field private state_key string
---@field private base fun(state: table, args: table, level: integer): state: table
local AssertModifier = {}
AssertModifier.__index = AssertModifier

local function make_base(name, state_key)
  return function(state, args, _)
    assert(args.n > 0, fmt('No %s provided to the %s-modifier', name, name))
    assert(rawget(state, state_key) == nil, name .. ' already set')

    rawset(state, state_key, args[1])
    return state
  end
end


--- Constructor
---
---@param name string: the name of the modifier
---@param state_key string: unique key to store the object we operate on in the state
--- object; key must be unique, to make sure we do not have name collisions in the shared
--- state object
---@param handler table: implements assertion logic for the modifier
function AssertModifier.new(name, state_key, handler)
  return setmetatable({
    base      = make_base(name, state_key),
    handler   = handler,
    name      = name,
    state_key = state_key,
  }, AssertModifier)
end


--- Gets the state associated w/ this assert modifier.
---
---@generic T
---@param state table: overall state object passed into luassert modifiers
---@return T|nil: the state associated w/ this assert modifier
function AssertModifier:get_state(state)
  return rawget(state, self.state_key)
end


--- Registers the modifier w/ luassert.
function AssertModifier:register()
  assert:register('modifier', self.name, self.base)
end

return AssertModifier


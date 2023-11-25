local TestUtils      = require 'toolbox.test.utils'
local Modifiers      = require 'toolbox.test.extensions.modifiers'

local assert = require 'luassert.assert'
local say    = require 'say'

local concat           = TestUtils.concat
local fmt              = TestUtils.fmt
local not_nil_or_empty = TestUtils.not_nil_or_empty
local pack             = TestUtils.pack
local unpack           = TestUtils.unpack


---@alias AssertMsgType 'positive' | 'negative'
---@alias AssertionMsgs { [AssertMsgType]: string|nil }

--- Defines an individual custom assertion attached to an AssertModifier.
---
---@class Assertion
---@field private name string
---@field private msgs AssertionMsgs
---@field private aliases string[]
local Assertion = {}
Assertion.__index = Assertion

--- Constructor
---
---@param name string: the assertion's name
---@param msgs AssertionMsgs|nil: optional; the assertion's error messages
---@param aliases string[]|nil: optional, but must include at east one before registration;
--- the assertions, aliases, if any
---@return Assertion: a new instance
function Assertion.new(name, msgs, aliases)
  return setmetatable({
    name    = name,
    msgs    = msgs or {},
    aliases = aliases or {},
  }, Assertion)
end


--- Adds a "positive" failure message to the assertion.
---
---@param msg string: the message
---@return Assertion: this instance
function Assertion:with_positive(msg)
  self.msgs.positive = msg
  return self
end


--- Adds a "negative" failure message to the assertion.
---
---@param msg string: the message
---@return Assertion: this instance
function Assertion:with_negative(msg)
  self.msgs.negative = msg
  return self
end


--- Adds on or more aliases to the assertion.
---
---@param ... string: the alias(es)
---@return Assertion: this instance
function Assertion:with_alias(...)
  local aliases = pack(...)

  for _, alias in ipairs(aliases) do
    concat(self.aliases, alias)
  end

  return self
end


---@private
function Assertion:msg_fqn(type)
  return fmt('assertion.%s.%s', self.name, type)
end


---@private
function Assertion:register_msgs()
  assert(
    not_nil_or_empty(self.msgs),
    'msgs must contain at least one type of assertion messaage'
  )

  local fqns = {}

  for type, msg in pairs(self.msgs) do
    local fqn = self:msg_fqn(type)
    concat(fqns, fqn)
    say:set(fqn, msg)
  end

  return fqns
end


local function get_mod_state(state)
  for _, mod in pairs(Modifiers) do
    local mod_state = mod:get_state(state)

    if mod_state ~= nil then
      return mod_state, mod
    end
  end
end


---@private
function Assertion:make_assertion()
  return function(state, args, _)
    local mod_state, mod = get_mod_state(state)

    assert(
      mod.handler[self.name] ~= nil,
      fmt("The %s handler doesn't implement the %s assertion", mod.name, self.name)
    )

    return mod.handler[self.name](mod_state, args)
  end
end


---@private
function Assertion:get_names()
  local names = { self.name }

  for _, alias in ipairs(self.aliases) do
    concat(names, alias)
  end

  return names
end


--- Registers the assertion w/ luassert under its name and aliases.
function Assertion:register()
  local fqns = self:register_msgs()
  local names = self:get_names()

  for _, name in ipairs(names) do
    assert:register('assertion', name, self:make_assertion(), unpack(fqns))
  end
end

return Assertion


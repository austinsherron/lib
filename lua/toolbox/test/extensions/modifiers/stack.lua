---@diagnostic disable: invisible, undefined-doc-param

local Stack = require 'toolbox.extensions.stack'
local Utils = require 'toolbox.test.utils'

local assert = require 'luassert.assert'

local fmt          = Utils.fmt
local table_equals = Utils.table_equals
local table_len    = Utils.table_len
local to_set       = Utils.to_set


--- A handler for an assert modifier that enables interactions w/ stacks. For example:
---
---   assert.stack(stack).empty()
---   assert.stack(stack).Not.contains({ 'a', 1, 'z' })
---
---@class StackHandler
local StackHandler = {}

--- A stack assertion that checks that a stack contains all provided elements, and whose
--- negation checks that it's missing at least one of them. For example:
---
---   assert.stack(Stack.new(1, 2, 3)).contains({ 1, 3 })           -- passes
---   assert.stack(Stack.new(1, 2, 3)).contains({ 1, 2, 3, 4 })     -- fails
---   assert.stack(Stack.new(1, 2, 3)).Not.contains({ 4, 8 })       -- passes
---   assert.stack(Stack.new(1, 2, 3)).Not.contains({ 1, 3 })       -- fails
---
--- The assertion will fail fast on the first missing/present element (so it will report
--- failures one at a time).
---
---@param should_contain any[]: contains the elements to that arr should/should not
--- contain
---@param stack Stack: the stack to check (implicit argument passed via assert.stack)
function StackHandler.contains(stack, args)
  local should_contain = args[1]
  assert(#should_contain > 0, fmt('#should_contains must be > 0'))

  local stack_set = to_set(stack.stack)
  local missing = nil

  for _, e in ipairs(should_contain) do
    if stack_set[e] == nil then
      missing = e
      args[1] = e
      break   -- fail fast on first missing value
    end
  end

  args.n = missing and 1 or 0
  return missing == nil, { missing }
end

--- A stack assertion that checks that a stack is empty, and whose negation checks that
--- it isn't. For example:
---
---   assert.stack(Stack.new()).empty()                -- passes
---   assert.stack(Stack.new(1, 2, 3)).empty()         -- fails
---   assert.stack(Stack.new(1, 2, 3)).Not.empty()     -- passes
---   assert.stack(Stack.new()).Not.empty()            -- fails
---
---@param stack Stack: the stack to check (implicit argument passed via assert.stack)
function StackHandler.empty(stack, args)
  local stack_len = table_len(stack.stack)

  args[1] = stack_len
  return stack_len == 0, { stack_len }
end


--- A stack assertion that checks that a stack equals another stack, and whose negation
--- checks that it doesn't. For example:
---
---   assert.stack(Stack.new(1, 2, 3)).equals(Stack.new(1, 3, 2))       -- passes
---   assert.stack(Stack.new(1, 2, 3)).equals(Stack.new(1, 2))          -- fails
---   assert.stack(Stack.new(1, 2, 3)).Not.equals(Stack.new(1, 2))      -- passes
---   assert.stack(Stack.new(1, 2, 3)).Not.equals(Stack.new(1, 3, 2))   -- fails
---
---@param other Stack: the other stack to check for equality
---@param stack Stack: the stack to check (implicit argument passed via assert.stack)
function StackHandler.eq(stack, args)
  local other = args[1]

  assert(getmetatable(other) == Stack, fmt('expected other to be stack: %s', other))

  return table_equals(stack.stack, other.stack), { other }
end


--- A stack assertion that checks that a stack is the same object as another stack, and
--- whose negation checks that it's not. For example:
---
---   local stack_a = Stack.new(1, 2, 3)
---   local stack_b = Stack.new(1, 2, 3)
---
---   assert.stack(stack_a).same(stack_a)         -- passes
---   assert.stack(stack_a).same(stack_b)         -- fails
---   assert.stack(stack_a).Not.same(stack_b)     -- passes
---   assert.stack(stack_a).Not.same(stack_a)     -- fails
---
---@param other Stack: the other stack to check
---@param stack Stack: the stack to check (implicit argument passed via assert.stack)
function StackHandler.is(stack, args)
  local other = args[1]

  return rawequal(stack, other), { other }
end


--- A stack assertion that checks that a stack has a specific length, and whose negation
--- checks that its length is anything other. For example:
---
---   assert.stack(Stack.new(1, 2, 3)).has.length(3)               -- passes
---   assert.stack(Stack.new(1, 2, 3)).has.length(2)               -- fails
---   assert.stack(Stack.new(1, 2, 3)).does_not.have.length(0)     -- passes
---   assert.stack(Stack.new().Not.length(0)                       -- fails
---
---@param asserted_len integer: the asserted length of the stack
---@param stack Stack: the stack to check (implicit argument passed via assert.stack)
function StackHandler.length(stack, args)
  local asserted_len = args[1]
  local stack_len = table_len(stack.stack)

  args[1] = stack_len
  return stack_len == asserted_len, { asserted_len, stack_len }
end

return StackHandler


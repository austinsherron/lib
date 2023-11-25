---@diagnostic disable: undefined-doc-param, invisible

local Set            = require 'toolbox.extensions.set'
local TestUtils      = require 'toolbox.test.utils'

local assert = require 'luassert.assert'

local fmt          = TestUtils.fmt
local table_equals = TestUtils.table_equals
local table_len    = TestUtils.table_len


--- A handler for an assert modifier that enables interactions w/ sets. For example:
---
---   assert.set(set).empty()
---   assert.set(set).Not.contains({ 'a', 1, 'z' })
---
---@class SetHandler
local SetHandler = {}

--- A set assertion that checks that a set contains all provided elements, and whose
--- negation checks that it's missing at least one of them. For example:
---
---   assert.set(Set.new({ 1, 2, 3 })).contains({ 1, 3 })              -- passes
---   assert.set(Set.new({ 1, 2, 3 })).contains({ 1, 2, 3, 4 })        -- fails
---   assert.set(Set.new({ 1, 2, 3 })).Not.contains({ 4, 8 })          -- passes
---   assert.set(Set.new({ 1, 2, 3 })).Not.contains({ 1, 3 })          -- fails
---
--- The assertion will fail fast on the first missing/present element (so it will report
--- failures one at a time).
---
---@param set Set: the set to check (implicit argument passed via assert.set)
---@param should_contain any[]: contains the elements to that arr should/should not
--- contain
function SetHandler.contains(set, args)
  local should_contain = args[1]
  assert(#should_contain > 0, fmt('#should_contains must be > 0'))

  local missing = nil

  for _, e in ipairs(should_contain) do
    if set.items[e] == nil then
      missing = e
      args[1] = e
      break   -- fail fast on first missing value
    end
  end

  args.n = missing and 1 or 0
  return missing == nil, { missing }
end


--- A set assertion that checks that a set is empty, and whose negation checks that
--- it isn't. For example:
---
---   assert.set(Set.new()).empty()                  -- passes
---   assert.set(Set.new({ 1, 2, 3 })).empty()       -- fails
---   assert.set(Set.new({ 1, 2, 3 })).Not.empty()   -- passes
---   assert.set(Set.new({})).Not.empty()            -- fails
---
---@param set Set: the set to check (implicit argument passed via assert.set)
function SetHandler.empty(set, args)
  local set_len = table_len(set.items)

  args[1] = set_len
  return set_len == 0, { set_len }
end


--- A set assertion that checks that a set equals another set, and whose negation checks
--- that it doesn't. For example:
---
---   assert.set(Set.new({ 1, 2, 3 })).equals(Set.new({ 1, 3, 2 }))       -- passes
---   assert.set(Set.new({ 1, 2, 3 })).equals(Set.new({ 1, 2 }))          -- fails
---   assert.set(Set.new({ 1, 2, 3 })).Not.equals(Set.new({ 1, 2 }))      -- passes
---   assert.set(Set.new({ 1, 2, 3 })).Not.equals(Set.new({ 1, 3, 2 }))   -- fails
---
---@param other Set: the other set to check for equality
---@param set Set: the set to check (implicit argument passed via assert.set)
function SetHandler.eq(set, args)
  local other = args[1]

  assert(getmetatable(other) == Set, fmt('expected other to be set: %s', other))

  return table_equals(set.items, other.items) and set.len == other.len, { other }
end


--- A set assertion that checks that a set is the same object as another set, and whose
--- negation checks that it's not. For example:
---
---   local set_a = Set.new({ 1, 2, 3 })
---   local set_b = Set.new({ 1, 2, 3 })
---
---   assert.set(set_a).same(set_a)         -- passes
---   assert.set(set_a).same(set_b)         -- fails
---   assert.set(set_a).Not.same(set_b)     -- passes
---   assert.set(set_a).Not.same(set_a)     -- fails
---
---@param other Set: the other set to check
---@param set Set: the set to check (implicit argument passed via assert.set)
function SetHandler.is(set, args)
  local other = args[1]

  return rawequal(set, other), { other }
end


--- A set assertion that checks that a set has a specific length, and whose negation
--- checks that it's length is anything other. For example:
---
---   assert.set(Set.new({ 1, 2, 3 })).has.length(3)               -- passes
---   assert.set(Set.new({ 1, 2, 3 })).has.length(2)               -- fails
---   assert.set(Set.new({ 1, 2, 3 })).does_not.have.length(0)     -- passes
---   assert.set(Set.new({})).does_not.have.length(0)              -- fails
---
---@param asserted_len integer: the asserted length of the set
---@param set Set: the set to check (implicit argument passed via assert.set)
function SetHandler.length(set, args)
  local asserted_len = args[1]
  local set_len = table_len(set.items)

  args[1] = set_len
  return set_len == asserted_len, { asserted_len, set_len }
end

return SetHandler


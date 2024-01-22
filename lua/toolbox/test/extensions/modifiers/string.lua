---@diagnostic disable: undefined-doc-param

local Utils = require 'toolbox.test.utils'

local assert = require 'luassert.assert'

local fmt = Utils.fmt
local is_substring = Utils.is_substring
local to_set = Utils.to_set

--- A handler for an assert modifier that enables interactions w/ strings. For example:
---
---   assert.string(string).Not.empty()
---   assert.string(string).is_a.permutation('azecb')
---
---@class StringHandler
local StringHandler = {}

--- A string assertion that checks that a all provided elements are substrings of a
--- string, and whose negation checks that at least one isn't. For example:
---
---   assert.string('me + you').contains({ 'me', 'you' })           -- passes
---   assert.string('me + you').contains({ 'me', 'you', 'us' })     -- fails
---   assert.string('me + you').Not.contains({ 'us', 'them' })      -- passes
---   assert.string('me + you').Not.contains({ 'you', 'me' })       -- fails
---
--- The assertion will fail fast on the first missing/present substring (so it will report
--- failures one at a time).
---
---@param should_contain any[]: contains the elements to that arr should/should not
--- contain
---@param str string: the string to check (implicit argument passed via assert.string)
function StringHandler.contains(str, args)
  local should_contain = args[1]
  assert(#should_contain > 0, fmt '#should_contains must be > 0')

  local missing = nil

  for _, substr in ipairs(should_contain) do
    if not is_substring(str, substr) then
      missing = substr
      args[1] = substr
      break -- fail fast on first missing value
    end
  end

  args.n = missing and 1 or 0
  return missing == nil, { missing }
end

--- A string assertion that checks that a string is empty, and whose negation checks that
--- it isn't. For example:
---
---   assert.string('').empty()                     -- passes
---   assert.string('hey there!').empty()           -- fails
---   assert.string("bye bye :'(").Not.empty()      -- passes
---   assert.string('').Not.empty()                 -- fails
---
---@param str string: the string to check (implicit argument passed via assert.string)
function StringHandler.empty(str, args)
  args[1] = #str
  return #str == 0, { #str }
end

--- A string assertion that checks that a string is equal to or is a permutation of
--- another, and whose negation checks that it isn't. For example:
---
---   assert.string().eq()         -- passes
---   assert.string().eq()         -- fails
---   assert.string().Not.eq()     -- passes
---   assert.string().Not.eq()     -- fails
---
---@param other Array: the other array to check for equality
---@param arr any[]: the array to check (implicit argument passed via assert.array)
function StringHandler.eq(arr, args)
  local other = args[1]

  return table_equals(arr, other), { other }
end

--- An array assertion that checks that an array is the same object as another array, and
--- whose negation checks that it's not. For example:
---
---   local arr_a = { 1, 2, 3 }
---   local arr_b = { 1, 2, 3 }
---
---   assert.array(arr_a).same(arr_a)         -- passes
---   assert.array(arr_a).same(arr_b)         -- fails
---   assert.array(arr_a).Not.same(arr_b)     -- passes
---   assert.array(arr_a).Not.same(arr_a)     -- fails
---
---@param other Array: the other array to check
---@param arr any[]: the array to check (implicit argument passed via assert.array)
function StringHandler.is(arr, args)
  local other = args[1]

  return rawequal(arr, other), { other }
end

--- An array assertion that checks that an array has a specific length, and whose negation
--- checks that it's length is anything other. For example:
---
---   assert.array({ 1, 2, 3 }).has.length(3)               -- passes
---   assert.array({ 1, 2, 3 }).has.length(2)               -- fails
---   assert.array({ 1, 2, 3 }).does_not.have.length(0)     -- passes
---   assert.array({}).Not.length(0)                        -- fails
---
---@param asserted_len integer: the asserted length of the array
---@param arr any[]: the array to check (implicit argument passed via assert.array)
function StringHandler.length(arr, args)
  local asserted_len = args[1]

  args[1] = #arr
  return #arr == asserted_len, { #arr }
end

return StringHandler

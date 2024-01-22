---@diagnostic disable: undefined-doc-param

local Utils = require 'toolbox.test.utils'

local assert = require 'luassert.assert'

local fmt = Utils.fmt
local table_equals = Utils.table_equals
local to_set = Utils.to_set

--- A handler for an assert modifier that enables interactions w/ arrays. For example:
---
---   assert.array(arr).empty()
---   assert.array(arr).Not.contains({ 'a', 1, 'z' })
---
---@class ArrayHandler
local ArrayHandler = {}

--- An array assertion that checks that an array contains all provided elements, and whose
--- negation checks that it's missing at least one of them. For example:
---
---   assert.array({ 1, 2, 3 }).contains({ 1, 3 })              -- passes
---   assert.array({ 1, 2, 3 }).contains({ 1, 2, 3, 4 })        -- fails
---   assert.array({ 1, 2, 3 }).Not.contains({ 4, 8 })          -- passes
---   assert.array({ 1, 2, 3 }).Not.contains({ 1, 3 })          -- fails
---
--- The assertion will fail fast on the first missing/present element (so it will report
--- failures one at a time).
---
---@param should_contain any[]: contains the elements to that arr should/should not
--- contain
---@param arr any[]: the array to check (implicit argument passed via assert.array)
function ArrayHandler.contains(arr, args)
  local should_contain = args[1]
  assert(#should_contain > 0, fmt '#should_contains must be > 0')

  local arr_set = to_set(arr)
  local missing = nil

  for _, e in ipairs(should_contain) do
    if arr_set[e] == nil then
      missing = e
      args[1] = e
      break -- fail fast on first missing value
    end
  end

  args.n = missing and 1 or 0
  return missing == nil, { missing }
end

--- An array assertion that checks that an array is empty, and whose negation checks that
--- it isn't. For example:
---
---   assert.array({}).empty()                -- passes
---   assert.array({ 1, 2, 3 }).empty()       -- fails
---   assert.array({ 1, 2, 3 }).Not.empty()   -- passes
---   assert.array({}).Not.empty()            -- fails
---
---@param arr any[]: the array to check (implicit argument passed via assert.array)
function ArrayHandler.empty(arr, args)
  args[1] = #arr
  return #arr == 0, { #arr }
end

--- An array assertion that checks that an array is equal to another array, and whose
--- negation checks that it isn't. For example:
---
---   assert.array({ 1, 2, 3 }).eq({ 1, 2, 3 })         -- passes
---   assert.array({ 1, 2, 3 }).eq({ 1, 3, 2 })         -- fails
---   assert.array({ 1, 2, 3 }).Not.eq({ 3, 2, 1 })     -- passes
---   assert.array({}).Not.eq({})                       -- fails
---
---@param other Array: the other array to check for equality
---@param arr any[]: the array to check (implicit argument passed via assert.array)
function ArrayHandler.eq(arr, args)
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
function ArrayHandler.is(arr, args)
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
function ArrayHandler.length(arr, args)
  local asserted_len = args[1]

  args[1] = #arr
  return #arr == asserted_len, { #arr }
end

return ArrayHandler

local map = require 'lib.lua.utils.map'


--- A class that attempts to roughly replicate Java 8's Stream API:
--  https://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html.
--
---@class Stream
local Stream = {}
Stream.__index = Stream

--- Constructor that takes an array.
--
---@param array table?: a table, ideally array-like, on which to preform stream operations
---@return Stream a stream that wraps the provided array
function Stream.new(array)
  local this = { array = array or {} }

  setmetatable(this, Stream)

  return this
end


--- Create a new stream that contains the elements of "this" stream filtered by the
--  provided predicate.
--
---@param predicate function: the predicate function used to filter values from "this" stream
---@return Stream: a new stream that contains the elements of "this" stream, filtered by
-- the provided predicate
function Stream:filter(predicate)
  local filtered = map.filter(self.array, predicate)
  return Stream.new(filtered)
end


--- Creates a new stream that contains the elements of "this" stream transformed by the
--  provided mapping function.
--
---@param mapper function: a function that transforms values of "this" stream
---@return Stream: a new stream that contains the elements of "this" stream transformed
-- by the provided mapping function
function Stream:map(mapper)
  local mapped = map.map(self.array, mapper)
  return Stream.new(mapped)
end


--- Calls the provided function on each item in "this" stream.
--
---@param func function: called on each item in "this" stream
function Stream:foreach(func)
  for i, item in ipairs(self.array) do
    func(item, i)
  end
end


--- Reduces the values of "this" stream according to the provided reducer function and
--  initial value.
--
---@param reducer function: a function that reduces values of "this" stream to a single value
---@param init any: the initial value to use for reduction
---@return any: the values of "this" stream combined according to the provided reducer
-- function and initial value
function Stream:reduce(reducer, init)
  local reduced = map.reduce(self.array, reducer, init)
  return reduced
end


--- "Collects" the values of "this" stream. "Collection" basically amounts to performing a
--  transform on the elements of a stream collectively, as opposed to individually, the
--  way map does.
--
---@param collector function: the "collector" function that takes the elements of the stream
-- as an argument
---@return any: the elements of "this" stream, transformed by the collection function
function Stream:collect(collector)
  return collector(self.array)
end


---@return table: the raw elements of "this" stream
function Stream:get()
  return self.array
end

return Stream.new


local map = require 'toolbox.utils.map'


--- A class that attempts to roughly replicate Java 8's Stream API:
--- https://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html.
---
--- TODO: implement Stream:flatmap
---
---@class Stream<T>
---@field private array `T`[]: backing data structure
local Stream = {}
Stream.__index = Stream

--- Constructor that takes an array.
---
---@generic T
---@param array T[]?: an array-like table on which to preform stream operations
---@return Stream: a stream that wraps the provided array
function Stream.new(array)
  local this = { array = array or {} }
  setmetatable(this, Stream)
  return this
end


--- Create a new stream that contains the elements of "this" stream filtered by the
--- provided predicate.
---
---@generic T
---@param predicate fun(i: T): f: boolean: the predicate function used to filter values
--- from "this" stream
---@return Stream: a new stream that contains the elements of "this" stream, filtered
--- by the provided predicate
function Stream:filter(predicate)
  local filtered = map.filter(self.array, predicate)
  return Stream.new(filtered)
end


--- Creates a new stream that contains the elements of "this" stream transformed by the
--- provided mapping function.
---
---@generic T, M
---@param mapper fun(i: T): m: M: a function that transforms values of "this" stream
---@return Stream: a new stream that contains the elements of "this" stream transformed
--- by the provided mapping function
function Stream:map(mapper)
  local mapped = map.map(self.array, mapper)
  return Stream.new(mapped)
end


--- Calls func on each element of "this" stream but returns them unchanged. One can think
--- of this method as a cross b/w foreach (perform an action w/ values) and map (values
--- are returned).
---
---@generic T
---@param func fun(i: T): n: nil: a function that performs actions w/ the elements of the
--- stream, but does not transform or filter them in any way
---@return Stream: a new stream that contains the unchanged elements of "this" stream
function Stream:peek(func)
  local unmapped = map.map(self.array, function(i) func(i); return i end)
  return Stream.new(unmapped)
end


--- Calls the provided function on each item in "this" stream.
---
---@generic T
---@param func fun(it: T, i: integer): n: nil: called on each item in "this" stream
function Stream:foreach(func)
  for i, item in ipairs(self.array) do
    func(item, i)
  end
end


--- Reduces the values of "this" stream according to the provided reducer function and
--- initial value.
---
---@generic T
---@param reducer fun(l: T?, r: T): c: T: a function that reduces values of "this" stream
--- to a single value
---@param init T?: the initial value to use for reduction
---@return T: the values of "this" stream combined according to the provided reducer
--- function and initial value
function Stream:reduce(reducer, init)
  local reduced = map.reduce(self.array, reducer, init)
  return reduced
end


--- "Collects" the values of "this" stream. "Collection" basically amounts to performing a
--- transform on the elements of a stream collectively, as opposed to individually, the
--- way map does.
---
---@generic S, T
---@param collector (fun(c: S[]): o: T)?: the "collector" function that takes the elements of
--- the stream as an argument; if not provided, a no-op collector is used, i.e.: the array-like
--- table that backs the stream is returned
---@return T: the elements of "this" stream, transformed by the collection function
function Stream:collect(collector)
  collector = collector or function() return self.array end
  return collector(self.array)
end


---@generic T
---@return T[]: the raw elements of "this" stream
function Stream:get()
  return self.array
end

return Stream.new


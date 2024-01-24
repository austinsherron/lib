local Array = require 'toolbox.core.array'
local Bool = require 'toolbox.core.bool'
local Iter = require 'toolbox.utils.iter'
local Lambda = require 'toolbox.functional.lambda'
local Map = require 'toolbox.utils.map'
local Num = require 'toolbox.core.num'
local Set = require 'toolbox.extensions.set'

--- A class that attempts to roughly replicate Java 8's Stream API:
--- https://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html.
---
--- TODO: implement Stream:flatmap
---
---@class Stream<T>
---@field private iterable Iterable: backing data structure
local Stream = {}
Stream.__index = Stream

--- Constructor that takes an array.
---
---@generic T
---@param iterable Iterable: an iterable data-structure on which to preform stream
--- operations
---@return Stream: a stream that wraps the provided iterable
function Stream.new(iterable)
  return setmetatable({ iterable = iterable or {} }, Stream)
end

--- Create a new stream that contains the elements of "this" stream filtered by the
--- provided predicate.
---
---@generic T
---@param predicate fun(e: T, i: integer): f: boolean: the predicate function used to
--- filter values from "this" stream
---@return Stream: a new stream that contains the elements of "this" stream, filtered
--- by the provided predicate
function Stream:filter(predicate)
  local filtered = Map.filter(self.iterable, predicate)
  return Stream.new(filtered)
end

--- Creates a new stream that contains the elements of "this" stream transformed by the
--- provided mapping function.
---
---@generic T, M
---@param mapper fun(e: T, i: integer): m: M: a function that transforms values of "this"
--- stream
---@return Stream: a new stream that contains the elements of "this" stream transformed
--- by the provided mapping function
function Stream:map(mapper)
  local mapped = Map.map(self.iterable, mapper)
  return Stream.new(mapped)
end

--- Creates a new stream that contains the elements of the iterable elements of "this"
--- stream transformed by the provided mapping function.
---
---@generic T, M
---@param mapper (fun(i: T): m: M)|nil: optional, defaults to a function the identity
--- function; a function that transforms values of "this" stream
---@return Stream: a new stream that contains the elements of the iterable elements of
--- "this" stream transformed by the provided mapping function
function Stream:flatmap(mapper)
  mapper = mapper or Lambda.IDENTITY
  local mapped = {}

  for _, iterable in ipairs(self.iterable) do
    for _, value in ipairs(iterable) do
      table.insert(mapped, mapper(value))
    end
  end

  return Stream.new(mapped)
end

--- Calls func on each element of "this" stream but returns them unchanged. One can think
--- of this method as a cross b/w foreach (perform an action w/ values) and map (values
--- are returned).
---
---@generic T
---@param func fun(e: T, i: integer): n: nil: a function that performs actions w/ the
--- elements of the stream, but does not transform or filter them in any way
---@return Stream: a new stream that contains the unchanged elements of "this" stream
function Stream:peek(func)
  local unmapped = Map.map(self.iterable, function(e, i)
    func(e, i)
    return e
  end)
  return Stream.new(unmapped)
end

--- Calls the provided function on each item in "this" stream.
---
---@generic T
---@param func fun(e: T, i: integer): n: nil: called on each item in "this" stream
function Stream:foreach(func)
  for i, item in ipairs(self.iterable) do
    func(item, i)
  end
end

--- Reduces the values of "this" stream according to the provided reducer function and
--- initial value.
---
---@generic S, T
---@param reducer fun(l: S|nil, r: S, i: integer): c: T: a function that reduces values of
--- "this" stream to a single value
---@param init T|nil: the initial value to use for reduction
---@return T: the values of "this" stream combined according to the provided reducer
--- function and initial value
function Stream:reduce(reducer, init)
  local reduced = Map.reduce(self.iterable, reducer, init)
  return reduced
end

local function default_collector(iterable)
  local arr = {}

  for _, i in ipairs(iterable) do
    table.insert(arr, i)
  end

  return arr
end

--- "Collects" the values of "this" stream. "Collection" basically amounts to performing a
--- transform on the elements of a stream collectively, as opposed to individually, the
--- way map does.
---
---@generic T
---@param collector (fun(c: Iterable): o: T)|nil: optional, defaults to a function that
--- collects stream items to an array; a function that takes as an argument the iterable
--- that backs this stream; if not provided
---@return T: the elements of "this" stream, transformed by the collector function
function Stream:collect(collector)
  collector = collector or default_collector
  return collector(self.iterable)
end

---@generic T
---@return Iterable: contains the raw elements of "this" stream
function Stream:get()
  return self.iterable
end

--- A collection of functions for use w/ Stream:collect.
---
---@class Collectors
local Collectors = {}

---@note: to expose Collectors
Stream.Collectors = Collectors

--- Creates a collector that, given an iterable, returns an array that contains its
--- entries.
---
---@generic T
---@return fun(it: Iterable): T[]: a function that, given an iterable, returns an array
--- that contains its entries
function Collectors.to_array()
  return function(it)
    return Iter.Utils.to_collection(it, {}, Array.append)
  end
end

--- Creates a collector that, given an iterable, returns a set that contains its entries.
---
---@generic T
---@return fun(it: Iterable): T[]: a function that, given an iterable, returns a set that
--- contains its entries
function Collectors.to_set()
  return function(it)
    return Iter.Utils.to_collection(it, Set.new(), Set.add)
  end
end

--- Creates a collector that, given an iterable, returns a stringified version of its
--- entries.
---
---@generic T
---@param sep string: optional, defaults to ",": the string to use to join elements of the
--- iterable
---@return fun(it: Iterable): T[]: a function that, given an iterable, returns a
--- stringified version of its entries
function Collectors.joining(sep)
  return function(it)
    return Iter.Utils.joining(it, sep)
  end
end

--- Creates a collector that, given an iterable, returns its only entry.
---
---@generic T
---@param strict boolean|nil: optional, defaults to true; if true, raises an error if the
---- iterable is empty or contains more than one entry
---@return fun(it: Iterable): T|nil: a function that, given an iterable, returns its only
--- entry
function Collectors.to_only(strict)
  strict = Bool.or_default(strict, true)

  return function(it)
    return Iter.Utils.get_only(it, strict)
  end
end

--- Creates a collector that, given an iterable of numbers, returns its max.
---
---@return fun(it: Iterable): max: number: a function that, given an iterable of numbers,
--- returns its max
function Collectors.max()
  return function(it)
    return Num.max(it)
  end
end

--- Creates a collector that, given an iterable of numbers, returns its min.
---
---@return fun(it: Iterable): min: number: a function that, given an iterable of numbers,
--- returns its min
function Collectors.min()
  return function(it)
    return Num.min(it)
  end
end

return Stream

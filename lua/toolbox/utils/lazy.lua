local Callable = require 'toolbox.functional.callable'
local Introspect = require 'toolbox.meta.introspect'
local OnErr = require 'toolbox.error.onerr'
local String = require 'toolbox.core.string'

local ternary = require('toolbox.core.bool').ternary

---@class _LazyValue
---@field private loaded boolean: flag that indicates that the loader function was called,
--- as it's possible for a loader function to return nil
---@field private loader fun(): l: `T`: function that loads the lazy-loaded value
---@field private backup Callable|nil: a value to substitute for the lazy-loaded value in
--- the event of an error in the loader function
---@field package val `T`: the lazy-loaded value
---@field package err string|nil: an error message from a failed call to loader, if any
--- was encountered
---@field [any] any
local _LazyValue = {}
_LazyValue.__index = _LazyValue

function _LazyValue.new(loader, backup)
  return setmetatable({
    loaded = false,
    loader = loader,
    val = nil,
    backup = backup or Callable.empty(),
    err = nil,
  }, _LazyValue)
end

---@package
function _LazyValue:load()
  if self.loaded then
    return self.val
  end

  self.val, self.err = OnErr.substitute(self.loader, self.backup)
  self.loaded = true

  if self.val == nil and String.not_nil_or_empty(self.err) then
    error(String.fmt('Lazy: unable to load value: %s', self.err or ''))
  end

  return self.val
end

--- Gets the lazy loaded value.
---
---@generic T
---@return T: the lazy loaded value
function _LazyValue:get()
  return self:load()
end

--- Wraps a function that loads a value and calls it only when callers request it.
---
--- FIXME: comparison metamethods don't work (read: aren't called) when comparing to
---        different types.
---
---@class LazyValue
---@field private val _LazyValue: the lazy-loaded value
---@field [any] any
local LazyValue = {}
LazyValue.__index = LazyValue

--- Constructor
---
---@generic T
---@param loader fun(): l: T: the function that loads the lazy-loaded value
---@param backup Callable|nil: a value to substitute for the lazy-loaded value in the
--- event of an error in the loader function
---@return LazyValue: a new instance
function LazyValue.new(loader, backup)
  return setmetatable({
    val = _LazyValue.new(loader, backup),
  }, LazyValue)
end

--- Loads the lazy-loaded value if necessary and returns it.
---
---@generic T
---@return T|nil: the lazy-loaded value
function LazyValue:get()
  return self.val:get()
end

---@return string|nil: the error response from the call to loader, if any
function LazyValue:get_error()
  return self.val.err
end

--- Custom index metamethod that loads the lazy-loaded value if necessary before indexing.
---
---@generic T
---@param k any: a key that (hypothetically) maps to the value being requested
---@return T|nil: the value that maps to k in the lazy-loaded value, if it exists
function LazyValue:__index(k)
  if Introspect.in_metatable(self, k) then
    return Introspect.get_from_metatable(self, k)
  end

  return self.val:load()[k]
end

local function get_maybe_lazy(maybe)
  return ternary(getmetatable(maybe) == LazyValue, function()
    return maybe:load()
  end, maybe)
end

---@private
function LazyValue:compare_maybe_lazy(maybe, comparator)
  local to_compare = get_maybe_lazy(maybe)
  return comparator(self.val:load(), to_compare)
end

--- Custom equals method that loads the lazy-loaded value if necessary before checking
--- equality.
---
--- See FIXME in class docs.
---
---@param o any: the other value to check for equality
---@return boolean: true if the provided value == this instance, (or the value contained
--- therein) false otherwise
function LazyValue:__eq(o)
  return self:compare_maybe_lazy(o, function(l, r)
    return l == r
  end)
end

--- Custom equals method that loads the lazy-loaded value if necessary before checking
--- equality.
---
--- See FIXME in class docs.
---
---@param o any|nil: the other value to check for equality
---@return boolean: true if the provided value == this instance, (or the value contained
--- therein) false otherwise
function LazyValue:__lt(o)
  return self:compare_maybe_lazy(o, function(l, r)
    return l < r
  end)
end

--- Custom equals method that loads the lazy-loaded value if necessary before checking
--- equality.
---
--- See FIXME in class docs.
---
---@param o any|nil: the other value to check for equality
---@return boolean: true if the provided value == this instance, (or the value contained
--- therein) false otherwise
function LazyValue:__le(o)
  return self:compare_maybe_lazy(o, function(l, r)
    return l <= r
  end)
end

--- Custom call method that loads the lazy-loaded value if necessary and returns it.
---
---@note: If the lazy-loaded value can't be called, this method will raise an error.
---
---@generic T
---@param ... any: args to pass to the lazy-loaded value call
---@return T: the lazy-loaded value
function LazyValue:__call(...)
  local val = self.val:load()
  return val(...)
end

--- Custom concat method that loads the lazy-loaded value if necessary and "joins" it to
--- the provided value.
---
---@generic T
---@return T: the lazy-loaded value concatenated to the provided value "o"
function LazyValue:__concat(o)
  return self.val:load() .. get_maybe_lazy(o)
end

--- Contains utilities for lazy evaluation.
--
---@class Lazy
local Lazy = {}

--- Allows lazy evaluation of a value.
--
---@generic T
---@param loader fun(): l: T: a function that loads the value when needed
---@param backup Callable|nil: a value to substitute for the lazy-loaded value in the
--- event of an error in the loader function
---@return LazyValue: a "getter" function for the lazy value; the first invocation of
-- this function will load the value
function Lazy.value(loader, backup)
  return LazyValue.new(loader, backup)
end

--- Lazy evaluates a require of the given resource.
--
---@generic T
---@param to_require string: the import path of the resource to require
---@param backup Callable|nil: a value to substitute for the value from the lazy-loaded
--- module
---@return LazyValue<T>: a lazy-loaded value loaded via a require call
function Lazy.require(to_require, backup)
  return Lazy.value(function()
    return require(to_require)
  end, backup)
end

return Lazy

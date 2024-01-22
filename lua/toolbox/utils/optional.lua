--- A utility that mimics Java's "Optional" api. See
--- https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html.
---
---@class Optional<T>
---@field private value `T`
local Optional = {}
Optional.__index = Optional

--- Constructor
---
---@generic T
---@param value T|nil: the optional's value
---@return Optional: a new instance
function Optional.of(value)
  return setmetatable({ value = value }, Optional)
end

--- Constructor that creates an empty instance (its value is nil).
---
---@return Optional: a new instance
function Optional.empty()
  return Optional.of()
end

--- Gets this instance's value if non-nil, otherwise raise an error.
---@error if this instance's value is nil
function Optional:get()
  if self:is_present() then
    return self.value
  end

  error 'Optional.get: no value exists in the optional'
end

--- Checks if the optional's value is non-nil.
---
---@return boolean: true if this instance's value is non-nil, false otherwise
function Optional:is_present()
  return self.value ~= nil
end

--- Calls the provided consumer w/ this instance's value if it's non-nil; does nothing
--- otherwise.
---
---@generic T
---@param consumer fun(value: T) the function to call w/ this instance's value
function Optional:if_present(consumer)
  if not self:is_present() then
    return
  end

  consumer(self.value)
end

--- If this instance's value is non-nil, calls the provided mapper w/ it, and returns an
--- optional of mapper's return value. Does nothing if this instance's value is nil.
---
---@generic S, T
---@param mapper fun(value: T): S the mapper function to call w/ this instance's value
---@return Optional: an optional w/ the value returned by mapper, or an empty optional if
--- this instance's value is nil (or if mapper returns nil)
function Optional:map(mapper)
  if not self:is_present() then
    return Optional.empty()
  end

  return Optional.of(mapper(self.value))
end

--- Gets this instance's value if it's non-nil, otherwise returns other.
---
---@generic T
---@param other T: the value to return if this instance's value is nil
---@return T: this instance's value, or other if it's nil
function Optional:or_else(other)
  return self.value or other
end

--- Gets this instance's value if it's non-nil, otherwise returns the return value of
--- supplier.
---
---@generic T
---@param supplier fun(): T supplies the value to return if this instance's value is nil
---@return T: this instance's value, or the return value of supplier if it's nil
function Optional:or_else_get(supplier)
  return self.value or supplier()
end

--- Gets this instance's value if it's non-nil, otherwise raises an error.
---
---@generic T
---@param msg string|nil: optional; the error message to use if this instance's value is
--- nil
---@return T: this instance's value if it's non-nil
function Optional:or_else_error(msg)
  msg = msg or 'No value exists in the optional'

  if self:is_present() then
    return self.value
  end

  error(msg)
end

return Optional

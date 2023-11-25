local Array = require 'toolbox.core.array'
local Table = require 'toolbox.core.table'
local Iter  = require 'toolbox.extensions.iter'

local ternary = require('toolbox.core.bool').ternary


--- A simple stack implementation whose instances are backed by tables.
---
---@generic T
---@class Stack<T>
---@field private stack `T`[]: backing data structure
local Stack = {}
Stack.__index = Stack


--- Constructor
---
---@generic T
---@param ... T: initial items to push onto the stack
---@return Stack: a new instance
function Stack.new(...)
  local this = { stack = Table.pack(...) }
  return setmetatable(this, Stack)
end


--- Copy constructor
---
--- Note: this copy constructor performs "shallow" copies, meaning that complex/nested
--- objects are not truly copied (read: only their references are copied).
---
---@param o Stack: the stack to copy
---@return Stack: a new instance that is a shallow copy of o
function Stack.copy(o)
  return Stack.new(Table.unpack(o.stack))
end


--- Returns the number of items in the stack.
---
---@operator unm:Stack
---@return integer: the number of items in the stack
function Stack:__len()
  return #self.stack
end


---@return boolean: true if there are no items in the stack, false otherwise
function Stack:empty()
  return #self.stack == 0
end


--- Pushes an item onto the stack.
---
---@generic T
---@param item T: the item to push onto the stack
function Stack:push(item)
  Array.append(self.stack, item)
end


--- Pops an item off of the stack and returns it, or nil if the stack is
--- empty.
---
---@generic T
---@return T|nil: the item popped from the stack, or nil if the stack is empty
function Stack:pop()
  if self:empty() then
    return nil
  end

  local popped = self:peek()

  self.stack = ternary(
    #self == 1,
    {},
    Array.slice(self.stack, 1, -1)
  )

  return popped
end


---@generic T
---@return T|nil: returns the same value as would an equivalent call to pop w/out
--- modifying the stack (i.e.: no value is removed from the stack)
function Stack:peek()
  return self.stack[#self]
end


---@generic T
---@return T[]: returns all items in the stack w/out popping any elements; elements are
--- returned in the order in which they'd be popped from the stack, assuming no stack
--- mutations
function Stack:peekall()
  return Array.reversed(self.stack)
end


--- Pushes all provided items onto the stack.
---
---@generic T
---@param ... T: the items to push onto the stack
function Stack:pushall(...)
  self.stack = Table.concat({ self.stack, Table.pack(...) })
end


--- Checks if the provided stack is equal to this stack.
---
---@note: this method assumes one dimensional stacks, and that stack contents are not
--- themselves value containers (i.e.: tables). This method performs tests for "shallow"
--- equality.
---
---@param o Stack: the other stack
---@return boolean: true if the provided stack is (shallow) equal to this stack, false
--- otherwise
function Stack:__eq(o)
  if #self ~= #o then
    return false
  end

  for i = 1, #self do
    if self.stack[i] ~= o.stack[i] then
      return false
    end
  end

  return true
end


--- Metamethod that allows stacks to be used w/ the ipairs function, i.e.: that enables
--- iteration over stacks.
---
---@note: items are yielded in the order in which they'd be popped from the stack.
---
---@generic T
---@return fun(): (number,T): a next function that returns successive entries in this stack
---@return T[]: an array-like table that contains the elements in this stack
---@return nil: the starting point for iteration
function Stack:__ipairs()
  local items = Array.reversed(self.stack)
  local next = Iter.array(items)
  return next, items, nil
end


--- Constructs and returns a string representation of the set.
---
---@return string: a string representation of the set
function Stack:__tostring()
  return Table.tostring(self.stack, 'stack(', ')')
end

return Stack


local Iter = require 'toolbox.utils.iter'
local Table = require 'toolbox.core.table'

--- A simple set implementation whose instances are backed by tables.
--
---@generic T
---@class Set<T>: { [T]: boolean }
---@field private items { [`T`]: boolean }: backing data structure
---@field private len integer: "cached" length of the set
local Set = {}
Set.__index = Set

local function add(item, set)
  if set.items[item] == nil then
    set.len = set.len + 1
  end

  set.items[item] = true
end

--- Constructor
--
---@generic T
---@param initial T[]?: initial items to add to the set
---@return Set: a new instance
function Set.new(initial)
  initial = initial or {}
  local this = { items = {}, len = 0 }

  for _, item in ipairs(initial) do
    add(item, this)
  end

  setmetatable(this, Set)
  return this
end

--- Constructor
---
---@generic T
---@param ... T?: initial contents
---@return Set: a new instance
function Set.of(...)
  return Set.new(Table.pack(...))
end

--- Constructor for a set w/ one (initial) item.
---
---@generic T
---@param item T: initial contents
---@return Set: a new instance
function Set.only(item)
  return Set.new({ item })
end

--- Constructor for a set w/ no elements.
---
---@return Set: a new instance w/ no items
function Set.empty()
  return Set.new()
end

--- Copy constructor
--
--  Note: this copy constructor performs "shallow" copies, meaning that complex/nested
--  objects are not truly copied (read: only their references are copied).
--
---@param o Set: the set to copy
---@return Set: a new instance that is a shallow copy of o
function Set.copy(o)
  local this = { items = {}, len = 0 }

  for item, _ in pairs(o.items) do
    add(item, this)
  end

  setmetatable(this, Set)
  return this
end

--- Adds an item to the set.
--
---@generic T
---@param item T: the item to add to the set
function Set:add(item)
  add(item, self)
end

--- Adds all provided items to the set.
--
---@generic T
---@param ... T: the items to add to the set
function Set:addall(...)
  local items = Table.pack(...)

  for _, item in ipairs(items) do
    self:add(item)
  end
end

--- Removes an item from the set, if present.
---
---@generic T
---@param item T: the item to remove from the set
function Set:remove(item)
  self.items[item] = nil
end

--- Removes all provided items from the set, if present.
---
---@generic T
---@param ... T: the items to remove from the set
function Set:removeall(...)
  local items = Table.pack(...)

  for _, item in ipairs(items) do
    self:remove(item)
  end
end

--- Returns true if item is in the set, false otherwise.
--
---@generic T
---@param item T?: the item to check
---@return boolean: true if item is in the set, false otherwise
function Set:contains(item)
  return self.items[item] ~= nil
end

---@generic T
---@return T[]: an array-like table that contains the entries in the set
function Set:entries()
  return Table.keys(self.items)
end

--- Checks if the set is a superset of o.
---
---@param o Set: the set to check
---@return boolean: true if the set is a superset of o, false otherwise
function Set:superset_of(o)
  return o:subset_of(self)
end

--- Checks if the set is a subset of o.
---
---@param o Set: the set to check
---@return boolean: true if the set is a subset of o, false otherwise
function Set:subset_of(o)
  for e, _ in pairs(self.items) do
    if o.items[e] == nil then
      return false
    end
  end

  return true
end

--- Returns the number of items in the set.
--
---@operator unm:Set
---@return integer: the number of items in the set
function Set:__len()
  return self.len
end

--- Checks if the provided set is equal to this set.
--
---@param o Set: the other set
---@return boolean: true if the provided set is equal to this set, false otherwise
function Set:__eq(o)
  if #self ~= #o then
    return false
  end

  for k, _ in pairs(self.items) do
    if not o:contains(k) then
      return false
    end
  end

  for k, _ in pairs(o.items) do
    if not self:contains(k) then
      return false
    end
  end

  return true
end

--- Constructs and returns the union of this set and the set "o".
--
---@param o Set: the "other" set
function Set:__add(o)
  local new = Set.copy(self)
  new:addall(Table.unpack(o:entries()))
  return new
end

--- Constructs and returns the difference of this set and the set "o".
--
---@param o Set: the "other" set
function Set:__sub(o)
  local new = Set.new()

  for _, v in ipairs(self) do
    if not o:contains(v) then
      new:add(v)
    end
  end

  return new
end

---Alias for Set:__add.
--
---@see Set.__add
function Set:__concat(o)
  return self + o
end

--- Metamethod that allows sets to be used w/ the ipairs function.
--
---@generic T
---@return fun(): (number,T): a next function that returns successive entries in this set
---@return T[]: an array-like table that contains the elements in this set
---@return nil: the starting point for iteration
function Set:__ipairs()
  local entries = self:entries()
  local next = Iter.array(entries)
  return next, entries, nil
end

--- Constructs and returns a string representation of the set.
--
---@return string: a string representation of the set
function Set:__tostring()
  local entries = self:entries()
  return Table.tostring(entries, 'set(', ')')
end

return Set

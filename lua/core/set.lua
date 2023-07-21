local tbl = require 'lib.lua.core.table'


--- A simple set implementation whose instances are backed by tables.
--
---@class Set<T>: { [T]: boolean }
---@field private items { [T]: boolean }: backing data structure
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
---@return Set<T>: this instance
function Set.new(initial)
  initial = initial or {}
  local this = { items = {}, len = 0 }

  for _, item in ipairs(initial) do
    add(item, this)
  end

  setmetatable(this, Set)
  return this
end


--- Copy constructor
--
--  Note: this copy constructor performs "shallow" copies, meaning that complex/nested
--  objects are not truly copied (read: only their references are copied).
--
---@generic T
---@param o Set<T>: the set to copy
---@return Set<T>: a new instance that is a shallow copy of o
function Set.copy(o)
  local this = { items = {}, len = 0 }

  for item, _  in pairs(o.items) do
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
  local items = table.pack(...)

  for _, item in ipairs(items) do
    self:add(item)
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

  return true
end


--- TODO: Constructs and returns the union of this set and the set "o".
--
---@generic T
---@param o Set<T>: the "other" set
function Set:__add(o)
  return Set.new()
end


--- TODO: Constructs and returns the difference of this set and the set "o".
--
---@generic T
---@param o Set<T>: the "other" set
function Set:__sub(o)
  return Set.new()
end


-- TODO: implement alias for + (__add)
function Set:__concat(o)
  return self + o
end


--- TODO: implement an iterator
function Set:__pairs()
end


--- Constructs and returns a string representation of the set.
--
---@return string: a string representation of the set
function Set:__tostring()
  local keys = tbl.keys(self.items)
  return tbl.tostring(keys, 'set(', ')')
end

return Set


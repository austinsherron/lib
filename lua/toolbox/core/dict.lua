local Common = require 'toolbox.core.__common'


--- Contains utilities for interacting w/ dictionary like tables, i.e.: tables whose keys
--- have meaning beyond integer indices.
---
---@note: in the docs in the remainder of this file, I'll use the terms dict/dictionary to
--- refer to tables w/ the aforementioned form.
---
---@class Dict
local Dict = {}

--- Checks if the provided dict is empty.
---
--- Note: a dict is still considered empty if it's comprised of any number of key-value
--- pairs (k, v) where all v == nil.
---
---@generic K, V
---@param dict { [K]: V }: the dict to check
---@return boolean: true if the provided dict is empty, false otherwise
function Dict.is_empty(dict)
  for _, v in pairs(dict) do
    if v ~= nil then
      return false
    end
  end

  return true
end


--- Checks that a dict is nil or empty.
--
---@generic K, V
---@param dict { [K]: V }|nil: the dict to check
---@return boolean: true if the dict is nil or empty, false otherwise
function Dict.nil_or_empty(dict)
  return dict == nil or Dict.is_empty(dict)
end


--- Checks that the provided dict is not nil nor empty.
--
---@generic K, V
---@param dict { [K]: V }|nil: the dict to check
---@return boolean: true if the dict is not nil nor empty, false otherwise
function Dict.not_nil_or_empty(dict)
  return dict ~= nil and not Dict.is_empty(dict)
end


--- Checks if two dicts are equals.

---@note: this function does not check metatables or account for cycles (self referencing
--- dicts).
---
---@generic K, V, L, W (K ?= L, V ?= W)
---@param l { [K]: V }: the "left" possible dictionary to check
---@param r { [L]: W }: the "right" possible dictionary to check
---@return boolean: true if l "shallow equals" r, false otherwise
function Dict.equals(l, r)
  if l == r then
    return true
  end

  for k, v in pairs(l) do
    if type(r[k]) ~= type(v) then
      return false
    elseif not Common.Table.is(v) and r[k] ~= v then
      return false
    elseif Common.Table.is(v) and not Dict.equals(v, r[k]) then
      return false
    end
  end

  for k, _ in pairs(r) do
    if l[k] == nil then
      return false
    end
  end

  return true
end


--- If key doesn't map to a value in dict, uses compute to generate one, add it dict,
--- and return it.
---
---@generic K, V
---@param dict { [K]: V }: the dict to check for key's value, and to which the return
--- value of compute should be added if one doesn't exist
---@param key K: the key to check for a value in dict, and to which compute's return value
--- will be associated if a value is added
---@param compute fun(k: K): V computes the value to add to dict @ key if one doesn't
--- already exist; if a value already exists, this function won't be called
---@return V: the value of dict @ key, or the return value of compute if none exists
function Dict.compute_if_nil(dict, key, compute)
  local val = dict[key]

  if val ~= nil then
    return val
  end

  dict[key] = compute(key)
  return dict[key]
end

return Dict


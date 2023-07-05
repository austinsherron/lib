local Set = {}

--- Checks the keys of two tables for set equality, i.e.: do the tables have the same keys.
--
---@param l table: a table whose keys to check for set equality
---@param r table: a table whose keys to check for set equality
---@return boolean: true if tables l and r have the same keys, false otherwise; false if
-- either l or r is nil
function Set.equals(l, r)
  if (l == nil or r == nil) then
    return false
  end

  if (#l ~= #r) then
    return false
  end

  for k, _ in pairs(l) do
    if (r[k] == nil) then
      return false
    end
  end

  return true
end

return Set


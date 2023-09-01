
--- A class that attempts to implement the semantics of Python's "defaultdict".
---
---@class DefaultDict<T>
---@field private defaulter DefaultDict
---@field private table DefaultDict
local DefaultDict = {}
DefaultDict.__index = DefaultDict

--- Constructor
---
---@generic T
---@param defaulter fun(): d: T: a function that returns initial values for new indices
---@return DefaultDict: a new instance
function DefaultDict.new(defaulter)
  return setmetatable({
    defaulter = defaulter,
    table     = {},
  }, DefaultDict)
end


--- Returns the value in the table that maps to k. If one isn't present, it uses the
--- defaulter function to initialize the value at k before returning it.
---
---@generic T
---@param k any: the key that maps to the desired value
---@return T: the value that maps to k, or the return value of defaulter if there's no
--- value that maps to k
function DefaultDict:__index(k)
  if self.table[k] == nil then
    self.table[k] = self.defaulter()
  end

  return self.table[k]
end

return DefaultDict


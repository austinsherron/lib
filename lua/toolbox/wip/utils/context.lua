--- A serializable context.
---
---@class Context
---@field private __logger Logger:
local Context = {}
Context.__index = Context

--- Constructor
--
---@return Context: a new instance
function Context.new(logger)
  return setmetatable({
    __logger = logger,
  }, Context)
end

---@note: Logger methods duplicated here for convenience.
---@see Logger
function Context:trace(...)
  self.__logger:trace(...)
end
function Context:debug(...)
  self.__logger:debug(...)
end
function Context:info(...)
  self.__logger:info(...)
end
function Context:warn(...)
  self.__logger:warn(...)
end
function Context:error(...)
  self.__logger:error(...)
end

return Context.new

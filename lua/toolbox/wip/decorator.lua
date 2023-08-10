
local mt = {
  __concat =
    function(a, f)
      return function(...)
        return f(...)
      end
    end
}

local function decorator(...)
  print('decorated!')
  return setmetatable({ ... }, mt)
end


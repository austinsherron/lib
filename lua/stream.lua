require 'lib.lua.map'


local Stream = {}
Stream.__index = Stream

function Stream.new(array)
  this = { array = array }

  setmetatable(this, Stream)

  return this
end


function Stream:filter(predicate)
  local filtered = filter(self.array, predicate)
  return Stream.new(filtered)
end


function Stream:map(mapper)
  local mapped = map(self.array, mapper)
  return Stream.new(mapped)
end


function Stream:reduce(reducer, init)
  local reduced = reduce(self.array, reducer, init)
  return reduced
end


function Stream:collect(collector)
  return collector(self.array)
end


function Stream:get()
  return self.array
end


return Stream.new


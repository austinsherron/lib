
local Num = {}

--- Returns the provided number n if it is min < n < max, otherwise, returns min if n < min
--  or max if n > max.
--
---@param n number: the number to bound
---@param min number: the minimum number that this function will return; must be < max
---@param max number: the maximum number that this function will return; must be > min
---@return number: n if min < n < max, otherwise min if n < min or max if n > max
---@error if min > max
function Num.bounds(n, min, max)
  if min > max then
    error(string.format('Num.bounds: min (%s) must be <= max (%s)', min, max))
  end

  if n < min then
    return min
  end

  if n > max then
    return max
  end

  return n
end

return Num


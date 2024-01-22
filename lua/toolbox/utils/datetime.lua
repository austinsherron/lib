local FMT_12_HR = '%m-%d-%Y %I:%M %p'
local FMT_24_HR = '%Y-%m-%d %H:%M:%S'

--- Contains utilities for interacting w/ and manipulating dates/times.
---
---@class Datetime
local Datetime = {}

--- Constructs and returns a string representation of the date and time now.
---
---@param use_12hr boolean?: if true, the time string will use a 12 hour format (i.e.: w/
--- am/pm); optional, defaults to false
---@return string: a date/time string w/ the date and time now
function Datetime.now(use_12hr)
  use_12hr = use_12hr or false

  local fmt = use_12hr and FMT_12_HR or FMT_24_HR
  return tostring(os.date(fmt))
end

return Datetime

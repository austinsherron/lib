
local Path = {}

--- Returns the path of the lua script that's currently executing. Sourced from
--  https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file.
--
---@return string: the path of the lua script that's currently executing
function Path.script_path()
   local str = debug.getinfo(2, 'S').source:sub(2)
   return str:match('(.*/)')
end


--- Returns the provided filename w/out the extension. If the filename provided has no
--  extension, this function returns nil. Sourced from
--  https://stackoverflow.com/questions/18884396/extracting-filename-only-with-pattern-matching.
--
---@param filename string: the filename we want to trim an extension from
---@return string: the provided filename w/out the extension, or nil if the filename provided
-- has no extension
function Path.trim_extension(filename)
  return filename:match('(.+)%..+')
end

return Path


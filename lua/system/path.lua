
local Path = {}

--- Equivalent to dirname in POSIX systems. Sourced from
--  https://github.com/Donearm/scripts/blob/master/lib/dirname.lua.
--
---@param path string: the path string
---@return string: the dirname of the provided path or empty string if the string doesn't
-- contain any path separators
function Path.dirname(path)
  if not path:match('.-/.-') then
    return ''
  end

  local dir, _ = string.gsub(path, '(.*/)(.*)', '%1')
  return dir
end


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


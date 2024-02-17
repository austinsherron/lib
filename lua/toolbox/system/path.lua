local Env = require 'toolbox.system.env'
local Stream = require 'toolbox.extensions.stream'
local String = require 'toolbox.core.string'

local ternary = require('toolbox.core.bool').ternary

local fmt = String.fmt

local Path = {}

--- Equivalent to dirname in POSIX systems. Sourced from
--  https://github.com/Donearm/scripts/blob/master/lib/dirname.lua.
--
---@param path string: the path string
---@return string: the dirname of the provided path or empty string if the string doesn't
-- contain any path separators
function Path.dirname(path)
  if not path:match '.-/.-' then
    return ''
  end

  local dir, _ = string.gsub(path, '(.*/)(.*)', '%1')
  return dir
end

--- Returns the basename from the provided path. For example:
--
--    * /home/austin/Workspace/nvim -> nvim
--    * /home/austin/Documents/note.txt -> note.txt
--
--  Note: returns nil if the provided string isn't a path (i.e.: doesn't contain "/"), or
--  if the base path is root ("/").
--
---@param path string: the path from which to extract the basename
---@return string|nil: the basename from the provided path or nil if the provided string
--- isn't a path (i.e.: doesn't contain "/") or if the base path is root ("/")
function Path.basename(path)
  return path:match '^.+/(.+)$'
end

function Path.filename(path)
  local basename = Path.basename(path) or path
  return Path.trim_extension(basename or '') or basename
end

--- Gets the provided path relative to rooter, where rooter is either a string path of
--- dir/project that contains path, or a function that finds one.
---
--- TODO: add real impl
---
---@param path string: the path whose path relative to rooter that we want
---@param rooter string|(fun(path: string): string)|nil optional, defaults to a function
--- that find's path's nearest ancestor dir w/ a git repo; that a literal string path
--- that's an - to ancestor path or a function that returns one
---@return string: the provided path relative to rooter
function Path.from_project_root(path, rooter)
  return ''
end

--- Returns the path of the lua script that's currently executing. Sourced from
--  https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file.
--
---@param depth integer|nil: call stack depth of the return script
---@return string: the path of the lua script that's currently executing
function Path.script_path(depth)
  depth = depth or 2

  local str = debug.getinfo(depth, 'S').source:sub(2)
  return str:match '(.*/)'
end

--- Returns the provided filename w/out the extension. If the filename provided has no
--  extension, this function returns nil. Sourced from
--  https://stackoverflow.com/questions/18884396/extracting-filename-only-with-pattern-matching.
--
---@param filename string: the filename we want to trim an extension from
---@return string: the provided filename w/out the extension, or nil if the filename provided
-- has no extension
function Path.trim_extension(filename)
  return filename:match '(.+)%..+'
end

--- Returns the extension of the provided filename. If it has no extension, this function
--- returns nil.
--
---@param filename string: the filename we want the extension from
---@return string: the extension of the provided filename, or nil if the filename has no
--- extension
function Path.extension(filename)
  return filename:match '.+%.(.+)'
end

--- Returns the abspath relative to root. Raises an error if abspath is not a child of
--- root.
---
---@param rootpath string: the path to transform abspath relative to
---@param abspath string: the absolute path to transform
---@return string: abspath relative to root
function Path.relative(rootpath, abspath)
  local sfx = ternary(String.endswith(rootpath, '/'), '', '/')
  local root = rootpath .. sfx

  if not Path.ischild(root, abspath) then
    error(fmt('Path.relative: %s is not a child of %s', abspath, rootpath))
  end

  return String.replace(abspath, root, '')
end

--- Uses string matching to check if path is a child of rootpath.
---
---@note: This function returns true if rootpath == path
---
---@param rootpath string: the root path to check against
---@param path string: the path to check against rootpath
---@return boolean: true if path is a child of rootpath or if rootpath == path, false
--- otherwise
function Path.ischild(rootpath, path)
  return String.startswith(path, rootpath)
end

--- Uses Path.is_child to find the entries in paths that are children or rootpath.
---
---@param rootpath string: the root path to check against
---@param paths string[]: the paths to check against rootpath
---@return string[]: the paths entries that are children or rootpath
function Path.get_children(rootpath, paths)
  return Stream.new(paths)
    :filter(function(p)
      return Path.ischild(rootpath, p)
    end)
    :collect()
end

--- Gets the "standard" cache path based on xdg spec.
---
---@param subdir string|nil: and optional sub-directory path to append
---@return string: the path to the cache dir
function Path.cache(subdir)
  subdir = (subdir and ('/' .. subdir) or '')
  return Env.xdg_cache_home() .. subdir
end

--- Gets the "standard" config path based on xdg spec.
---
---@param subdir string|nil: and optional sub-directory path to append
---@return string: the path to the config subdir
function Path.config(subdir)
  subdir = (subdir and ('/' .. subdir) or '')
  return Env.xdg_config_home() .. subdir
end

--- Gets the "standard" data path based on xdg spec.
---
---@param subdir string|nil: and optional sub-directory path to append
---@return string: the path to the data subdir
function Path.data(subdir)
  subdir = (subdir and ('/' .. subdir) or '')
  return Env.xdg_data_home() .. subdir
end

--- Gets the "standard" log path based.
---
---@param subdir string|nil: and optional sub-directory path to append
---@return string: the path to the log subdir
function Path.log(subdir)
  subdir = (subdir and ('/' .. subdir) or '')
  return Env.log_root() .. subdir
end

--- Gets the "standard" state path based on xdg spec.
---
---@param subdir string|nil: and optional sub-directory path to append
---@return string: the path to the state subdir
function Path.state(subdir)
  subdir = (subdir and ('/' .. subdir) or '')
  return Env.xdg_state_home() .. subdir
end

return Path

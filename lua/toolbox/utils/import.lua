local Path = require 'toolbox.system.path'
local Shell = require 'toolbox.system.shell'
local String = require 'toolbox.core.string'

local fmt = String.fmt

--- Contains utilities functions for importing ("requiring") lua code.
---
---@class Import
local Import = {}

--- Checks if a lua module exists.
---
--- NOTE: Adapted from https://stackoverflow.com/a/15434737.
---
---@param module string: a lua module identifier
---@return boolean: true if the provided module exists given the current lua env config,
--- false otherwise
function Import.does_module_exist(module)
  if package.loaded[module] then
    return true
  end

  for _, searcher in ipairs(package.loaders) do
    local loader = searcher(module)

    if type(loader) == 'function' then
      package.preload[module] = loader
      return true
    end
  end

  return false
end

--- Gets the current lua runtime path as an array of strings.
---
---@param raw boolean|nil: optional, defaults to false; if true, don't split the string
--- into an array
---@return string[]|string: the current lua runtime path as an array of strings, if not
--- raw, or as a string if raw == true
function Import.getpath(raw)
  if raw == true then
    return package.path
  end

  return String.split(package.path, ';')
end

local function make_package_paths(path)
  return {
    fmt('%s/?.lua', path),
    fmt('%s/?/init.lua', path),
  }
end

--- Adds path to the lua runtime path (i.e.: mutates package.path).
---
---@param path string: the path to add
---@param dryrun boolean|nil: optional, defaults to false; if true, don't mutate
--- package.paths
---@return string: the updated path
function Import.add_to_path(path, dryrun)
  local package_paths = String.join(make_package_paths(path), ';')

  if dryrun ~= true then
    package.path = package.path .. ';' .. package_paths
  end

  return Import.getpath(true) .. ';' .. package_paths
end

--- Recursively require all non-"init.lua" lua files in the provided directory.
--
---@param dir string: the path to the directory from which to source lua files
---@param require_base string: the "require" string that, when combined w/ a file found
-- by this function, makes a full/valid string for use w/ require
---@param process_require (fun(r: function, id: string): table|nil)|nil: optional function
--- to wrap the calls to require; note: process_require must call the function "r" and
--- return its value for require_for_init to function as intended
---@return table: a compound table that consists of all return values from required modules
---@error if the provided "dir" isn't a dir
function Import.require_for_init(dir, require_base, process_require)
  if not Shell.is_dir(dir) then
    error('dir=' .. dir .. 'must be a directory')
  end

  local result = {}
  process_require = process_require or function(f)
    return f()
  end

  for _, file in ipairs(Shell.ls(dir, true)) do
    local path = dir .. '/' .. file

    if Shell.is_dir(path) and file ~= '' then
      local nested_base = require_base .. '.' .. file

      table.insert(result, Import.require_for_init(path, nested_base, process_require))
    elseif String.endswith(file, '.lua') and file ~= 'init.lua' then
      local wo_extension = Path.trim_extension(file)
      local to_require = require_base .. '.' .. wo_extension

      local required = process_require(function()
        return require(to_require)
      end, wo_extension)

      table.insert(result, required)
    end
  end

  return result
end

--- Imports the lua modules in the provided dir path as global variables. A module's
--- global variable is named as the capitalized filename of the module.
---
---@param dirpath string: a path to a directory w/ lua modules to import and assign to
--- global variables
function Import.as_globals(dirpath)
  if not Shell.is_dir(dirpath) then
    error('dirpath=' .. dirpath .. 'must be a directory')
  end

  local children = Shell.ls(dirpath)

  for _, child in ipairs(children) do
    if not Shell.is_dir(child) then
      local varname = String.capitalize(Path.filename(child))
      local cmd = fmt("%s = dofile('%s')", varname, child)

      load(cmd)()
    end
  end
end

return Import

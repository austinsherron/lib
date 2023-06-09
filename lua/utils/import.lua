local pth = require 'lib.lua.system.path'
local shell = require 'lib.lua.system.shell'
local str = require 'lib.lua.core.string'


local Import = {}

--- Recursively require all non-"init.lua" lua files in the provided directory.
--
---@param dir string: the path to the directory from which to source lua files
---@param require_base boolean: the "require" string that, when combined w/ a file found
-- by this function, makes a full/valid string for use w/ require
---@return table: a compound table that consists of all return values from required modules
function Import.require_for_init(dir, require_base)
  if not shell.is_dir(dir) then
    error('dir=' .. dir .. 'must be a directory')
  end

  local result = {}

  for _, file in ipairs(shell.ls(dir, true)) do
    local path = dir ..'/' .. file

    if shell.is_dir(path) and file ~= '' then
      require_base = require_base .. '.' .. file
      table.insert(result, Import.require_for_init(path, require_base))
    elseif (str.endswith(file, '.lua') and file ~= 'init.lua') then
      local wo_extension = pth.trim_extension(file)
      local to_require = require_base .. '.' .. wo_extension

      table.insert(result, require(to_require))
    end
  end

  return result
end

return Import


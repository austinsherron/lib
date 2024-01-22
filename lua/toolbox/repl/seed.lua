---@diagnostic disable: lowercase-global, undefined-global

local Env = require 'toolbox.system.env'
local Import = require 'toolbox.utils.import'

Utils = {}

Utils.libroot = function()
  return Env.code_root() .. '/lib/lua'
end

local function make_dofile(root)
  return function(relpath)
    return dofile(root .. '/' .. relpath)
  end
end

Utils.toolbox = function(relpath)
  relpath = relpath and '/' .. relpath or ''
  return Utils.libroot() .. '/toolbox' .. relpath
end

Utils.dofile = function(root, relpath)
  return make_dofile(root)(relpath)
end

Utils.nvimload = make_dofile(Env.nvim_root())
Utils.libload = function(relpath)
  return make_dofile(Utils.toolbox(relpath))
end

local TO_LOAD = {
  'core',
  'extensions',
  'functional',
  'system',
  'utils',
}

for _, module in ipairs(TO_LOAD) do
  Import.as_globals(Utils.toolbox(module))
end

clear = function()
  os.execute 'clear'
end
tenary = Bool.ternary
fmt = String.fmt

foreach = Map.foreach
map = Map.map

tostring = function(...)
  local ok, res = pcall(String.tostring, ...)

  if ok then
    return res
  end

  return tostring(...)
end

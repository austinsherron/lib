require 'lib.lua.bool'
require 'lib.lua.path'
require 'lib.lua.string'
require 'lib.lua.table'

local stream = require('lib.lua.stream')


local function make_cmd_silent_if_necessary(cmd, silent)
  local silent = silent or false
  return ternary(silent, cmd .. ' 2> /dev/null', cmd)
end


function get_env(var_name)
  return os.getenv(var_name)
end


function run(cmd, silent)
  local cmd = make_cmd_silent_if_necessary(cmd, silent)

  return os.execute(cmd)
end


function mkdir(dirname, ignore_errors)
  local ignore_errors = ignore_errors or false
  local cmd_mod = ternary(ignore_errors, '-p', '')

  return run('mkdir ' .. cmd_mod .. ' ' .. dirname)
end


function get_cmd_output(cmd, silent)
  local cmd = make_cmd_silent_if_necessary(cmd, silent)

  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()

  return result
end


function git_clone(url, path)
  return run(string.format("[ -e '%s' ] || git clone '%s' '%s'", path, url, path))
end


function is_dir(path)
  local f = io.open(path, 'r')

  if (f == nil) then
      return false
  end

  local _, _, code = f:read(1)
  f:close()
  return code == 21
end


function ls(path, basename)
  local path = path or ''
  local basename = basename or false

  local cmd_base = 'ls ' .. path
  local cmd = ternary(basename, cmd_base .. ' | xargs -n 1 basename', cmd_base)

  local out = get_cmd_output(cmd, true)
  return string.split_lines(out)
end


function require_for_init(path, require_base)
  local path = path or '.'
  local lua_files = ls(path .. '/*.lua', true)

  return stream(lua_files)
    :filter(function(i) return i ~= 'init.lua' end)
    :map(trim_extension)
    :map(function(i) return require_base .. '.' .. i end)
    :map(function(i) return require(i) end)
    :filter(function(i) return type(i) == 'table' end)
    :reduce(table.combine, {})
end


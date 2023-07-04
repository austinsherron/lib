require 'lib.lua.bool'
require 'lib.lua.path'
require 'lib.lua.string'
require 'lib.lua.table'

local stream = require('lib.lua.stream')


local function make_cmd_silent_if_necessary(cmd, silent)
  local silent = silent or false
  return ternary(silent, cmd .. ' 2> /dev/null', cmd)
end

local Run = {}

function Run.get_env(var_name)
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


function cp(src, dst, ignore_errors)
  local cmd_flags = ''

  if (is_dir(src)) then
    cmd_flags = '-r '
  end

  return run('cp ' .. cmd_flags .. src .. ' ' .. dst)
end


function get_cmd_output(cmd, silent)
  local cmd = make_cmd_silent_if_necessary(cmd, silent)

  local handle = io.popen(cmd)
  local result = handle:read('*a')
  handle:close()

  return result
end


function git_clone(url, path)
  return run(string.format("[ -e '%s' ] || git clone '%s' '%s'", path, url, path))
end


function git_root()
  return get_cmd_output('git rev-parse --show-toplevel')
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
  return stream(string.split_lines(out))
    :collect(function (arr) return arr end)
end


function require_for_init(dir, require_base)
  if not is_dir(dir) then
    error('dir=' .. dir .. 'must be a directory')
  end

  local result = {}

  for _, file in ipairs(ls(dir, true)) do
    local path = dir ..'/' .. file

    if is_dir(path) and file ~= '' then
      local require_base = require_base .. '.' .. file
      table.insert(result, require_for_init(path, require_base))
    elseif (string.endswith(file, '.lua') and file ~= 'init.lua') then
      local wo_extension = trim_extension(file)
      local to_require = require_base .. '.' .. wo_extension

      table.insert(result, require(to_require))
    end
  end

  return result
end


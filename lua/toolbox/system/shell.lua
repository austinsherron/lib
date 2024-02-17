local Bool = require 'toolbox.core.bool'
local Stream = require 'toolbox.extensions.stream'
local String = require 'toolbox.core.string'

local ternary = Bool.ternary

local function make_cmd_silent_if_necessary(cmd, silent)
  silent = silent or false
  return ternary(silent, cmd .. ' 2> /dev/null', cmd)
end

--- Utilities for executing shell commands.
---
---@class Shell
local Shell = {}

--- Execute a shell command.
---
---@param cmd string: the command to execute
---@param silent boolean|nil: optional, defaults to false; if true, command output will be
--- redirected
---@return boolean|nil: indicates success
---@return integer|nil: the command's return code
function Shell.run(cmd, silent)
  cmd = make_cmd_silent_if_necessary(cmd, silent)

  local suc, _, rc = os.execute(cmd)
  return suc, rc
end

--- Creates a directory.
---
---@param dirname string: the name or relative/absolute path of the directory to create
---@param ignore_errors boolean?: optional, defaults to false; if true, the command won't
--- fail if the dir already exists and it will create parent directories as necessary
---@return boolean|nil: indicates success
---@return integer|nil: the command's return code
function Shell.mkdir(dirname, ignore_errors)
  ignore_errors = ignore_errors or false
  local cmd_mod = ternary(ignore_errors, '-p', '')

  return Shell.run('mkdir ' .. cmd_mod .. ' ' .. dirname)
end

--- Copies the file/dir at path src to path dst.
---
---@param src string: the name or relative/absolute path of the file/dir to copy
---@param dst string: the name or relative/absolute path of the destination of the copy
---@return boolean|nil: indicates success
---@return integer|nil: the command's return code
function Shell.cp(src, dst)
  local cmd_flags = ''

  if Shell.is_dir(src) then
    cmd_flags = '-r '
  end

  return Shell.run('cp ' .. cmd_flags .. src .. ' ' .. dst)
end

--- Gets the string output of the provided command.
---
---@param cmd string: the command for which to get output
---@param silent boolean|nil: optional, defaults to false; if true, command output will be
--- redirected
---@return string: the string output of the provided command
function Shell.get_cmd_output(cmd, silent)
  cmd = make_cmd_silent_if_necessary(cmd, silent)

  local handle = io.popen(cmd)

  if handle == nil then
    return ''
  end

  local result = handle:read '*a'
  handle:close()

  return result
end

--- Returns true if the file at path is a directory, false otherwise.
---
--- TODO: update callers of this function to use File.is_dir.
---
---@deprecated
---@param path string: the path to check
---@return boolean: true if the file at path is a directory, false otherwise
function Shell.is_dir(path)
  local f = io.open(path, 'r')

  if f == nil then
    return false
  end

  local _, _, code = f:read(1)
  f:close()
  return code == 21
end

--- Run "ls" on the provided path and capture its output.
---
---@param path string: the path on which to run ls
---@param basename boolean|nil: optional, defaults to false; if true, the results will only
--- include basenames as opposed to full paths
---@return table: an array-like table that contains the output of ls
function Shell.ls(path, basename)
  path = path or ''
  basename = basename or false

  local cmd_base = 'ls ' .. path
  local cmd = ternary(basename, cmd_base .. ' | xargs -n 1 basename', cmd_base)

  local out = Shell.get_cmd_output(cmd, true)
  return Stream.new(String.split_lines(out) or {}):collect(function(arr)
    return arr
  end)
end

--- Adds executable file permissions to the file at path.
---
---@param path string: the path to the file to make executable
---@return boolean|nil: indicates success
---@return integer|nil: the command's return code
function Shell.chmod_x(path)
  return Shell.run('chmod +x ' .. path)
end

---@return string: the current "os type", i.e.: linux, etc
function Shell.ostype()
  local uname = Shell.get_cmd_output 'uname -a'
  return String.lower(String.trim_after(uname, ' '))
end

return Shell

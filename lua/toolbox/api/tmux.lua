local Array = require 'toolbox.core.array'
local Num = require 'toolbox.core.num'
local Shell = require 'toolbox.system.shell'
local String = require 'toolbox.core.string'

local Dimensions = require('toolbox.types.plane').Dimensions

local fmt = String.fmt

--- Simple tmux lua api.
---
---@class Tmux
local Tmux = {}

local TMUX_CMD = 'tmux %s'

--- Executes the provided tmux command.
---
---@param cmd string: a tmux command (w/out a "tmux" prefix)
---@param ... any|nil: values to format into the command
---@return string: the output of the tmux command, if any
function Tmux.exec(cmd, ...)
  cmd = fmt(TMUX_CMD, cmd)
  return Shell.get_cmd_output(fmt(cmd, ...))
end

local WINDOW_DIMENSIONS_CMD = 'display-message%s -p "#{window_width}x#{window_height}"'

--- Gets the dimensions of the provided tmux window, or the current window if none is
--- provided.
---
---@param window string|integer|nil: the name or id of a tmux window
---@return Dimensions: the dimensions of the provided window, or the
--- current window if none was provided
function Tmux.window_dimensions(window)
  window = window ~= nil and ' -t ' .. window or ''
  local dim = String.trim(Tmux.exec(WINDOW_DIMENSIONS_CMD, window), '\n')
  local split = String.split(dim, 'x')

  if Array.len(split) ~= 2 then
    error(fmt('Tmux.window_dimensions: dimensions in unexpected format: %s', dim))
  end

  return Dimensions(Num.as(split[1]), Num.as(split[2]))
end

return Tmux

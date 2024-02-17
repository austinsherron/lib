local Num = require 'toolbox.core.num'
local Shell = require 'toolbox.system.shell'
local String = require 'toolbox.core.string'
local Table = require 'toolbox.core.table'

local ternary = require('toolbox.core.bool').ternary
local map = require('toolbox.utils.map').map

local fmt = String.fmt

--- Contains utilities for interacting w/ processes.
---
---@class Proc
local Proc = {}

--- Parameterizes Proc.find.
---
---@class ProcFindOpts
---@field ignore_case boolean: optional, defaults to true; if true, pattern matching is
--- case insensitive
---@field arg_match boolean: optional, defaults to false; if true, pattern matches against
--- process arg list in addition to name
---@field include_ancestors boolean: optional, defaults to true; if true, pattern matches
--- against process ancestors

---@type ProcFindOpts
local DEFAULT_FIND_OPTS = {
  ignore_case = true,
  arg_match = false,
  include_ancestors = true,
}

local FIND_OPT_FLAGS = {
  ignore_case = 'i',
  arg_match = 'f',
  include_ancestors = 'a',
}

local function process_find_opts(opts)
  local flags = ''

  for key, val in pairs(opts) do
    if val then
      flags = flags .. FIND_OPT_FLAGS[key]
    end
  end

  return ternary(flags == '', '', ' -' .. flags)
end

--- Search for processes using the provided pattern.
---
---@param pattern string: the process search pattern
---@param opts ProcFindOpts|nil: parameterizes search
---@return integer[]: an array of process ids that matched the search pattern; may be
--- empty
function Proc.find(pattern, opts)
  opts = Table.combine(DEFAULT_FIND_OPTS, opts or {})

  local flags = process_find_opts(opts)
  local cmd = fmt('pgrep%s %s', flags, pattern)

  local out = String.split_lines(Shell.get_cmd_output(cmd, true)) or {}
  return map(out, Num.as)
end

return Proc

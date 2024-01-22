local Grammar = require 'toolbox.utils.grammar'
local String = require 'toolbox.core.string'

--- Contains utilities for validating arbitrary data, params, etc.
---
---@class Validate
local Validate = {}

local function handle_required_string(req, to_validate, missing)
  if to_validate[req] == nil then
    table.insert(missing, req)
  end

  return missing
end

local function handle_required_table(req, to_validate, missing)
  local sub_missing = Validate.missing_required(req, to_validate)

  if #sub_missing == #req then
    table.insert(missing, sub_missing)
  end

  return missing
end

function Validate.missing_required(required, to_validate)
  local missing = {}

  for _, req in ipairs(required) do
    if type(req) == 'string' then
      missing = handle_required_string(req, to_validate, missing)
    elseif type(req) == 'table' then
      missing = handle_required_table(req, to_validate, missing)
    else
      error('unrecognized type=' .. type(req) .. ' to Validate.missing_required')
    end
  end

  return missing
end

function Validate.required(required, to_validate, op)
  local missing = Validate.missing_required(required, to_validate)

  if #missing == 0 then
    return
  end

  local missing_str = String.rjoin(missing, { ', ', ' or ' })
  local is_are = Grammar.to_be(missing)

  error(missing_str .. ' ' .. is_are .. ' required to ' .. op)
end

return Validate

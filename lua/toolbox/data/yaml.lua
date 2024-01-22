local yaml = require 'yaml'

--- Contains utility functions for interacting w/ and manipulating yaml.
---
---@class Yaml
local Yaml = {}

--- Creates a lua runtime representation of the yaml in the provided file.
---
---@param path string: a path to a yaml file
---@return table: a lua table representation of the provided yaml string
function Yaml.from_file(path)
  return yaml.loadpath(path)
end

--- Creates a yaml string from the provided lua table.
---
---@param tbl table: the table to convert to a yaml string
---@return string: a yaml string from the provided lua table
function Yaml.encode(tbl)
  return yaml.dump(tbl)
end

return Yaml

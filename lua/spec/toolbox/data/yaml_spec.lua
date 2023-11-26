local Yaml  = require 'toolbox.data.yaml'
local Utils = require 'toolbox.test.utils'

local assert = require 'luassert.assert'


local YAML_PATH = Utils.asset_path('test.yaml')

describe('Yaml', function()
  describe('.from_file(path)', function()
    it('should load a lua table from the provided yaml file', function()
      local yaml = Yaml.from_file(YAML_PATH)
      local expected = {
        list      = { 'one', 'two', 'three', 'four' },
        string    = 'a simple string',
        number    = 24,
        boolean_t = true,
        boolean_f = false,
        map       = {a = 1, b = 2, c = 3 },
      }

      assert.same(yaml, expected)
    end)
  end)

  describe('.encode(tbl)', function()
    it('should encode a tabl to a yaml string', function()
      local tbl = {
        { string = 'a different string' },
        { number = -1 },
        { list   = { 5, 3, 1 }},
        { map    = { z = 26 }},
      }
      local str =
[[---
- string: a different string
- number: -1
- list:
  - 5
  - 3
  - 1
- map:
    z: 26
]]

      assert.equals(Yaml.encode(tbl), str)
    end)
  end)
end)


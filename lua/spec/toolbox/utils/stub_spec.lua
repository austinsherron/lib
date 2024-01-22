local Stub = require 'toolbox.utils.stub'

local assert = require 'luassert.assert'

describe('Stub', function()
  describe(':__index()', function()
    it('should permit any method call w/o error', function()
      local stub = Stub.new()
      local stub_mt = getmetatable(stub)

      assert.Nil(Stub['func'])
      assert.Nil(stub_mt['func'])

      assert.Not.has_error(function()
        ---@diagnostic disable-next-line: undefined-field
        stub:func()
      end)
    end)
  end)
end)

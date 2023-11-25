local DefaultDict = require 'toolbox.extensions.defaultdict'

local assert = require 'luassert.assert'


describe('DefaultDict', function()
  describe('.__index(k)', function()
    it('returns a values that exist in the dict', function()
      local defaulter = spy.new(function(_) return 0 end)
      local dd = DefaultDict.new(defaulter)

      dd.a = 1
      dd.b = 2

      assert.equals(dd.a, 1)
      assert.equals(dd.b, 2)
      assert.spy(defaulter).Not.was_called()
    end)
    it('defaults and returns values that do not exist in the dict', function()
      local defaulter = spy.new(function(_) return 0 end)
      local dd = DefaultDict.new(defaulter)

      dd.a = 1
      dd.b = 2
      dd.c = dd.a + dd.b + dd.d

      assert.equals(dd.a, 1)
      assert.equals(dd.b, 2)
      assert.equals(dd.c, 3)
      assert.equals(dd.d, 0)
      assert.spy(defaulter).was_called(1)
    end)
  end)
end)


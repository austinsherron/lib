local Callable = require 'toolbox.functional.callable'

local assert = require 'luassert.assert'

require 'toolbox.test.extensions'


describe('Callable', function()
  describe('.new(val)', function()
    it('should work with a non-callable value', function()
      local callable = Callable.new(1)
      assert.equals(callable(), 1)

      callable = Callable.new('a')
      assert.equals(callable(), 'a')

      callable = Callable.new(true)
      assert.True(callable())

      callable = Callable.new(false)
      assert.False(callable())

      callable = Callable.new({ a = 2, c = 1 })
      assert.same(callable(), { a = 2, c = 1 })
    end)
    it('should work with a callable value', function()
      assert.equals(Callable.new(1)(), 1)
      assert.equals(Callable.new('a')(), 'a')
      assert.equals(Callable.new(true)(), true)
      assert.equals(Callable.new(false)(), false)

      local callable = Callable.new({ a = 2, c = 1 })
      assert.same(callable(), { a = 2, c = 1 })
    end)
  end)

  describe('.empty()', function()
    it('should return nil', function()
      local callable = Callable.empty()

      assert.Nil(callable())
    end)
  end)
end)


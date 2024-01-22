local Lazy = require 'toolbox.utils.lazy'

local assert = require 'luassert.assert'

describe('Lazy', function()
  describe('.value(loader)', function()
    local val = 20

    local loader
    local lazy

    it('should not call loader until the value is needed', function()
      loader = spy.new(function()
        return val
      end)
      Lazy.value(loader)

      assert.spy(loader).Not.called()
    end)
    it('should load and return when needed', function()
      loader = spy.new(function()
        return val
      end)
      lazy = Lazy.value(loader)

      assert.equals(lazy:get(), val)
      assert.Nil(lazy:get_error())
      assert.spy(loader).called()
    end)
    it('should allow direct indexing of the lazy-loaded value ', function()
      loader = spy.new(function()
        return { key = val }
      end)
      lazy = Lazy.value(loader)

      ---@diagnostic disable-next-line: undefined-field
      assert.equals(lazy.key, 20)
      assert.Nil(lazy:get_error())
      assert.spy(loader).called()
    end)
    it('should return the lazy-loaded value when called', function()
      loader = spy.new(function()
        return val
      end)
      lazy = Lazy.value(loader)

      assert.equals(lazy(), val)
      assert.Nil(lazy:get_error())
      assert.spy(loader).called()
    end)
    it('should support concatenation', function()
      loader = spy.new(function()
        return 'hello'
      end)
      lazy = Lazy.value(loader)

      assert.equals(lazy .. ' there friend', 'hello there friend')
      assert.Nil(lazy:get_error())
      assert.spy(loader).called()
    end)
  end)
end)

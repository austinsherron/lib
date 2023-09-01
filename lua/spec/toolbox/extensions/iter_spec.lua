---@diagnostic disable: invisible

local Iter = require 'toolbox.extensions.iter'

describe('Iter', function()
  describe('.iter(len)', function()
    it('should produce a function that can be called "len" times before returning "finishing"', function()
      local nxt = Iter.iter(4)

      assert.Nil(nxt())
      assert.equals(nxt(), 1)
      assert.equals(nxt(), 2)
      assert.equals(nxt(), 3)
      assert.equals(nxt(), -1)
    end)
  end)

  describe('.array(arr)', function()
    it('should return successive values of arr', function()
      local nxt = Iter.array({ 1, 2, 3, 4 })

      assert.equals(nxt(), 1)
      assert.equals(nxt(), 2)
      assert.equals(nxt(), 3)
      assert.equals(nxt(), 4)
      assert.Nil(nxt())
    end)
    it('should return the single value of a len 1 array', function()
      local nxt = Iter.array({ 1 })

      assert.equals(nxt(), 1)
      assert.Nil(nxt())
    end)
    it('should work w/ empty arrays', function()
      local nxt = Iter.array({})

      assert.Nil(nxt())
    end)
  end)
end)


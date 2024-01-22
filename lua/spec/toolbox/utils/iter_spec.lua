---@diagnostic disable: invisible

local Iter = require 'toolbox.utils.iter'

local assert = require 'luassert.assert'

describe('Iter', function()
  describe('.array(arr)', function()
    it('should return successive values of arr', function()
      local nxt = Iter.array({ 'a', 'b', 'c', 'd' })

      assert.same({ nxt() }, { 1, 'a' })
      assert.same({ nxt() }, { 2, 'b' })
      assert.same({ nxt() }, { 3, 'c' })
      assert.same({ nxt() }, { 4, 'd' })
      assert.Nil(nxt())
    end)
    it('should return the single value of an array w/ one element', function()
      local nxt = Iter.array({ 'a' })

      assert.same({ nxt() }, { 1, 'a' })
      assert.Nil(nxt())
    end)
    it('should work w/ empty arrays', function()
      local nxt = Iter.array({})

      assert.Nil(nxt())
    end)
  end)

  describe('.dict(dict)', function()
    it('should return successive key/value pairs of dict', function()
      local orig = { a = 1, b = 2, c = 3, d = 4 }
      local actual = {}

      local nxt = Iter.dict(orig)

      for _ = 1, 4 do
        local k, v = nxt()
        actual[k] = v
      end

      assert.same(actual, orig)
      assert.Nil(nxt())
    end)
    it('should return the single key/value pair of a dict w/ one pair', function()
      local nxt = Iter.dict({ z = 26 })
      local k, v = nxt()

      assert.equals(k, 'z')
      assert.equals(v, 26)
      assert.Nil(nxt())
    end)
    it('should work w/ empty dicts', function()
      local nxt = Iter.dict({})

      assert.Nil(nxt())
    end)
  end)
end)

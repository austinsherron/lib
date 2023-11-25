local Set    = require 'toolbox.extensions.set'
local Stream = require 'toolbox.extensions.stream'

local assert = require 'luassert.assert'

require 'toolbox.test.extensions'


describe('Stream', function()
  describe(':filter(predicate)', function()
    it('should filter some elements', function()
      local input = { 'a', 'b', 'c', 'd' }
      local fltrd = Stream(input)
        :filter(function(e) return e == 'a' or e == 'c' end)
        :collect()

      assert.array(fltrd).eq({ 'a', 'c' })
      assert.array(input).eq({ 'a', 'b', 'c', 'd' })
    end)
    it('should filter no elements', function()
      local input = { 'a', 'b', 'c', 'd' }
      local fltrd = Stream(input)
        :filter(function(e) return e ~= 'e' end)
        :collect()

      assert.array(fltrd).eq({ 'a', 'b', 'c', 'd' })
      assert.array(input).eq({ 'a', 'b', 'c', 'd' })
      assert.array(input).Not.is(fltrd)
    end)
    it('should filter all elements', function()
      local input = { 'a', 'b', 'c', 'd' }
      local fltrd = Stream(input)
        :filter(function(e) return e < 'a' end)
        :collect()

      assert.array(fltrd).empty()
      assert.array(input).eq({ 'a', 'b', 'c', 'd' })
    end)
  end)

  describe(':map(mapper)', function()
    it('should map elements', function()
      local input = { 3, 2, 1, 0, -1 }
      local mpped = Stream(input)
        :map(function(e) return e * 3 end)
        :collect()

      assert.array(mpped).eq({ 9, 6, 3, 0, -3 })
      assert.array(input).eq({ 3, 2, 1, 0, -1 })
    end)
  end)

  describe(':peek(func)', function()
    it('should call func on elements but return them unchanged', function()
      local func = spy.new(function(e) return 3 * e end)
      local arr = { 1, 2, 3 }

      local peekd = Stream(arr)
        :peek(func)
        :collect()

      assert.array(peekd).eq(arr)
      assert.array(peekd).Not.is(arr)

      assert.spy(func).was_called_with(1)
      assert.spy(func).was_called_with(2)
      assert.spy(func).was_called_with(3)
    end)
  end)

  describe(':foreach(func)', function()
    it('should call func on elements but return nothing', function()
      local func = spy.new(function(e) return 3 * e end)
      local arr = { 3, 2, 1 }

      local freachd = Stream(arr):foreach(func)

      assert.Nil(freachd)

      assert.spy(func).was_called_with(3, 1)
      assert.spy(func).was_called_with(2, 2)
      assert.spy(func).was_called_with(1, 3)
    end)
  end)

  describe(':reduce(reducer, init)', function()
    it('should combine all elements to a single value', function()
      local arr = { 3, 2, 1 }

      local rducd = Stream(arr)
        :reduce(function(l, r) r = r or 0; return l + r end)

      assert.equals(rducd, 6)
    end)
    it('should combine all elements and init to a single value', function()
      local arr = { 3, 2, 1 }

      local rducd = Stream(arr)
        :reduce(function(l, r) return l + r end, 3)

      assert.equals(rducd, 9)
    end)
  end)

  describe(':collect(collector)', function()
    it('should transform the output of the stream using the collector function', function()
      local cllctd = Stream({ 1, 2, 3 })
        :collect(function(c) return Set.new(c) end)

      assert.set(cllctd).eq(Set.of(1, 2, 3))
    end)
    it('should transform the output of the stream using the default collector function', function()
      local input = { 1, 2, 3 }
      local cllctd = Stream(input):collect()

      assert.array(cllctd).eq(input)
      -- TODO: it would be better if this were a different array
      assert.array(cllctd).is(input)
    end)
  end)

  describe(':get()', function()
    it('should get the internal array from the stream', function()
      local strm = Stream({ 1, 2, 3 })

      assert.array(strm:get()).eq({ 1, 2, 3 })

      strm = strm:map(function(i) return i * 2 end)

      assert.array(strm:get()).eq({ 2, 4, 6 })

      strm = strm:filter(function(i) return i > 2 end)

      assert.array(strm:get()).eq({ 4, 6 })
      assert.set(strm:collect(function(c)
        return Set.new(c)
      end)).eq(Set.of(4, 6))
    end)
  end)

  describe('chaining', function()
    it('should support method chaining', function()
      local out = Stream({ 1, 2, 3 })
        :map(function(i) return i * 2 end)
        :filter(function(i) return i > 2 end)
        :collect(function(c) return Set.new(c) end)

      assert.set(out).eq(Set.of(4, 6))
    end)
  end)
end)

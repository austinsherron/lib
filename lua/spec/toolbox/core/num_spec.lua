local Num = require 'toolbox.core.num'

local assert = require 'luassert.assert'

describe('Num', function()
  describe('.is(x)', function()
    it('should return true if x is a number', function()
      assert.True(Num.is(1))
      assert.True(Num.is(0))
      assert.True(Num.is(-3))
      assert.True(Num.is(82.421))
      assert.True(Num.is(-3.145))
      assert.True(Num.is(1.71e-5))
      assert.True(Num.is(3.51E-7))
      assert.True(Num.is(0x1F4))
    end)
    it('should return false if x is not a number', function()
      assert.False(Num.is '1')
      assert.False(Num.is 'a number')
      assert.False(Num.is(true))
      assert.False(Num.is(false))
      assert.False(Num.is({ 1, 2, 3 }))
      assert.False(Num.is({ a = 1, b = 2, c = 3 }))
      assert.False(Num.is(nil))
    end)
  end)

  describe('.isint(x)', function()
    it('should return true if x is an int', function()
      assert.True(Num.isint(1000))
      assert.True(Num.isint(1))
      assert.True(Num.isint(0))
      assert.True(Num.isint(-3))
      assert.True(Num.isint(-823))
      assert.True(Num.isint(0x1F4))
      assert.True(Num.isint(1.71e+2))
    end)
    it('should return false if x is not an int', function()
      assert.False(Num.isint(82.421))
      assert.False(Num.isint(-3.145))
      assert.False(Num.isint(1.71e-5))
      assert.False(Num.isint(3.51E-7))
      assert.False(Num.isint(0x1F5.E))
      assert.False(Num.isint '1')
      assert.False(Num.isint 'a number')
      assert.False(Num.isint(true))
      assert.False(Num.isint(false))
      assert.False(Num.isint({ 1, 2, 3 }))
      assert.False(Num.isint({ a = 1, b = 2, c = 3 }))
      assert.False(Num.isint(nil))
    end)
  end)

  describe('.isstrnum(str)', function()
    it('should return true if str is a string representation of a number', function()
      assert.True(Num.isstrnum '1')
      assert.True(Num.isstrnum '0')
      assert.True(Num.isstrnum '-3')
      assert.True(Num.isstrnum '82.421')
      assert.True(Num.isstrnum '-3.145')
      assert.True(Num.isstrnum '1.71e-5')
      assert.True(Num.isstrnum '3.51E-7')
      assert.True(Num.isstrnum '0x1F4')
    end)
    it('should return false if str is not a string representation of a number', function()
      assert.False(Num.isstrnum 'a number')
      assert.False(Num.isstrnum 'true')
      assert.False(Num.isstrnum 'false')
      assert.False(Num.isstrnum '{ 1, 2, 3 }')
      assert.False(Num.isstrnum '{ a = 1, b = 2, c = 3 }')
      assert.False(Num.isstrnum 'nil')
    end)
  end)

  describe('.isstrint(str)', function()
    it('should return true if str is a string representation of an int', function()
      assert.True(Num.isstrint '1000')
      assert.True(Num.isstrint '1')
      assert.True(Num.isstrint '0')
      assert.True(Num.isstrint '-3')
      assert.True(Num.isstrint '-823')
      assert.True(Num.isstrint '0x1F4')
      assert.True(Num.isstrint '1.71e+2')
    end)
    it('should return false if str is not a string representation of an int', function()
      assert.False(Num.isstrint '82.421')
      assert.False(Num.isstrint '-3.145')
      assert.False(Num.isstrint '1.71e-5')
      assert.False(Num.isstrint '3.51E-7')
      assert.False(Num.isstrint '0x1F5.E')
      assert.False(Num.isstrint 'a number')
      assert.False(Num.isstrint 'true')
      assert.False(Num.isstrint 'false')
      assert.False(Num.isstrint '{ 1, 2, 3 }')
      assert.False(Num.isstrint '{ a = 1, b = 2, c = 3 }')
      assert.False(Num.isstrint 'nil')
    end)
  end)

  describe('.bounded(n, l, u, li, ui)', function()
    describe('.ibounded(n, l, u) (inclusive bounds)', function()
      it('should return false if n < l', function()
        assert.False(Num.bounded(2, 5, 10, true, true))
        assert.False(Num.ibounded(2, 5, 10))
      end)
      it('should return true if n == l', function()
        assert.True(Num.bounded(5, 5, 10, true, true))
        assert.True(Num.ibounded(5, 5, 10))
      end)
      it('should return true if l < n < u', function()
        assert.True(Num.bounded(7, 5, 10, true, true))
        assert.True(Num.ibounded(7, 5, 10))
      end)
      it('should return true if n == u', function()
        assert.True(Num.bounded(10, 5, 10, true, true))
        assert.True(Num.ibounded(10, 5, 10))
      end)
      it('should return false if n > u', function()
        assert.False(Num.bounded(12, 5, 10, true, true))
        assert.False(Num.ibounded(12, 5, 10))
      end)
    end)
    describe('inclusive lower (exclusive upper) bound', function()
      it('should return false if n < l', function()
        assert.False(Num.bounded(2, 5, 10, true, false))
      end)
      it('should return true if n == l', function()
        assert.True(Num.bounded(5, 5, 10, true, false))
      end)
      it('should return true if l < n < u', function()
        assert.True(Num.bounded(7, 5, 10, true, false))
      end)
      it('should return false if n == u', function()
        assert.False(Num.bounded(10, 5, 10, true, false))
      end)
      it('should return false if n > u', function()
        assert.False(Num.bounded(12, 5, 10, true, false))
      end)
    end)
    describe('inclusive upper (exclusive lower) bound', function()
      it('should return false if n < l', function()
        assert.False(Num.bounded(2, 5, 10, false, true))
      end)
      it('should return false if n == l', function()
        assert.False(Num.bounded(5, 5, 10, false, true))
      end)
      it('should return true if l < n < u', function()
        assert.True(Num.bounded(7, 5, 10, false, true))
      end)
      it('should return true if n == u', function()
        assert.True(Num.bounded(10, 5, 10, false, true))
      end)
      it('should return false if n > u', function()
        assert.False(Num.bounded(12, 5, 10, false, true))
      end)
    end)
    describe('.ebounded(n, l, u) (exclusive bounds)', function()
      it('should return false if n < l', function()
        assert.False(Num.bounded(2, 5, 10, false, false))
        assert.False(Num.ebounded(2, 5, 10))
      end)
      it('should return false if n == l', function()
        assert.False(Num.bounded(5, 5, 10, false, false))
        assert.False(Num.ebounded(5, 5, 10))
      end)
      it('should return true if l < n < u', function()
        assert.True(Num.bounded(7, 5, 10, false, false))
        assert.True(Num.ebounded(7, 5, 10))
      end)
      it('should return false if n == u', function()
        assert.False(Num.bounded(10, 5, 10, false, false))
        assert.False(Num.ebounded(10, 5, 10))
      end)
      it('should return false if n > u', function()
        assert.False(Num.bounded(12, 5, 10, false, false))
        assert.False(Num.ebounded(12, 5, 10))
      end)
    end)
  end)

  describe('.bounds(n, min, max)', function()
    local min, max = 0, 5

    it('should return n if min < n < max', function()
      local result = Num.bounds(3, min, max)
      assert.equals(result, 3)
    end)
    it('should return n/min if min <= n < max', function()
      local result = Num.bounds(min, min, max)
      assert.equals(result, min)
    end)
    it('should return n/max if min < n <= max', function()
      local result = Num.bounds(max, min, max)
      assert.equals(result, max)
    end)
    it('should return min if n < min', function()
      local result = Num.bounds(-2, min, max)
      assert.equals(result, min)
    end)
    it('should return max if n > max', function()
      local result = Num.bounds(9, min, max)
      assert.equals(result, max)
    end)
    it('should return n i min == n == max', function()
      local result = Num.bounds(max, max, max)
      assert.equals(result, max)
    end)
    it('should raise and error if min > max', function()
      assert.has.errors(function()
        Num.bounds(3, max, min)
      end)
    end)
  end)
end)
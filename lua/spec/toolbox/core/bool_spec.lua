local Bool = require 'toolbox.core.bool'


describe('Bool', function()
  describe('.ternary(cond, T, F)', function()
    local true_val = "Hey, it's a truthy value!"
    local false_val = "Ugh, it's another falsy value..."

    it('should return the first value if the condition is truthy', function ()
      local result = Bool.ternary('a test' == 'a test', true_val, false_val)
      assert.equal(result, true_val)
    end)
    it('should return the second value if the condition is falsy', function ()
      local result = Bool.ternary('a test' == 'b test', true_val, false_val)
      assert.equal(result, false_val)
    end)
    it("should return nil if the condition is falsy and there's no second value", function ()
      local result = Bool.ternary('b test' == 'c test', true_val)
      assert.Nil(result)
    end)

    local truthy_fn_val = '...still truthy 😄'
    local falsy_fn_val = 'Always falsy. 🦹'

    local true_fn = function () return truthy_fn_val end
    local false_fn = function () return falsy_fn_val end

    it("should return the first function's value if the condition is truthy" , function ()
      local result = Bool.ternary('d test' == 'd test', true_fn, false_fn)
      assert.equal(result, truthy_fn_val)
    end)
    it("should return the second function's value if the condition is falsy" , function ()
      local result = Bool.ternary('d test' == 'dd test', true_fn, false_fn)
      assert.equal(result, falsy_fn_val)
    end)
    it("should return nil if the condition is falsy and there's no second function" , function ()
      local result = Bool.ternary('d test' == 'dd test', true_fn)
      assert.Nil(result)
    end)
  end)

  describe('.as_bool(value)', function ()
    it('should return true if the value is "true"', function ()
      assert.True(Bool.as_bool('true'))
    end)
    it('should return false if the value is "True"', function ()
      assert.False(Bool.as_bool('True'))
    end)
    it('should return false if the value is anything other than "true"', function ()
      assert.False(Bool.as_bool('another_value'))
    end)
    it('should return false if the value is "" (empty string)', function ()
      assert.False(Bool.as_bool(''))
    end)
    it('should return false if the value is nil', function ()
      assert.False(Bool.as_bool(nil))
    end)
  end)

  describe('.or_default(bool, default)', function ()
    it("should return the value if it's not nil", function ()
      assert.True(Bool.or_default(true, false))
    end)
    it('should return the default if the value is nil', function ()
      assert.False(Bool.or_default(nil, false))
    end)
  end)
end)


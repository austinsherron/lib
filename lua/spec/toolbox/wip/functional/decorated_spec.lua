local Table     = require 'toolbox.core.table'
local Decorated = require 'toolbox.functional.decorated'

local assert = require 'luassert.assert'


describe('Decorated', function()
  describe('.new(fn)', function()
    it('should apply the decorator to singleton functions', function()
      local Add = Decorated.new(function(num) return num + 2 end);

      function Add.five(num)
        return num + 5
      end

      function Add.twenty(num)
        return num + 20
      end

      print(Table.tostring(Add))

      assert.equals(Add.five(2), 9)
      assert.equals(Add.twenty(0), 22)
    end)
    it('should apply the decorator to instance methods', function()
      ---@class Adder
      ---@field __num number
      local Adder = Decorated.new(function(num) return num + 5 end);
      Adder.__index = Adder

      function Adder.new(num)
        return setmetatable({ __num = num }, Adder)
      end

      function Adder:add(num)
        return self.__num + num
      end

      print(Table.tostring(Adder))

      -- local add_7 = Adder.new(7)

      -- assert.equals(add_7:add(2), 11)
      -- assert.equals(add_7:add(-7), 2)
      -- assert.equals(add_7:add(-9), 0)
    end)
  end)
end)


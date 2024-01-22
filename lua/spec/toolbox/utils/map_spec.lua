local Array = require 'toolbox.core.array'
local Map = require 'toolbox.utils.map'
local String = require 'toolbox.core.string'

local assert = require 'luassert.assert'

describe('Map', function()
  describe('.filter(arr, filter)', function()
    it('should filter out falsy results and include truthy ones', function()
      local seq = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
      local is_even = function(x)
        return x % 2 == 0
      end
      local even_nos = Map.filter(seq, is_even)

      assert.True(Array.equals(even_nos, { 2, 4, 6, 8, 10 }))
    end)
    it('should handle correctly a filter that never applies', function()
      local seq = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
      local gt_zero = function(x)
        return x > 0
      end
      local gt_zero_nos = Map.filter(seq, gt_zero)

      assert.True(Array.equals(gt_zero_nos, seq))
    end)
    it('should handle correctly a filter that produces an empty array', function()
      local seq = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
      local gt_ten = function(x)
        return x > 10
      end
      local gt_ten_nos = Map.filter(seq, gt_ten)

      assert.True(Array.equals(gt_ten_nos, {}))
    end)
  end)

  describe('.map(arr, mapper)', function()
    it('should apply the mapper to every value in arr', function()
      local seq = { 1, 2, 3, 4, 5 }
      local x5 = function(x)
        return x * 5
      end
      local x5ed = Map.map(seq, x5)

      assert.True(Array.equals(x5ed, { 5, 10, 15, 20, 25 }))
    end)
    it('should handle correctly a mapper that changes object types', function()
      local seq = { 1, 2, 3, 4, 5 }
      local to_str = function(x)
        return String.tostring(x)
      end
      local str_seq = Map.map(seq, to_str)

      assert.True(Array.equals(str_seq, { '1', '2', '3', '4', '5' }))
    end)
  end)

  describe('.reduce(arr, reducer, init)', function()
    it('', function() end)
  end)
end)

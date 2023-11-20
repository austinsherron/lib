local Dict = require 'toolbox.core.dict'


describe('Dict', function()
  describe('.is_empty(dict)', function()
    it('should return true when the dict is empty', function()
      assert.True(Dict.is_empty({}))
    end)
    it('should return false when the dict is not empty', function()
      assert.False(Dict.is_empty({ k = 'v' }))
    end)
    it('should not consider nil a value', function()
      assert.True(Dict.is_empty({ k = nil }))
    end)
  end)

  describe('.nil_or_empty(dict)', function()
    it('should return true if dict is nil', function()
      assert.True(Dict.nil_or_empty(nil))
    end)
    it('should return true if dict is empty', function()
      assert.True(Dict.nil_or_empty({}))
    end)
    it('should return false if dict is neither nil nor empty', function()
      assert.False(Dict.nil_or_empty({ a = 'val' }))
    end)
  end)

  describe('.not_nil_or_empty(dict)', function()
    it('should return false if dict is nil', function()
      assert.False(Dict.not_nil_or_empty(nil))
    end)
    it('should return false if dict is empty', function()
      assert.False(Dict.not_nil_or_empty({}))
    end)
    it('should return true if dict is neither nil nor empty', function()
      assert.True(Dict.not_nil_or_empty({ a = 'val' }))
    end)
  end)

  describe('.equals(l, r)', function()
    it('should return true if l and r reference the same table', function()
      local l = { a = 1, b = 2 }
      local r = l

      assert.True(Dict.equals(l, r))
    end)
    it('should return true if l and r are shallow tables w/ the same values', function()
      local l = { a = 1, b = 2 }
      local r = { a = 1, b = 2 }

      assert.True(Dict.equals(l, r))
    end)
    it('should return true if l and r are nested tables w/ the same values', function()
      local l = { a = 1, b = 2, c = { d = 3, f = 4 }}
      local r = { a = 1, b = 2, c = { d = 3, f = 4 }}

      assert.True(Dict.equals(l, r))
    end)
    it('should return true if l and r are deeply nested tables w/ the same values', function()
      local l = { a = 1, b = 2, c = { d = { g = 5, h = 6 }, f = 4 }}
      local r = { a = 1, b = 2, c = { d = { g = 5, h = 6 }, f = 4 }}

      assert.True(Dict.equals(l, r))
    end)
    it("should return false if l has a key/value pair that r doesn't have", function()
      local l = { a = 1, b = 2, c = 3 }
      local r = { a = 1, b = 2 }

      assert.False(Dict.equals(l, r))
    end)
    it("should return false if r has a key/value pair that l doesn't have", function()
      local l = { a = 1, b = 2 }
      local r = { a = 1, b = 2, c = 3 }

      assert.False(Dict.equals(l, r))
    end)
    it('should return false if a shared key has a different value in l and r', function()
      local l = { a = 1, b = 2, c = 3 }
      local r = { a = 1, b = 2, c = 4 }

      assert.False(Dict.equals(l, r))
    end)
    it('should return false w/ multiple of the previous "falsy" test conditions', function()
      local l = { a = 1, b = 2, c = 3, d = 5}
      local r = { a = 1, b = 2, c = 4, e = 6 }

      assert.False(Dict.equals(l, r))
    end)
    it("should return false if a sub-table of l has a key/value pair that r doesn't have", function()
      local l = { a = 1, b = 2, c = { d = 3, f = 4, g = 5 }}
      local r = { a = 1, b = 2, c = { d = 3, f = 4 }}

      assert.False(Dict.equals(l, r))
    end)
    it("should return false if a sub-table of r has a key/value pair that l doesn't have", function()
      local l = { a = 1, b = 2, c = { d = 3, f = 4 }}
      local r = { a = 1, b = 2, c = { d = 3, f = 4, g = 5 }}

      assert.False(Dict.equals(l, r))
    end)
    it('should return false if a shared sub-table key has a different value in l and r', function()
      local l = { a = 1, b = 2, c = { d = 3, f = 4, g = 6 }}
      local r = { a = 1, b = 2, c = { d = 3, f = 4, g = 5 }}

      assert.False(Dict.equals(l, r))
    end)
    it('should return false w/ multiple of the previous "falsy" test conditions in a sub-table', function()
      local l = { a = 1, b = 2, c = { d = 3, f = 4, g = 6, h = 7 }}
      local r = { a = 1, b = 2, c = { d = 3, f = 4, g = 5, i = 7 }}

      assert.False(Dict.equals(l, r))
    end)
    it("should return false if a sub-sub-table of l has a key/value pair that r doesn't have", function()
      local l = { a = 1, b = 2, c = { d = { g = 5, h = 6, i = 7 }, f = 4 }}
      local r = { a = 1, b = 2, c = { d = { g = 5, h = 6 }, f = 4 }}

      assert.False(Dict.equals(l, r))
    end)
    it("should return false if a sub-sub-table of r has a key/value pair that l doesn't have", function()
      local l = { a = 1, b = 2, c = { d = { g = 5, h = 6 }, f = 4 }}
      local r = { a = 1, b = 2, c = { d = { g = 5, h = 6, i = 7 }, f = 4 }}

      assert.False(Dict.equals(l, r))
    end)
    it('should return false if a shared sub-sub-table key has a different value in l and r', function()
      local l = { a = 1, b = 2, c = { d = { g = 5, h = 6, i = 9 }, f = 4 }}
      local r = { a = 1, b = 2, c = { d = { g = 5, h = 6, i = 7 }, f = 4 }}

      assert.False(Dict.equals(l, r))
    end)
    it('should return false w/ multiple of the previous "falsy" test conditions in a sub-sub-table', function()
      local l = { a = 1, b = 2, c = { d = { g = 5, h = 6, i = 9, j = 'ten' }, f = 4 }}
      local r = { a = 1, b = 2, c = { d = { g = 5, h = 6, i = 7, k = 'ten' }, f = 4 }}

      assert.False(Dict.equals(l, r))
    end)
  end)

  describe('.compute_if_nil(dict, key, compute))', function()
    it("it should add compute's return value to the dict if it's not present", function()
      local dict = { a = 1, b = 2 }
      local compute = spy.new(function() return 3 end)

      assert.equals(Dict.compute_if_nil(dict, 'c', compute), 3)
      assert.equals(dict.c, 3)
      assert.spy(compute).was_called()
    end)
    it("it should not add compute's return value to the dict if it is present", function()
      local dict = { a = 1, b = 2, c = 4 }
      local compute = spy.new(function() return 3 end)

      assert.equals(Dict.compute_if_nil(dict, 'c', compute), 4)
      assert.equals(dict.c, 4)
      assert.spy(compute).Not.was_called()
    end)
  end)
end)


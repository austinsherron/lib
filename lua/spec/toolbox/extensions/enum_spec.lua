---@diagnostic disable: undefined-field

local Enumeration = require 'toolbox.extensions.enum'
local String = require 'toolbox.core.string'

local Enum = Enumeration.Enum
local Entry = Enumeration.Entry
local enum = Enumeration.enum
local entry = Enumeration.entry

require 'toolbox.test.extensions'

local assert = require 'luassert.assert'

describe('Enum', function()
  describe('.new(entries, default)', function()
    it('should construct a new instance w/ the provided entries', function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 })

      assert.equal(Abc.a, 1)
      assert.equal(Abc.b, 2)
      assert.equal(Abc.c, 3)
    end)
    it('should construct an instance w/ a default, if one is provided', function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 }, 'b')

      assert.equal(Abc.b, 2)
      assert.equal(Abc:get_default(), 2)
      assert.equal(Abc.b, Abc:get_default())
    end)
  end)

  describe(':has_default()', function()
    it('should return true if the enum was instantiated w/ a default', function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 }, 'b')

      assert.True(Abc:has_default())
    end)
    it('should return false if the enum was not instantiated w/ a default', function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 })

      assert.False(Abc:has_default())
    end)
  end)

  describe(':get_default()', function()
    it('should return the default value if the enum was instantiated w/ a default key', function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 }, 'a')

      assert.equal(Abc:get_default(), 1)
    end)
    it('should return nil if the enum was not instantiated w/ a default', function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 })

      assert.Nil(Abc:get_default())
    end)
  end)

  describe(':is_valid(entry)', function()
    local Abc = Enum.new({ a = 1, b = 2, c = 3 })

    it("should return true if entry corresponds to one of the enum's keys", function()
      assert.True(Abc:is_valid 'a')
      assert.True(Abc:is_valid 'b')
      assert.True(Abc:is_valid 'c')
    end)
    it("should return true if entry corresponds to one of the enum's values", function()
      assert.True(Abc:is_valid(1))
      assert.True(Abc:is_valid(2))
      assert.True(Abc:is_valid(3))
    end)
    it("should return false if entry doesn't correspond to any of the enum's keys or values", function()
      assert.False(Abc:is_valid 'g')
      assert.False(Abc:is_valid 'z')

      assert.False(Abc:is_valid(7))
      assert.False(Abc:is_valid(26))
    end)
  end)

  describe(':is_key(key)', function()
    local Abc = Enum.new({ a = 1, b = 2, c = 3 })

    it("should return true if key corresponds to one of the enum's keys", function()
      assert.True(Abc:is_key 'a')
      assert.True(Abc:is_key 'b')
      assert.True(Abc:is_key 'c')
    end)
    it("should return false if key doesn't correspond to any of the enum's keys", function()
      assert.False(Abc:is_key 'g')
      assert.False(Abc:is_key 'z')
    end)
    it("should return false if key is one of the enum's values", function()
      assert.False(Abc:is_key(1))
      assert.False(Abc:is_key(2))
      assert.False(Abc:is_key(3))
    end)
    it("should return false if key isn't one of the enum's values", function()
      assert.False(Abc:is_key(7))
      assert.False(Abc:is_key(26))
    end)
  end)

  describe(':is_value(val)', function()
    local Abc = Enum.new({ a = 1, b = 2, c = 3 })

    it("should return true if val corresponds to one of the enum's values", function()
      assert.True(Abc:is_value(1))
      assert.True(Abc:is_value(2))
      assert.True(Abc:is_value(3))
    end)
    it("should return false if val doesn't correspond to any of the enum's values", function()
      assert.False(Abc:is_value(7))
      assert.False(Abc:is_value(26))
    end)
    it("should return false if val is one of the enum's keys", function()
      assert.False(Abc:is_value 'a')
      assert.False(Abc:is_value 'b')
      assert.False(Abc:is_value 'c')
    end)
    it("should return false if val isn't one of the enum's keys", function()
      assert.False(Abc:is_value 'g')
      assert.False(Abc:is_value 'z')
    end)
  end)

  describe(':or_default(entry)', function()
    local Abc = Enum.new({ a = 1, b = 2, c = 3, d = 4 }, 'd')

    it("should return the value that corresponds to entry if it's one of the enum's keys", function()
      assert.equal(Abc:or_default 'a', 1)
      assert.equal(Abc:or_default 'b', 2)
      assert.equal(Abc:or_default 'c', 3)
    end)
    it("should return entry if it's one of the enum's values", function()
      assert.equal(Abc:or_default(1), 1)
      assert.equal(Abc:or_default(2), 2)
      assert.equal(Abc:or_default(3), 3)
    end)
    it("should return the default value if it has one and if entry isn't one of the enum's keys or values", function()
      assert.equal(Abc:or_default 'g', 4)
      assert.equal(Abc:or_default 'z', 4)
      assert.equal(Abc:or_default(7), 4)
      assert.equal(Abc:or_default(26), 4)
    end)
    it(
      "should return nil if the enum doesn't have a default value and if entry isn't one of the enum's keys or values",
      function()
        Abc = Enum.new({ a = 1, b = 2, c = 3 })

        assert.Nil(Abc:or_default 'g')
        assert.Nil(Abc:or_default 'z')
        assert.Nil(Abc:or_default(7))
        assert.Nil(Abc:or_default(26))
      end
    )
  end)

  describe(':keys()', function()
    it("should return an array of the enum's keys", function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 })
      local keys = Abc:keys()

      assert.array(keys).contains({ 'a', 'b', 'c' })
      assert.array(keys).length(3)
    end)
  end)

  describe(':values()', function()
    it("should return an array of the enum's values", function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 })
      local values = Abc:values()

      assert.array(values).contains({ 1, 2, 3 })
      assert.array(values).length(3)
    end)
  end)

  describe(':__tostring()', function()
    it("should return a properly formatted string based on the enum's contents", function() end)
  end)

  describe(':__index(key)', function()
    it("should allow direct indexing of the enum entry's key/value pairs", function()
      local Abc = Enum.new({ a = 1, b = 2, c = 3 })

      assert.equal(Abc.a, 1)
      assert.equal(Abc.b, 2)
      assert.equal(Abc.c, 3)
      assert.Nil(Abc.d)
    end)
  end)

  describe(':__pairs()', function()
    it("should enable via __pairs iteration over the enum entry's key/value pairs", function()
      local entries = { a = 1, b = 2, c = 3 }
      local Abc = Enum.new(entries)
      local new = {}

      for k, v in pairs(Abc) do
        new[k] = v
      end

      assert.same(entries, new)
    end)
  end)

  describe('enum(entries, default)', function()
    it('should construct an enum from an array of entries', function()
      local Abcde = enum({
        entry('a', 1),
        entry('b', 2),
        entry('c', 3),
        entry('d', 4),
        entry('e', 5),
      })

      assert.equal(Abcde.a, 1)
      assert.equal(Abcde.b, 2)
      assert.equal(Abcde.c, 3)
      assert.equal(Abcde.d, 4)
      assert.equal(Abcde.e, 5)

      assert.False(Abcde:has_default())
      assert.Nil(Abcde:get_default())

      assert.equal(getmetatable(Abcde), Enum)
    end)
    it('should construct an enum from a dict of key/value pairs', function()
      local Abcde = enum({ a = 1, b = 2, c = 3, d = 4, e = 5 })

      assert.equal(Abcde.a, 1)
      assert.equal(Abcde.b, 2)
      assert.equal(Abcde.c, 3)
      assert.equal(Abcde.d, 4)
      assert.is_a.equal(Abcde.e, 5)

      assert.False(Abcde:has_default())
      assert.Nil(Abcde:get_default())

      assert.equal(getmetatable(Abcde), Enum)
    end)
    it('should construct an enum w/ a default', function()
      local Abcde_array = enum({
        entry('a', 1),
        entry('b', 2),
        entry('c', 3),
        entry('d', 4),
        entry('e', 5),
      }, 'c')

      local Abcde_dict = enum({ a = 1, b = 2, c = 3, d = 4, e = 5 }, 'c')

      assert.equal(Abcde.a, 1)
      assert.equal(Abcde.b, 2)
      assert.equal(Abcde.c, 3)
      assert.equal(Abcde.d, 4)
      assert.equal(Abcde.e, 5)

      assert.True(Abcde:has_default())
      assert.equal(Abcde:get_default(), 3)

      assert.equal(getmetatable(Abcde), Enum)
    end)
    it('should construct an enum w/out a default', function() end)
  end)
end)

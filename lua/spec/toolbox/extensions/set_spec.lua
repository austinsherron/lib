local Set = require 'toolbox.extensions.set'

local assert = require 'luassert.assert'

require 'toolbox.test.extensions'


describe('Set', function()
  describe('.new(initial)', function()
    it('should create a new set w/ the values provided', function()
      assert.set(Set.new({ 1, 2, 3 })).eq(Set.new({ 1, 1, 3, 2 }))
      assert.set(Set.new()).eq(Set.new())
      assert.set(Set.new({})).eq(Set.new({}))
    end)
  end)

  describe('.of(...)', function()
    it('should create a new set w/ the values provided', function()
      assert.set(Set.of(1, 2, 3)).eq(Set.new({ 1, 2, 3 }))
      assert.set(Set.of(1, 1, 2, 3)).eq(Set.new({ 1, 1, 2, 3 }))
      assert.set(Set.of('a')).eq(Set.new({ 'a' }))
      assert.set(Set.of()).eq(Set.new())
    end)
  end)

  describe('.only(item)', function()
    it('should create a new set w/ the value provided', function()
      assert.set(Set.only(1)).eq(Set.new({ 1 }))
      assert.set(Set.only('a')).eq(Set.new({ 'a' }))
      assert.set(Set.only(true)).eq(Set.new({ true }))
    end)
  end)

  describe('.empty()', function()
    it('should create an empty set', function()
      local empty = Set.empty()

      assert.set(empty).eq(Set.new())
      assert.set(empty).is.empty()
      assert.set(empty).has.length(0)
    end)
  end)

  describe('.copy(o)', function()
    it('should make a copy of the provided set', function()
      local set = Set.of('a', 'b', 'c')
      local copy = Set.copy(set)

      assert.set(set).eq(copy)
      assert.set(set).Not.is(copy)

      copy:add('d')
      assert.set(set).is_not.eq(copy)
    end)
  end)

  describe(':add(item)', function()
    it('should add the provided item to the set', function()
      local set = Set.of('a', 'b', 'c')

      assert.set(set).does_not.contain({ 'd' })
      set:add('d')
      assert.set(set).contains({ 'd' })
    end)
    it('should add only one instance of an item to the set', function()
      local set = Set.of('a', 'b', 'c')

      assert.set(set).length(3)

      set:add('d')
      assert.set(set).contains({ 'd' })
      assert.set(set).length(4)

      set:add('d')
      assert.set(set).contains({ 'd' })
      assert.set(set).length(4)
    end)
  end)

  describe(':addall(...)', function()
    it('should add the provided item to the set', function()
      local set = Set.of('a', 'b', 'c')

      assert.set(set).does_not.contain({ 'd', 'e', 'f' })
      set:addall('d', 'e', 'f')
      assert.set(set).contains({ 'd', 'e', 'f' })
    end)

    it('should add only one instance of an items to the set', function()
      local set = Set.of('a', 'b', 'c')

      assert.set(set).length(3)

      set:addall('d', 'e', 'f')
      assert.set(set).contains({ 'd', 'e', 'f' })
      assert.set(set).length(6)

      set:addall('d', 'e', 'f')
      assert.set(set).contains({ 'd', 'e', 'f' })
      assert.set(set).length(6)
    end)
  end)

  describe(':contains(item)', function()
    it('return true if the provided item is in the set', function()
      local set = Set.of(1, 2, 3)
      assert.True(set:contains(2))
    end)
    it('return true if the provided item added to the set', function()
      local set = Set.of(1, 2, 3)
      set:add(4)

      assert.True(set:contains(4))
    end)
    it("return false if the provided item isn't in the set", function()
      local set = Set.of(1, 2, 3)
      assert.False(set:contains(4))
    end)
  end)

  describe(':__len()', function()
    it('should return the number of distinct items in the set', function()
      local s = Set.of('a', 'b', 'c', 'c')

      assert.equals(#s, 3)
      s:add('a')
      assert.equals(#s, 3)
      s:add('d')
      assert.equals(#s, 4)
      s:addall('d', 'a', 'f', 'e', 'gadzooks', 'c')
      assert.equals(#s, 7)
    end)
  end)

  describe(':__eq(o)', function()
    it('should return true if two sets have the same contents', function()
      local l = Set.of('a', 'b', 'c')
      local r = Set.of('a', 'b', 'c')

      assert.True(l == r)

      l:add('a')
      r:add('c')

      assert.True(l == r)

      assert.True(Set.of('b', 'a', 'b') == Set.of('a', 'b', 'a', 'a'))
    end)
    it('should return false if two sets have different contents', function()
      assert.False(Set.of('a', 'b') == Set.of('c', 'd'))
      assert.False(Set.of('a', 'b') == Set.of('a', 'b', 'c'))
      assert.False(Set.of('a', 'b', 'c') == Set.of('a', 'b'))
    end)
  end)

  describe(':entries()', function()
    it("should return an array w/ the set's entries", function()
      local entries = Set.of('a', 'b', 'c', 'c', 'a'):entries()

      assert.array(entries).contains({ 'a', 'b', 'c' })
      assert.array(entries).length(3)

      assert.array(Set.of():entries()).is.empty()
    end)
  end)

  describe(':__add(o)', function()
    it('should create a new set that is the union of the set and the provided set', function()
      local set = Set.of('a', 'b', 'c')
      local other = Set.of('b', 'c', 'd', 'e')
      local super = set + other

      assert.set(super).eq(Set.of('a', 'b', 'c', 'd', 'e'))
      assert.set(super).length(5)
      assert.set(super).Not.is(set)
      assert.set(super).Not.is(other)
    end)
  end)

  describe(':__sub(o)', function()
    it('should create a new set that is the difference of the set and the provided set', function()
      local set = Set.of('a', 'b', 'c')
      local other = Set.of('b', 'c', 'd', 'e')
      local super = set - other

      assert.set(super).eq(Set.only('a'))
      assert.set(super).length(1)
      assert.set(super).Not.is(set)
      assert.set(super).Not.is(other)
    end)
  end)

  describe(':__concat(o)', function()
    it('should create a new set that is the union of the set and the provided set', function()
      local set = Set.of('a', 'b', 'c')
      local other = Set.of('b', 'c', 'd', 'e')
      local super = set .. other

      assert.set(super).eq(Set.of('a', 'b', 'c', 'd', 'e'))
      assert.set(super).length(5)
      assert.set(super).Not.is(set)
      assert.set(super).Not.is(other)
    end)
  end)

  describe(':__ipairs()', function()
    it('should iterate over the elements of the set', function()
      local set = Set.of('a', 'b', 'c')
      local other = Set.new()
      local i = 0

      for _, e in ipairs(set) do
        i = i + 1
        other:add(e)
      end

      assert.set(other).eq(set)
      assert.set(other).length(i)
    end)
  end)

  describe(':__tostring()', function()
    it('should return a string representation of the set', function()
      assert.equals(tostring(Set.only('a')), 'set(a)')
      assert.equals(tostring(Set.only(1)), 'set(1)')
    end)
  end)
end)


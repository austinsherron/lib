local Common = require 'toolbox.core.__common'
local Set = require 'toolbox.extensions.set'
local Table = require 'toolbox.core.table'

local assert = require 'luassert.assert'

describe('Table', function()
  describe('.is(o)', function()
    it('should return true if o is a table', function()
      assert.True(Table.is({ 1 }))
      assert.True(Table.is({ 1, 2 }))
      assert.True(Table.is({ 1, 2, 3 }))

      assert.True(Table.is({ 'c' }))
      assert.True(Table.is({ 'c', 'b' }))
      assert.True(Table.is({ 'c', 'b', 'a' }))

      assert.True(Table.is({ a = 1 }))
      assert.True(Table.is({ a = 1, b = 2 }))
      assert.True(Table.is({ a = 1, b = 2, c = 3 }))
    end)
    it('should return false if o is not a table', function()
      assert.False(Table.is(1))
      assert.False(Table.is 'a')
      assert.False(Table.is(false))
      assert.False(Table.is(true))
    end)
  end)

  describe('.is_empty(tbl)', function()
    it('should return true if tbl is empty', function()
      assert.True(Table.is_empty({}))
      assert.True(Table.is_empty({ nil }))
      assert.True(Table.is_empty({ nil, nil }))
      assert.True(Table.is_empty({ a = nil }))
      assert.True(Table.is_empty({ a = nil, b = nil }))
    end)
    it('should return false if tbl is not empty', function()
      assert.False(Table.is_empty({ 1 }))
      assert.False(Table.is_empty({ 1, 2, 3 }))
      assert.False(Table.is_empty({ 'z', 'b', 'c', 'a' }))
      assert.False(Table.is_empty({ a = 'z', c = 'q', 1 }))
    end)
  end)

  describe('.nil_or_empty(tbl)', function()
    it('should return true if tbl is nil or empty', function()
      assert.True(Table.nil_or_empty(nil))
      assert.True(Table.nil_or_empty({}))
      assert.True(Table.nil_or_empty({ nil }))
      assert.True(Table.nil_or_empty({ nil, nil }))
      assert.True(Table.nil_or_empty({ a = nil }))
      assert.True(Table.nil_or_empty({ a = nil, b = nil }))
    end)
    it('should return false if tbl is not nil nor empty', function()
      assert.False(Table.nil_or_empty({ 1 }))
      assert.False(Table.nil_or_empty({ 1, 2, 3 }))
      assert.False(Table.nil_or_empty({ 'z', 'b', 'c', 'a' }))
      assert.False(Table.nil_or_empty({ a = 'z', c = 'q', 1 }))
    end)
  end)

  describe('.not_nil_or_empty(tbl)', function()
    it('should return false if tbl is nil or empty', function()
      assert.False(Table.not_nil_or_empty(nil))
      assert.False(Table.not_nil_or_empty({}))
      assert.False(Table.not_nil_or_empty({ nil }))
      assert.False(Table.not_nil_or_empty({ nil, nil }))
      assert.False(Table.not_nil_or_empty({ a = nil }))
      assert.False(Table.not_nil_or_empty({ a = nil, b = nil }))
    end)
    it('should return true if tbl is not nil nor empty', function()
      assert.True(Table.not_nil_or_empty({ 1 }))
      assert.True(Table.not_nil_or_empty({ 1, 2, 3 }))
      assert.True(Table.not_nil_or_empty({ 'z', 'b', 'c', 'a' }))
      assert.True(Table.not_nil_or_empty({ a = 'z', c = 'q', 1 }))
    end)
  end)

  describe('.contains(tbl, val)', function()
    local inner = { hello = 'goodbye' }
    local inner_copy = { hello = 'goodbye' }

    local tbl = { 1, 'a', 'qwerty', z = true, q = 'absolutely', inner }

    it('should return true if tbl contains val', function()
      assert.True(Table.contains(tbl, 1))
      assert.True(Table.contains(tbl, 'a'))
      assert.True(Table.contains(tbl, 'qwerty'))
      assert.True(Table.contains(tbl, true))
      assert.True(Table.contains(tbl, 'absolutely'))

      ---@note: not necessarily an intended usage, but it works
      assert.True(Table.contains(tbl, inner))
    end)
    it("should return false if tbl doesn't contain val", function()
      assert.False(Table.contains(tbl, 'z'))
      assert.False(Table.contains(tbl, 'q'))
      assert.False(Table.contains(tbl, 'dvorac'))
      assert.False(Table.contains(tbl, false))
      assert.False(Table.contains(tbl, 'hardly'))

      ---@note: illustrates a shortcoming of Table.contains
      assert.False(Table.contains(tbl, inner_copy))
    end)
  end)

  describe('.keys(tbl, transform)', function()
    it("should return an array-like table's keys", function()
      assert.same(Table.keys({ 'a', 'b', 'c', 'd' }), { 1, 2, 3, 4 })
      assert.same(Table.values({}), {})
    end)
    it("should return a dict-like table's keys", function()
      assert.same(Table.keys({ a = 'z', b = 'y', c = 'x' }), { 'a', 'b', 'c' })
    end)

    local function transform(k, v)
      return Common.String.fmt('%s-%s', k, v)
    end

    it("should transform an array-like table's keys", function()
      assert.same(Table.keys({ 'a', 'b', 'c', 'd' }, transform), { '1-a', '2-b', '3-c', '4-d' })
      assert.same(Table.values({}), {})
    end)
    it("should transform a dict-like table's keys", function()
      assert.same(Table.keys({ a = 'z', b = 'y', c = 'x' }, transform), { 'a-z', 'b-y', 'c-x' })
    end)
  end)

  describe('.values(tbl, transform)', function()
    it("should return an array-like table's values", function()
      assert.same(Table.values({ 'a', 'b', 'c', 'd' }), { 'a', 'b', 'c', 'd' })
      assert.same(Table.values({}), {})
    end)
    it("should return a dict-like table's values", function()
      assert.same(Table.values({ a = 'z', b = 'y', c = 'x' }), { 'z', 'y', 'x' })
    end)

    local function transform(v, k)
      return Common.String.fmt('%s-%s', v, k)
    end

    it("should transform an array-like table's values", function()
      assert.same(Table.values({ 'a', 'b', 'c', 'd' }, transform), { 'a-1', 'b-2', 'c-3', 'd-4' })
      assert.same(Table.values({}), {})
    end)
    it("should transform a dict-like table's values", function()
      assert.True(Common.Array.equals(Table.values({ a = 'z', b = 'y', c = 'x' }, transform), { 'z-a', 'y-b', 'x-c' }))
    end)
  end)

  describe('.flatten(arrs)', function()
    it('should flatten non-nested arrays', function()
      assert.same(Table.flatten({ 'a', 'b', 'c', 'd', 'e', 'f', 'g' }), { 'a', 'b', 'c', 'd', 'e', 'f', 'g' })
      assert.same(
        Table.flatten({ { 'a', 'b', 'c' }, { 'd', 'e' }, { 'f', 'g' } }),
        { 'a', 'b', 'c', 'd', 'e', 'f', 'g' }
      )
    end)
    it('should flatten arbitrarily nested arrays', function()
      assert.same(
        Table.flatten({
          { 'a', 'b', 'c', { 'd', { 'e', 'f', { 'g' } }, 'h' } },
          { 'i', 'j', { 'k', { 'l' } } },
          { 'm', { 'n' } },
        }),
        { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n' }
      )
    end)
  end)

  describe('.pack(...)', function()
    it('should return a table filled with the provided arguments', function()
      assert.same(Table.pack(1, 2, 3, 'a', true, nil), { 1, 2, 3, 'a', true })
      assert.same(Table.pack(1, 2, 3, 'a', true, { 'a', 'b' }), { 1, 2, 3, 'a', true, { 'a', 'b' } })
    end)
    it('return an empty table if no arguments are passed', function()
      assert.same(Table.pack(), {})
    end)
  end)

  describe('.unpack(tbl)', function()
    it('should return the individual elements of the provided array-like table', function()
      local a, b, c = Table.unpack({ 'a', 'b', 'c' })

      assert.equals(a, 'a')
      assert.equals(b, 'b')
      assert.equals(c, 'c')
    end)
    it('should return nothing if an empty table is provided', function()
      assert.Nil(Table.unpack({}))
    end)
    it('should return nothing if a dict-like table is provided', function()
      assert.Nil(Table.unpack({ a = 1 }))
    end)
  end)

  describe('.get_only(tbl, strict)', function()
    describe('strict is false', function()
      it('should return the only key/value pair if there is only one key/value pair in tbl', function()
        local k, v = Table.get_only({ a = 1 }, false)

        assert.equals(k, 'a')
        assert.equals(v, 1)
      end)
      it('should return nils if the tbl is empty', function()
        local k, v = Table.get_only({}, false)

        assert.Nil(k)
        assert.Nil(v)
      end)
      it('should return a random key/value pair if there is more than one key/value pair in tbl', function()
        local k, v = Table.get_only({ a = 1, b = 2 }, false)

        -- TODO: create custom assertion that checks if variable is "one_of" multiple values
        if k == 'a' then
          assert.equals(k, 'a')
          assert.equals(v, 1)
        end

        if k == 'b' then
          assert.equals(k, 'b')
          assert.equals(v, 2)
        end
      end)
    end)

    describe('strict is true', function()
      it('should return the only key/value pair if there is only one key/value pair in tbl', function()
        local k, v = Table.get_only({ a = 1 })

        assert.equals(k, 'a')
        assert.equals(v, 1)
      end)
      it('should raise an error if the tbl is empty', function()
        assert.has_error(function()
          Table.get_only({})
        end)
      end)
      it('should raise an error if there is more than one key/value pair in tbl', function()
        assert.has_error(function()
          Table.get_only({ a = 1, b = 2 })
        end)
      end)
    end)
  end)

  describe('.map_items(tbl, xfms)', function()
    describe('dict-like tables', function()
      local tbl = { a = 1, b = 2, c = 3 }
      local keys = function(k, v, _)
        return k .. tostring(v)
      end
      local vals = function(v, _, _)
        return v + 1
      end

      it('should map keys', function()
        assert.same(Table.map_items(tbl, { keys = keys }), { a1 = 1, b2 = 2, c3 = 3 })
      end)
      it('should map values', function()
        assert.same(Table.map_items(tbl, { vals = vals }), { a = 2, b = 3, c = 4 })
      end)
      it('should map keys and values', function()
        assert.same(Table.map_items(tbl, { keys = keys, vals = vals }), { a1 = 2, b2 = 3, c3 = 4 })
      end)
    end)

    describe('array-like tables', function()
      local arr = { 1, 2, 3 }
      local keys = function(k, _, i)
        return k + i
      end
      local vals = function(v, _, i)
        return v + i
      end

      it('should map keys', function()
        assert.same(Table.map_items(arr, { keys = keys }), { [2] = 1, [4] = 2, [6] = 3 })
      end)
      it('should map values', function()
        assert.same(Table.map_items(arr, { vals = vals }), { 2, 4, 6 })
      end)
      it('should map keys and values', function()
        assert.same(Table.map_items(arr, { keys = keys, vals = vals }), { [2] = 2, [4] = 4, [6] = 6 })
      end)
    end)
  end)

  describe('.to_dict(arr, xfms)', function()
    local arr = { 'a', 'b', 'c' }
    local mapper = function(e, i)
      return e .. i
    end

    it('should use the key mapper', function()
      assert.same(Table.to_dict(arr, { keys = mapper }), { a1 = 'a', b2 = 'b', c3 = 'c' })
    end)
    it('should use the value mapper', function()
      assert.same(Table.to_dict(arr, { vals = mapper }), { a = 'a1', b = 'b2', c = 'c3' })
    end)
    it('should use the key and value mappers', function()
      assert.same(Table.to_dict(arr, { keys = mapper, vals = mapper }), { a1 = 'a1', b2 = 'b2', c3 = 'c3' })
    end)
    it('should use a single mapper if provided', function()
      assert.same(
        Table.to_dict(arr, function(e, i)
          return e .. i, e .. i
        end),
        { a1 = 'a1', b2 = 'b2', c3 = 'c3' }
      )
    end)
    it('should use default mappers if none are provided', function()
      assert.same(Table.to_dict(arr), { a = 'a', b = 'b', c = 'c' })
    end)
  end)

  describe('.shallow_copy(tbl)', function()
    it('should return a real copy of a non-nested table', function()
      local tbl = { a = 1, b = 2, c = 3 }
      local copied = Table.shallow_copy(tbl)

      assert.same(tbl, copied)
      assert.Not.equals(tbl, copied)
    end)
    it('should return a real copy of an empty table', function()
      local tbl = {}
      local copied = Table.shallow_copy(tbl)

      assert.same(tbl, copied)
      assert.Not.equals(tbl, copied)
    end)
  end)

  describe('.tostring(tbl, o, c, sep)', function()
    it('should stringify simple tables', function()
      assert.equals(Table.tostring({ a = 1 }), '{ a = 1 }')
    end)
    it('should stringify nested tables', function()
      assert.equals(Table.tostring({ a = { c = 2 } }), '{ a = { c = 2 } }')
      assert.equals(Table.tostring({ a = { b = { c = 1 } } }), '{ a = { b = { c = 1 } } }')
      assert.equals(Table.tostring({ a = { b = { c = {} } } }), '{ a = { b = { c = {} } } }')
    end)
    it('should stringify tables w/ tables as keys', function()
      assert.equals(Table.tostring({ [{ 'a' }] = { c = 2 } }), '{ { a } = { c = 2 } }')
      assert.equals(Table.tostring({ [{ a = 1 }] = { c = 2 } }), '{ { a = 1 } = { c = 2 } }')
    end)
    it('should stringify empty tables', function()
      assert.equals(Table.tostring({}), '{}')
    end)
    it('should stringify simple arrays', function()
      assert.equals(Table.tostring({ 'a', 1, 'b' }), '{ a, 1, b }')
    end)
    it('should stringify nested arrays', function()
      assert.equals(Table.tostring({ 'a', 1, { 'b', 'c', {} } }), '{ a, 1, { b, c, {} } }')
    end)
    it('should use custom opening/closing characters, if provided', function()
      assert.equals(Table.tostring({ 'a', 1, { 'b', 'c', {} } }, '[', ']'), '[ a, 1, [ b, c, [] ] ]')
    end)
    it('should use a custom separator, if provided', function()
      assert.equals(Table.tostring({ 'a', 1, { 'b', 'c', {} } }, nil, nil, '|'), '{ a|1|{ b|c|{} } }')
    end)
  end)

  describe('.merge(l, r)', function()
    it('should merge r into l', function()
      local tbl = { a = 1, b = 2 }

      Table.merge(tbl, { a = 2, c = 3 })
      assert.same(tbl, { a = 2, b = 2, c = 3 })
    end)
    it('should work with empty tables', function()
      local tbl = {}

      Table.merge(tbl, { a = 1, c = 3 })
      Table.merge(tbl, {})
      assert.same(tbl, { a = 1, c = 3 })
    end)
  end)

  describe('.concat(tbls)', function()
    it('should concatenate an multiple array-like tables into a single new table', function()
      assert.same(
        Table.concat({ { 'a', 'b', 'c' }, { 1, 2, 3 }, {}, { 'x', 'y', 'z' } }),
        { 'a', 'b', 'c', 1, 2, 3, 'x', 'y', 'z' }
      )
    end)
  end)

  describe('.split(tbl, left)', function()
    it('split tbl into two tables, the first w/ key in left, the second w/ the rest', function()
      local picked, rest = Table.split({ a = 1, b = 2, c = 3 }, { 'a', 'c', 'd' })

      assert.same(picked, { a = 1, c = 3 })
      assert.same(rest, { b = 2 })
    end)
    it('should work w/ an empty table', function()
      local picked, rest = Table.split({}, { 'a', 'c', 'd' })

      assert.same(picked, {})
      assert.same(rest, {})
    end)
    it('should work w/ an empty "left" array', function()
      local picked, rest = Table.split({ a = 1 }, {})

      assert.same(picked, {})
      assert.same(rest, { a = 1 })
    end)
  end)

  describe('.split_one(tbl, k)', function()
    it("should pick out the value associated w/ key, if it's present", function()
      local v, _ = Table.split_one({ a = 1, b = 2 }, 'a')

      assert.equals(v, 1)
    end)
    it('should return a new table w/out the key/value pair associated w/ k', function()
      local tbl = { a = 1, b = 2 }
      local _, rest = Table.split_one(tbl, 'a')

      assert.same(rest, { b = 2 })
      assert.same(tbl, { a = 1, b = 2 })
    end)
    it("should return nil and a new table if k isn't in tbl", function()
      local tbl = { a = 1, b = 2 }
      local v, rest = Table.split_one(tbl, 'c')

      assert.Nil(v)
      assert.same(tbl, { a = 1, b = 2 })
      assert.Not.equals(rest, tbl)
    end)
  end)

  describe('.pick(tbl, keep, unpacked)', function()
    local tbl = { a = 1, b = 2, c = 3 }

    it('should return a new table w/ the key/value pairs corresponding to keys in keep', function()
      assert.same(Table.pick(tbl, { 'a', 'c' }), { a = 1, c = 3 })
      assert.same(Table.pick(tbl, { 'a', 'c', 'd' }), { a = 1, c = 3 })
      assert.same(Table.pick(tbl, { 'a', 'b', 'c' }), { a = 1, b = 2, c = 3 })
      assert.same(Table.pick(tbl, {}), {})
      assert.same(Table.pick({}, { 'a', 'b' }), {})

      assert.same(Table.pick(tbl, { 'a', 'b', 'c' }), tbl)
      assert.Not.equals(Table.pick(tbl, { 'a', 'b', 'c' }), tbl)
    end)
    it('should unpack the values from the new table if unpacked == true', function()
      assert.equals(1, Table.pick(tbl, { 'a' }, true))
    end)
  end)

  describe('.pick_out(tbl, exclude, unpacked)', function()
    local tbl = { a = 1, b = 2, c = 3 }

    it('should return a new table w/ the key/value pairs corresponding to keys in keep', function()
      assert.same(Table.pick_out(tbl, Set.only 'a'), { b = 2, c = 3 })
      assert.same(Table.pick_out(tbl, Set.of('a', 'c')), { b = 2 })
      assert.same(Table.pick_out(tbl, Set.of('a', 'c', 'd')), { b = 2 })
      assert.same(Table.pick_out(tbl, Set.of('a', 'b', 'c')), {})
      assert.same(Table.pick_out(tbl, Set.empty()), { a = 1, b = 2, c = 3 })
      assert.same(Table.pick_out({}, Set.of('a', 'b')), {})

      assert.same(Table.pick_out(tbl, Set.empty()), tbl)
      assert.Not.equals(Table.pick_out(tbl, Set.empty()), tbl)
    end)
    it('should unpack the values from the new table if unpacked == true', function()
      assert.equals(Table.pick_out(tbl, Set.of('a', 'b'), true), 3)
    end)
  end)

  describe('.safeget(tbl, keys)', function()
    it('should get safely from a nil table', function()
      assert.Nil(Table.safeget(nil, 'key'))
    end)
    it("should return nil if there's no value associated w/ key", function()
      assert.Nil(Table.safeget({ a = 1, c = 3 }, 'b'))
      assert.Nil(Table.safeget({ a = 1, c = 3 }, { 'b' }))
      assert.Nil(Table.safeget({ a = 1, b = { d = 4 }, c = 3 }, { 'b', 'e' }))
    end)
    it('should get the value associated w/ key from a dict-like table', function()
      assert.equals(Table.safeget({ a = 1, b = 2 }, 'a'), 1)
      assert.equals(Table.safeget({ a = 1, b = 2 }, { 'a' }), 1)
      assert.equals(Table.safeget({ a = 1, b = 2 }, { 'a', 'b' }), 1)
      assert.same(Table.safeget({ a = 1, b = 2, c = { d = 4 } }, 'c'), { d = 5 })
    end)
    it('should get the value associated w/ key from an array-like table', function()
      assert.equals(Table.safeget({ 'a', 'b', 'c' }, 2), 'b')
      assert.equals(Table.safeget({ 'a', 'b', 'c' }, { 2 }), 'b')
      assert.equals(Table.safeget({ 'a', 'b', 'c' }, { 2, 1 }), 'b')
      assert.same(Table.safeget({ 'a', 'b', { 'c' } }, 3), { 'c' })
    end)
    it('should get the nested value associated w/ keys from a nested dict-like table', function()
      assert.equals(Table.safeget({ a = 1, b = { c = 3 } }, { 'b', 'c' }), 3)
      assert.same(Table.safeget({ a = 1, b = { c = { d = 4 } } }, { 'b', 'c' }), { d = 4 })
    end)
    it('should get the nested value associated w/ keys from a nested array-like table', function()
      assert.equals(Table.safeget({ 'a', 'b', { 'c', 'd' } }, { 3, 1 }), 'c')
      assert.same(Table.safeget({ 'a', 'b', { 'c', { 'd' } } }, { 3, 2 }), { 'd' })
    end)
  end)

  describe('.combine(l, r)', function()
    it('should combine l and r into a new table', function()
      local l = { a = 1, b = 2 }
      local r = { c = 3, d = 4 }

      assert.same(Table.combine(l, r), { a = 1, b = 2, c = 3, d = 4 })
      assert.same(l, { a = 1, b = 2 })
      assert.same(r, { c = 3, d = 4 })
    end)
    it('should work w/ empty tables', function()
      assert.same(Table.combine({ a = 1, b = 2 }, {}), { a = 1, b = 2 })
      assert.same(Table.combine({}, { a = 1, b = 2 }), { a = 1, b = 2 })
      assert.same(Table.combine({}, {}), {})
    end)
    it("shouldn't overwrite values in r", function()
      assert.same(Table.combine({ a = 1, b = 2 }, { b = -2, c = 3 }), { a = 1, b = -2, c = 3 })
    end)
    it('should work w/ nested tables', function()
      local l = {
        a = 1,
        b = { x = 2 },
        c = { d = 4 },
      }
      local r = { b = -2, e = { f = 25 } }
      local combined = {
        a = 1,
        b = -2,
        c = { d = 4 },
        e = { f = 25 },
      }

      assert.same(Table.combine(l, r), combined)
    end)
  end)

  describe('.combine_many(tbls)', function()
    it('should combine multiple tables into a new table', function()
      local une = { a = 1, b = 2 }
      local deux = { c = 3, d = 4 }
      local trois = { e = 5, f = 6 }
      local combined = { a = 1, b = 2, c = 3, d = 4, e = 5, f = 6 }

      assert.same(Table.combine_many({ une, deux, trois }), combined)
      assert.same(une, { a = 1, b = 2 })
      assert.same(deux, { c = 3, d = 4 })
      assert.same(trois, { e = 5, f = 6 })
    end)
    it('should work w/ empty tables', function()
      assert.same(Table.combine_many({ {}, { a = 1, b = 2 }, {} }), { a = 1, b = 2 })
      assert.same(Table.combine_many({ {}, {}, { a = 1, b = 2 } }), { a = 1, b = 2 })
      assert.same(Table.combine_many({ {}, {}, {} }), {})
    end)
    it('should prioritize (avoid overwriting) values further to the right (later in input array)', function()
      local ichi = { a = 1, b = 2 }
      local ni = { b = -2, c = 3 }
      local san = { b = 4, d = 5 }

      assert.same(Table.combine_many({ ichi, ni, san }), { a = 1, b = 4, c = 3, d = 5 })
    end)
    it('should work w/ nested tables', function()
      local uno = {
        a = 1,
        b = { x = 2 },
        c = { d = 4 },
      }
      local dos = { b = -2, e = { f = 25 } }
      local tres = { b = 4, e = { g = { h = 3 } }, d = 4 }
      local combined = {
        a = 1,
        b = 4,
        c = { d = 4 },
        d = 4,
        e = { g = { h = 3 } },
      }

      assert.same(Table.combine_many({ uno, dos, tres }), combined)
    end)
  end)

  describe('.reverse_items(tbl, fail_on_dup)', function()
    it('should reverse keys/values in tbl', function()
      assert.same(Table.reverse_items({ a = 'z', b = 'y', c = 'x' }), { z = 'a', y = 'b', x = 'c' })
    end)
    it('should work if the resulting table is array-like', function()
      assert.same(Table.reverse_items({ a = 1, b = 2, c = 3 }), { 'a', 'b', 'c' })
    end)
    it('should work if the resulting table is array-like', function()
      assert.same(Table.reverse_items({ a = 1, b = 2, c = 3 }), { 'a', 'b', 'c' })
    end)
    it('should work w/ array-like tables', function()
      assert.same(Table.reverse_items({ 'a', 'b', 'c' }), { a = 1, b = 2, c = 3 })
    end)
    it('should work w/ duplicate keys', function()
      assert.same(Table.reverse_items({ 'a', 'b', 'c', 'c' }), { a = 1, b = 2, c = 4 })
    end)
    it('should fail on duplicate keys if fail_on_dup == true', function()
      assert.has_error(function()
        Table.reverse_items({ 'a', 'b', 'c', 'c' }, true)
      end)
    end)
  end)

  describe('.array_combine(l, r)', function()
    it('should combine l and r into a new array-like table', function()
      local l = { 1, 2 }
      local r = { 2, 3 }

      assert.same(Table.array_combine(l, r), { 1, 2, 2, 3 })
      assert.same(l, { 1, 2 })
      assert.same(r, { 2, 3 })
    end)
    it('should work w/ empty tables', function()
      assert.same(Table.array_combine({ 1, 2 }, {}), { 1, 2 })
      assert.same(Table.array_combine({}, { 1, 2 }), { 1, 2 })
      assert.same(Table.array_combine({}, {}), {})
    end)
    it('should work w/ nested array-like tables', function()
      local l = { 1, { 2 }, { { 3 }, 4 } }
      local r = { -2, { 25 } }
      local combined = {
        1,
        { 2 },
        { { 3 }, 4 },
        -2,
        { 25 },
      }

      assert.same(Table.combine(l, r), combined)
    end)
  end)
end)

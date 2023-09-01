---@diagnostic disable: invisible

local Array = require 'toolbox.core.array'
local Table = require 'toolbox.core.table'
local Stack = require 'toolbox.extensions.stack'


describe('Stack', function()
  describe('.new(...)', function()
    it('should create a new stack w/ the provided items', function()
      local items = { 1, 2, 3, 4 }
      local s = Stack.new(Table.unpack(items))

      assert.True(Array.equals(s.stack, items))
    end)
    it('should create a new stack w/ a single initial item', function()
      local stack = Stack.new(3)

      assert.True(Array.equals(stack.stack, { 3 }))
    end)
    it('should create a new stack w/ no initial items', function()
      local stack = Stack.new()

      assert.True(Array.equals(stack.stack, {}))
    end)
  end)

  describe('.copy(o)', function()
    it('should create a distinct instance w/ the same members as o', function()
      local o = Stack.new(1, 2, 3, 4)
      local s = Stack.copy(o)

      assert.equals(#s, #o)

      while not s:empty() do
        assert.equals(s:pop(), o:pop())
      end

      s:push(5)

      assert.False(s:empty())
      assert.True(o:empty())
    end)
  end)

  describe(':__len()', function()
    it('should return 0 for an empty stack', function()
      local s = Stack.new()

      assert.equals(#s, 0)
    end)
    it('should return n where n == the number of items in the stack', function()
      local s = Stack.new()

      assert.equals(#s, 0)
      s:push(1)
      assert.equals(#s, 1)
      s:push(2)
      assert.equals(#s, 2)
      s:push(3)
      assert.equals(#s, 3)
      s:pop()
      assert.equals(#s, 2)
      s:pop()
      assert.equals(#s, 1)
      s:pop()
      assert.equals(#s, 0)
      s:pop()
      assert.equals(#s, 0)
      s:push(8)
      assert.equals(#s, 1)
      s:pop()
      s:pop()
      assert.equals(#s, 0)
    end)
  end)

  describe(':empty()', function()
    it('should return true if the stack is empty', function()
      local s = Stack.new()

      assert.True(s:empty())
    end)
    it('should return false if the stack is not empty', function()
      local s = Stack.new()

      assert.True(s:empty())
      s:push(1)
      assert.False(s:empty())
      s:push(2)
      assert.False(s:empty())
      s:pop()
      assert.False(s:empty())
      s:pop()
      assert.True(s:empty())
      s:pop()
      assert.True(s:empty())
    end)
  end)

  describe(':push(item)', function()
    it('add items to the "end" the stack', function()
      local s = Stack.new()

      s:push(1)
      s:push(2)
      s:push(3)

      assert.equals(s:pop(), 3)
      assert.equals(s:pop(), 2)
      assert.equals(s:pop(), 1)
      assert.equals(s:pop(), nil)
    end)
  end)

  describe(':pop()', function()
    it('should pop items off the end of the stack', function()
      local s = Stack.new()

      s:push(1)
      s:push(2)
      s:push(3)
      assert.equals(s:pop(), 3)
      assert.equals(s:pop(), 2)
      s:push(4)
      s:push(5)
      assert.equals(s:pop(), 5)
      assert.equals(s:pop(), 4)
      assert.equals(s:pop(), 1)
      s:push(10)
      s:push(11)
      assert.equals(s:pop(), 11)
      assert.equals(s:pop(), 10)
      assert.equals(s:pop(), nil)
    end)
  end)

  describe(':peek()', function()
    it('should show the top stack item w/out modifying the stack', function()
      local s = Stack.new()

      s:push(1)
      s:push(2)
      s:push(3)
      assert.equals(s:peek(), 3)
      assert.equals(s:peek(), 3)
      assert.equals(s:pop(), 3)
      assert.equals(s:peek(), 2)
      assert.equals(s:pop(), 2)
      assert.equals(s:pop(), 1)
      assert.equals(s:peek(), nil)
    end)
  end)

  describe(':peekall()', function()
    it('should show the all items in the stack item w/out modifying the stack', function()
      local s = Stack.new()

      s:push(1)
      s:push(2)
      s:push(3)
      assert.True(Array.equals(s:peekall(), { 3, 2, 1 }))
      assert.True(Array.equals(s:peekall(), { 3, 2, 1 }))
      assert.equals(s:pop(), 3)
      assert.True(Array.equals(s:peekall(), { 2, 1 }))
      assert.equals(s:pop(), 2)
      assert.equals(s:pop(), 1)
      assert.equals(s:peek(), nil)
    end)
  end)

  describe(':pushall(...)', function()
    it('should push all items onto the stack', function()
      local s = Stack.new()

      s:push(1)
      s:push(2)

      assert.equals(s:pop(), 2)
      s:pushall(3, 4, 5, 6)
      assert.equals(s:pop(), 6)
      assert.equals(s:pop(), 5)
      assert.equals(s:pop(), 4)
      assert.equals(s:pop(), 3)
      s:pushall()
      assert.equals(s:pop(), 1)
      s:pushall(1)
      assert.equals(s:pop(), 1)
      assert.equals(s:pop(), nil)
    end)
  end)

  describe(':__ipairs(o)', function()
    it("should yeild the stack's items in the right order w/out modifying the stack", function()
      local s = Stack.new()
      s:pushall(1, 2, 3)

      local c = Stack.copy(s)
      local idx = 1

      for i, v in ipairs(s) do
        assert.equals(idx, i)
        assert.equals(v, c:pop())

        idx = idx + 1
      end

      assert.Nil(c:pop())
      assert.equals(s:pop(), 3)
      assert.equals(s:pop(), 2)
      assert.equals(s:pop(), 1)
      assert.Nil(s:pop())
    end)
  end)
end)

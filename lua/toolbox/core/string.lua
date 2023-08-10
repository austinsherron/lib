local Bool  = require 'toolbox.core.bool'
local Table = require 'toolbox.core.table'


-- TODO: create "Indexable" class that implements python-like indexing for strings
--       see `toolbox.core.string.Indexable`

---@class String
local String = {}

--- Returns true if the provided string starts with the provided prefix, or if str == pfx.
--  false if either str or pfx == nil.
--
---@param str string?: the string to check
---@param pfx string?: the prefix to check
---@return boolean: true if str starts with pfx or str == pfx; false otherwise, or if either str or
-- pfx == nil
function String.startswith(str, pfx)
    if str == nil or pfx == nil then
        return false
    end

    return #pfx <= #str and str:sub(1, #pfx) == pfx
end


--- Returns true if the provided string ends with the provided suffix, or if str == sfx.
--  false if either str or sfx == nil.
--
---@param str string?: the string to check
---@param sfx string?: the suffix to check
---@return boolean: true if str ends with sfx or str == sfx; false otherwise, or if either str or
-- sfx == nil
function String.endswith(str, sfx)
    if str == nil or sfx == nil then
        return false
    end

    return #sfx <= #str and str:sub(-#sfx, #str) == sfx
end


--- Splits into an array-like table the provided string wherever "sep" is encountered in
--  that string. For example, the following call:
--
--    str.split('helloxxxtherexxxbeautiful', 'xxx')
--
--  Would result in the following return value:
--
--    { 'hello', 'there', 'beautiful' }
--
-- Empty strings between instances of sep are filtered from the return value. The return
-- value if str == nil is nil, and { str } if sep == nil.
--
---@param str string?: the string to split
---@param sep string: the separator on which to split str
---@return string[]?: an array like table of strings comprised of the provided string
-- split wherever the substring sep is encountered; nil if str == nil; { str } if sep == nil
function String.split(str, sep)
  if str == nil then
    return nil
  end

  if sep == nil then
    return { str }
  end

  local split = {}

  for part in string.gmatch(str, '([^'..sep..']+)') do
    table.insert(split, part)
  end

  return split
end


--- str.split w/ sep = '\n' (newline character).
--
---@param str string?: a string to split along '\n' (newline character)
---@return string[]?: a string split along '\n' (newline character)
function String.split_lines(str)
  return String.split(str, '\n')
end


--- Returns true if the provided string is not nil and not empty.
--
---@param str string?: the string to check
---@return true if the provided string is not nil and not empty, false otherwise
function String.not_nil_or_empty(str)
  return str ~= nil and str ~= ''
end


--- Returns true if the provided string nil or empty.
--
---@param str string?: the string to check
---@return true if the provided string is nil or empty, false otherwise
function String.is_nil_or_empty(str)
  return str == nil or str == ''
end


--- Converts arbitrary objects to human-readable strings.
--
--  TODO: add support for functions
--
---@param obj any?: the object to "stringify"
---@return string: the stringified version of the provided object
function String.tostring(obj)
  if type(obj) ~= 'table' or obj == nil then
    return tostring(obj)
  end

  -- if we're here , we're dealing w/ some kind of table; since classes/objects are tables,
  -- check to see if the table has a tostring meta-method; if not, use the home-baked generic
  -- table.tostring function
  return Bool.ternary(
    obj.__tostring == nil,
    function() return Table.tostring(obj) end,
    function() return tostring(obj) end
  )
end


local function do_pad(str, char, len, joiner)
  if len <= #str then
    return str
  end

  local num = len - #str
  local pad = ''

  for _ = 1, num do
    pad = pad .. char
  end

  return joiner(pad)
end


--- Pads the left-hand side of a string (i.e.: the beginning of the string in left-to-right
--  languages) w/ char until the string is len characters. For example:
--
--    String.lpad('hello', '$', 10) == '$$$$$hello'
--
--  If #str >= len, str is returned w/o modifications.
--
---@param str string: the string to pad
---@param char string: the character w/ which to pad str
---@param len integer: the desired length of the string to be returned
---@return string: str padded by char up to length len, or str if #str >= len
function String.lpad(str, char, len)
  return do_pad(str, char, len, function(pad)
    return pad .. str
  end)
end


--- Pads the right-hand side of a string (i.e.: the end of the string in left-to-right
--  languages) w/ char until the string is len characters. For example:
--
--    String.rpad('byebye', '!', 11) == 'byebye!!!!!'
--
--  If #str >= len, str is returned w/o modifications.
--
---@param str string: the string to pad
---@param char string: the character w/ which to pad str
---@param len integer: the desired length of the string to be returned
---@return string: str padded by char up to length len, or str if #str >= len
function String.rpad(str, char, len)
  return do_pad(str, char, len, function(pad)
    return str ..  pad
  end)
end

return String


local Common = require 'toolbox.core.__common'
local Type   = require 'toolbox.meta.type'

local stringify = require 'toolbox.common.stringify'

-- local see = require 'see'


--- TODO: create "Indexable" class that implements python-like indexing for strings
---       see `toolbox.core.string.Indexable`

--- Contains utilities for interacting w/ and manipulating strings.
---
---@class String
local String = {}

--- Checks if o is a string.
---
---@param o any|nil: the object to check
---@return boolean: true if o is a string, false otherwise
function String.is(o)
  return Type.is(o, 'string')
end


---@see Common.String.nil_or_empty
function String.nil_or_empty(...)
  return Common.String.nil_or_empty(...)
end


--- Returns true if the provided string is not nil and not empty.
---
---@param str string?: the string to check
---@return true if the provided string is not nil and not empty, false otherwise
function String.not_nil_or_empty(str)
  return str ~= nil and str ~= ''
end


--- Checks if str contains substr.
---
---@param str string: the string to check for containment of substr
---@param substr string: the substring to check for containment in str
---@return boolean: true if substr is a substring of str, false otherwise
function String.contains(str, substr)
  return string.find(str, substr) ~= nil
end


--- Capitalizes the given string, even if str is all upper-case.
---
---@param str string: the string to capitalize
---@param regularize boolean|nil: optional, defaults to true; if true, the string will be
--- lowercased before being capitalized
---@return string: str, but capitalized
function String.capitalize(str, regularize)
  regularize = Common.Bool.or_default(regularize, true)
  str = Common.Bool.ternary(regularize, str:lower(), str)

  return (str:gsub('^%l', string.upper))
end


---@see string.lower
function String.lower(str)
  return string.lower(str)
end


---@see string.upper
function String.upper(str)
  return string.upper(str)
end


--- Returns true if the provided string starts with the provided prefix, or if str == pfx.
--  false if either str or pfx == nil.
--
---@param str string|nil: the string to check
---@param pfx string|nil: the prefix to check
---@return boolean: true if str starts with pfx or str == pfx; false otherwise, or if either str or
-- pfx == nil or ''
function String.startswith(str, pfx)
  if String.nil_or_empty(str) or String.nil_or_empty(pfx) then
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
-- sfx == nil or ''
function String.endswith(str, sfx)
  if String.nil_or_empty(str) or String.nil_or_empty(sfx) then
        return false
    end

    return #sfx <= #str and str:sub(-#sfx, #str) == sfx
end


--- Get the first word of a multi-word string. This function considers the "first word"
--- to be the leftmost non-whitespace char string left and or right delimited by
--- whitespace. Some examples:
---
---   String.firstword('how do bugaboo?') == 'how'
---   String.firstword("  pretty swell how 'bout you?") == 'pretty'
---   String.firstword('wait\t\t you can talk?') == 'wait'
---   String.firstword('  I\n\t\t can at that') == 'I'
---
---@param str string: the string from which to extract the first word
---@return string|nil: the first, or possible only, word of str, or nil if str is
--- empty
function String.firstword(str)
  return str:match('%S+')
end


--- Trims all occurrences of the char/string "to_trim" from both ends of "str". Some
--- examples:
---
---   String.trim('xxxxxxhello there friendxxxx', 'x') == 'hello there friend'
---   String.trim('byebyehello there friendbyebye', 'bye') == 'hello there friend'
---   String.trim('      no need to say goodbye!       ') == 'no need to say goodbye!'
---
---@param str string: the string to trim
---@param to_trim string|nil: optional, defaults to " " (space); the char/string to trim
--- from str
---@return string: str w/ all occurrences of to_trim removed from both of its ends
function String.trim(str, to_trim)
  to_trim = to_trim or ' '

  return (string.gsub(str, '^' .. to_trim .. '*(.-)' .. to_trim .. '*$', '%1'))
end

local function validate_char(func, char)
  if #char == 0 then
    error(String.fmt('String.trim_before: char cannot be the empty string', func))
  end

  if #char > 1 then
    error(String.fmt('String.%s: #char cannot be > 1 (char="%s")', func, char))
  end

end


--- Trims from the provided string chars from the start of the string up to and including
--  the first occurrence of delim. For example:
--
--    String.trim_before('hi there!', ' ') == 'there!'
--
--  If delim doesn't exist in str, str is returned unchanged.
--
---@param str string: the string to trim
---@param delim string: the char to trim chars before
---@return string: str w/ chars trimmed from start to first occurrence of delim, or str
-- if delim isn't present in str
function String.trim_before(str, delim)
  validate_char('trim_before', delim)

  local idx = string.find(str, delim, 1, true)

  if idx == nil then
    return str
  end

  return string.sub(str, idx + 1, #str)
end


--- Trims from the provided string chars from the first occurrence of delim (including
--  delim) to the end of str. For example:
--
--    String.trim_after('hi there!', ' ') == 'hi'
--
--  If delim doesn't exist in str, str is returned unchanged.
--
---@param str string: the string to trim
---@param delim string: the char/string to trim chars after
---@return string: str w/ chars trimmed from first occurrence of delim to its end, or str
-- if delim isn't present in str
function String.trim_after(str, delim)
  validate_char('trim_after', delim)

  local idx = string.find(str, delim, 1, true)

  if idx == nil then
    return str
  end

  return string.sub(str, 1, idx - 1)
end


--- Given an array-like table of strings and a char/string separator, this function joins
--  the array w/ the separator. For example:
--
--    String.join({ 'hello', 'bonjour', 'sayonara' }, '!hi!') == 'hello!hi!bonjour!hi!sayonara'
--
---@param arr string[]: the array to join
---@param sep string|nil: the separator to use to join arr; optional, defaults to ", "
---@return string: a string comprised of the contents of arr joined by sep
function String.join(arr, sep)
  return String.rjoin(arr, { sep })
end

--- Internal helper that tracks and computes the various indices used during recursive
--  joins.
--
---@class RJoinCursor
---@field level integer: recursion depth
---@field si integer: current index in the separators array
---@field li integer: current index in the ldelims array
---@field ri integer: current index in the rdelims array
---@field len_j integer: len of separators array
---@field len_ld integer: len of ldelims array
---@field len_rd integer: len of rdelims array
local RJoinCursor = {}
RJoinCursor.__index = RJoinCursor

function RJoinCursor.new(separators, ldelims, rdelims)
  return setmetatable({
    level  = 0,
    si     = 0,
    li     = 0,
    ri     = 0,
    len_j  = #separators,
    len_ld = #ldelims,
    len_rd = #rdelims,
  }, RJoinCursor)
end


function RJoinCursor:inc()
  self.level = self.level + 1

  self.si = Common.Num.bounds(self.level, 1, self.len_j)
  self.li = Common.Num.bounds(self.level, 1, self.len_ld)
  self.ri = Common.Num.bounds(self.level, 1, self.len_rd)

  return self
end

--- Internal class that exists so would-be local methods can use mutual recursion.
--
---@class RecursiveJoin
local RecursiveJoin = {}

function RecursiveJoin.element(element, separators, ldelims, rdelims, cursor)
  if Type.is(element, 'table') then
    return RecursiveJoin.array(element, separators, ldelims, rdelims, cursor:inc())
  elseif Type.is(element, 'string') then
    return element
  end

  local element_str = tostring(element)

  error(
    'String.rjoin: element=' .. element_str .. ' is of unrecognized type=' .. Type.of(element)
  )
end


function RecursiveJoin.array(arr, separators, ldelims, rdelims, cursor)
  local si, li, ri = cursor.si, cursor.li, cursor.ri

  if #arr == 0 then
    return ldelims[li] .. '' .. rdelims[ri]
  end

  local str = ldelims[li] .. RecursiveJoin.element(
    arr[1], separators, ldelims, rdelims, cursor
  )

  for i=2,#arr do
    local element = RecursiveJoin.element(arr[i], separators, ldelims, rdelims, cursor)
    str = str .. separators[si] .. element
  end

  return str .. rdelims[ri]
end


--- Recursively join strings. Given an array-like table of strings/array-like tables,
--- this function will recursively join the strings in arr and its sub-arrays w/
--- separators[i], where i is the level of recursion depth, and where i will never exceed
--- #separators. Additionally, strings comprised of contents of sub-arrays will be bounded
--- by delimiters in ldelims and rdelims. For example:
---
---   String.rjoin(
---    { 'a', 'b', { 'c', { 'd', 'e' }}, 'f' },
---    { ',', '|' },
---    { '()' }, { ')' }) ==
---   'a,b,(c|(d|e),f)'
---
---
---@param arr (string|string[])[]: the array-like table to recursively join
---@param separators string[]|nil: the chars/strings to use to join strings in
--- arrays/sub-arrays; optional, defaults to { ', ' }
---@param ldelims string[]|nil: the left delimiters of strings comprised of sub-array
--- elements; optional, defaults to { '', '(' }
---@param rdelims string[]|nil the right delimiters of strings comprised of sub-array
--- elements; optional, defaults to { '', ')' }
---@return string: a string comprised of string/sub-array elements of arr
function String.rjoin(arr, separators, ldelims, rdelims)
  separators = Common.Bool.ternary(Common.Table.nil_or_empty(separators), { ', ' },     separators)
  ldelims    = Common.Bool.ternary(Common.Table.nil_or_empty(ldelims),    { '', '(' },  ldelims)
  rdelims    = Common.Bool.ternary(Common.Table.nil_or_empty(rdelims),    { '', ')' },  rdelims)

  local cursor = RJoinCursor.new(separators, ldelims, rdelims)
  return RecursiveJoin.array(arr, separators, ldelims, rdelims, cursor:inc())
end


--- Splits into an array-like table the provided string wherever "sep" is encountered in
--  that string. For example, the following call:
--
--    String.split('helloxxxtherexxxbeautiful', 'xxx')
--
--  Would result in the following return value:
--
--    { 'hello', 'there', 'beautiful' }
--
-- Empty strings between instances of sep are filtered from the return value. The return
-- value if sep == nil is { str }.
--
---@param str string: the string to split
---@param sep string: the separator on which to split str
---@return string[]: an array like table of strings comprised of the provided string
-- split wherever the substring sep is encountered; { str } if sep == nil
function String.split(str, sep)
  if sep == nil then
    return { str }
  end

  local split = {}

  for part in string.gmatch(str, '([^'..sep..']+)') do
    table.insert(split, part)
  end

  return split
end


--- String.split w/ sep = '\n' (newline character).
---
---@param str string?: a string to split along '\n' (newline character)
---@return string[]?: a string split along '\n' (newline character)
function String.split_lines(str)
  return String.split(str, '\n')
end


--- Converts arbitrary objects to human-readable strings.
---
---@see toolbox.common.stringify
function String.tostring(...)
  return stringify(...)
end


local function do_pad(func, str, char, len, joiner)
  validate_char(func, char)

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
  return do_pad('lpad', str, char, len, function(pad)
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
  return do_pad('rpad', str, char, len, function(pad)
    return str ..  pad
  end)
end


---@see Common.String.fmt
function String.fmt(base, ...)
  return Common.String.fmt(base, ...)
end

return String


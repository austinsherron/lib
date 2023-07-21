
-- TODO: create "Indexable" class that implements python-like indexing for strings
--       see `lib.lua.core.string.Indexable`

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
---@param str string: a string to split along '\n' (newline character)
---@return table?: a string split along '\n' (newline character)
function String.split_lines(str)
  return String.split(str, '\n')
end

return String


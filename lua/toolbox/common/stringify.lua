
local fmt = string.format

local function nil_or_empty(string)
  return string == nil or string == ''
end

---@note: this exists so local functions can use mutual recursion
local Stringify = {}

function Stringify.maybe_table(maybe_tbl, o, c, sep, seen)
  -- if Common.Table.is(maybe_tbl) and seen[maybe_tbl] ~= nil then
  --   return 'CYCLE'
  -- elseif Common.Table.is(maybe_tbl) then
  if type(maybe_tbl) == 'table' then
    seen[maybe_tbl] = true
    return Stringify.table(maybe_tbl, o, c, sep, seen)
  end

  return tostring(maybe_tbl)
end


--- Recursively constructs a string representation of the provided table. Non-table
--- constituents are "stringified" using the builtin "tostring" function.
---
---@param tbl table|nil: the table for which to construct a string representation
---@param o string|nil: optional, defaults to '{'; defaults to the opening "brace" of the
--- string representation
---@param c string|nil: optional, defaults to '}'; the closing "brace" of the string
--- representation
---@param sep string|nil: optional, defaults to ', '; separates elements of the table in
--- the string representation
---@return string: a string representation of the provided table
function Stringify.table(tbl, o, c, sep, seen)
  seen = seen or {}

  if tbl == nil then
    return ''
  end

  ---@note: since classes/objects are tables, check to see if the table has a tostring
  --- meta-method; if not, use the home-baked generic table.tostring function
  if tbl.__tostring ~= nil then
    return tostring(tbl)
  end

  seen[tbl] = true
  sep = sep or ', '

  local str = ''; local arr_str = ''
  local i = 1; local j = 1

  for k, v in pairs(tbl) do
    local key_str = Stringify.maybe_table(k, o, c, sep, seen)
    local val_str = Stringify.maybe_table(v, o, c, sep, seen)

    local nxt = (i == 1 and '' or sep) .. key_str .. ' = ' .. val_str
    str = str .. nxt
    i = i + 1

    if arr_str ~= nil and tbl[j] ~= nil then
      nxt = (j == 1 and '' or sep) .. Stringify.maybe_table(v, o, c, sep, seen)
      arr_str = arr_str .. nxt
      j = j + 1
    elseif arr_str ~= nil then
      ---@diagnostic disable-next-line: cast-local-type
      arr_str, j = nil, nil
    end
  end

  o = o or '{'
  c = c or '}'

  if nil_or_empty(arr_str) and nil_or_empty(str) then
    return o .. c
  end

  return fmt('%s %s %s', o, arr_str or str, c)
end


---@private
---@diagnostic disable-next-line: unused-local
function Stringify.func(obj)
  -- TODO: 'see' seems pretty powerful; explore it a bit to see what more we can do w/ it
  return 'function(?)' -- String.trim_after(tostring(see(obj)), ' {')
end


--- Converts arbitrary objects to human-readable strings.
---
--- When obj is a table, recursively constructs a string representation the table using
--- the builtin tostring function on non-table constituents or on tables that are found to
--- have a custom implementation of tostring.
---
--- When object is a function, TODO.
---
---@param obj any|nil: the object to "stringify"
---@param o string|nil: optional, defaults to '{'; only used when stringifying tables; the
--- opening brace of the string representation of a table
---@param c string|nil: optional, defaults to '}'; only used when stringifying tables; the
--- closing brace of the string representation of a table
---@param sep string|nil: optional, defaults to ', '; only used when stringifying tables;
--- separates elements in the string representation a table
---@return string: the stringified version of the provided object
return function(obj, o, c, sep)
  if type(obj) == 'table' then
    return Stringify.table(obj, o, c, sep)
  elseif type(obj) == 'function' then
    return Stringify.func(obj)
  end

  return tostring(obj)
end


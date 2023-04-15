--!/usr/bin/lua

require 'lib.lua.num'


function table.keys(tbl, transform)
    out = {}
    transform = transform or function(k) return k end

    for k, _ in pairs(tbl) do 
      table.insert(out, transform(k))
    end

    return out
end


function table.values(tbl, transform)
    out = {}
    transform = transform or function(v) return v end

    for _, v in pairs(tbl) do 
      table.insert(out, transform(v))
    end

    return out
end


function table.map_items(tbl, transforms)
    transform_k = transforms.keys or function(k) return k end
    transform_v = transforms.values or function(v) return v end

    out = {}

    for k, v in pairs(tbl) do 
      out[transform_k(k)] = transform_v(v)
    end

    return out
end


function table.map_keys(tbl, transform)
  return table.map_items(tbl, {keys = transform})
end


function table.map_values(tbl, transform)
  return table.map_items(tbl, {values = transform})
end


function table.shallow_copy(tbl)
    local new = {}
    for k, v in pairs(tbl) do new[k] = v end
    return new
end


function table.tostring(tbl)
  if (tbl == nil) then
    return ''
  end

  local str = '' ; local arr_str = ''
  local i = 1 ; local j = 1

  for k, v in pairs(tbl) do
    local nxt = (i == 1 and '' or ', ') .. tostring(k) .. ' = ' .. tostring(v)
    str = str .. nxt
    i = i + 1

    if (arr_str ~= nil and tbl[j] ~= nil) then
      local nxt = (j == 1 and '' or ', ') .. tostring(v)
      arr_str = arr_str .. nxt
      j = j + 1
    elseif (arr_str ~= nil) then
      arr_str, j = nil, nil
    end
  end

  return '{ ' .. (arr_str or str) .. ' }'
end


function table.is_array(tbl)
  local i = 0

  for _ in pairs(tbl) do
    i = i + 1

    if (t[i] == nil) then
      return false
    end   -- end if nil
  end     -- end for in tbl

  return true
end


function table.is_array__fast(tbl)
  return tbl[1] ~= nil and tbl[#tbl] ~= nil
end


function table.merge(l, r)
  for k, v in pairs(r) do
    l[k] = v
  end
end


-- function table.concat(...)
--   local all = table.pack(...)
--   local new = {}
--   local i = 1
-- 
--   for _, t in ipairs(all) do
--     for _, v in ipairs(t) do
--       new[i] = v
--       i = i + 1
--     end
--   end
-- 
--   return new
-- end


function table.combine(l, r)
  if (l == nil and r == nil) then
    return {}
  elseif (l == nil) then
    return r
  elseif (r == nil) then
    return l
  end

  local new = table.shallow_copy(l)

  table.merge(new, r)

  return new
end


function table.combine_many(tbls)
    local combined = {}

    if (tbls == nil) then
        return combined
    end

    for i, tbl in ipairs(tbls) do
        table.merge(combined, tbl)
    end

    return combined
end


-- note: this function will fail if tbl contains nil values
function table.reverse_items(tbl, fail_on_dup)
    local fail_on_dup = fail_on_dup or false
    local rev = {}

    for k, v in pairs(tbl) do
        if (rev[v] ~= nil and fail_on_dup) then
            error('duplicate value=' .. v .. ' encountered in table')
        end
        
        rev[v] = k
    end 
    return rev
end


function table.slice(tbl, s, e)
    if (tbl == nil or #tbl == 0) then
        return {}
    end

    local s = bounds(s, 1, #tbl)
    local e = bounds(e, 1, #tbl)

    if (s > e) then
        error('Invalid params: start = ' .. tostring(s) .. ' > end = ' .. tostring(e))
    end

    local slice = {}

    for i = s or 1, e or #tbl, 1 do
        local j = #slice + 1
        slice[j] = tbl[i]
    end

    return slice
end


function table.filter(tbl, filter)
  local out = {}

  for _, item in ipairs(tbl) do
    if (filter(item)) then
      table.insert(out, item)
    end
  end

  return out
end


function table.map(tbl, mapper)
  local out = {}

  for _, item in ipairs(tbl) do
    table.insert(out, mapper(item))
  end

  return out
end


function table.array_combine(l, r)
  local new = table.shallow_copy(l)

  for _, item in ipairs(r) do
    table.insert(new, item)
  end

  return new
end


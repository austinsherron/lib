--!/usr/bin/lua


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


function table.combine(l, r)
  local new = table.shallow_copy(l)

  table.merge(new, r)

  return new
end


function table.combine_many(tbls)
    local combined = {}

    if (tbls == nil) then
        return combined
    end

    for _, tbl in ipairs(tbls) do
        table.merge(combined, tbl)
    end

    return combined
end


-- note: this function will fail if tbl contains nil values
function reverse_items(tbl, fail_on_dup)
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



function string.startswith(str, pfx)
    if (str == nil or pfx == nil) then
        return false
    end

    return #pfx <= #str and str:sub(1, #pfx) == pfx
end

function string.endswith(str, sfx)
    if (str == nil or sfx == nil) then
        return false
    end

    return #sfx <= #str and str:sub(-#sfx, #str) == sfx
end


function string.split(str, sep)
  local lines = {}

  for line in str:gmatch('([^' .. sep .. ']*)' .. sep .. '?') do
    table.insert(lines, line)
  end

  return lines
end


function string.split_lines(str)
  return string.split(str, '\n')
end


-- local function test()
--     -- startswith
--     assert(string.startswith('some', 'something') == false)
--     assert(string.startswith('something', 'some') == true)
--     assert(string.startswith('something', 'xxx') == false)
--     assert(string.startswith(nil, 'xxx') == false)
--     assert(string.startswith('xxx', nil) == false)
--
--     -- endswith
--     assert(string.endswith('thing', 'something') == false)
--     assert(string.endswith('something', 'thing') == true)
--     assert(string.endswith('something', 'xxx') == false)
--     assert(string.endswith(nil, 'xxx') == false)
--     assert(string.endswith('xxx', nil) == false)
-- end



-- TODO: seems like there'd be a more better (lol, typo) (i.e.: more portable/general) 
--       way to do this
function get_config_path()
    return os.getenv('HOME') .. '/.config'
end


local function update_pkg_path(paths)
    if (paths == nil or #paths == 0) then
        return
    end

    for _, path in ipairs(paths) do
        package.path = package.path .. ';' .. path
    end
end


local function make_lua_path(base_path)
    return base_path .. '/?.lua'
end


local function make_init_path(base_path)
    return base_path .. '/?/init.lua'
end


function add_module_to_lua_path(module_path)
    update_pkg_path({ make_lua_path(module_path), make_init_path(module_path) })
end


-- sourced from https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file
function script_path()
   local str = debug.getinfo(2, 'S').source:sub(2)
   return str:match('(.*/)')
end


-- sourced from https://stackoverflow.com/questions/18884396/extracting-filename-only-with-pattern-matching
function trim_extension(filename)
  return filename:match('(.+)%..+')
end



-- TODO: seems like there'd be a more better (lol, typo) (i.e.: more portable/general) 
--       way to do this
function get_config_path()
    return os.getenv('HOME') .. '/.config'
end


local function update_pkg_path(paths)
    if (paths == nil or #paths == 0) then
        return 
    end

    package.path = package.path .. paths[1]

    if (#paths == 1) then
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


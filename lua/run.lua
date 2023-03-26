
function run(cmd)
    return os.execute(cmd)
end


function git_clone(url, path)
    local cmd = string.format("[ -e '%s' ] || git clone '%s' '%s'", path, url, path)
    return run(cmd)
end




function Set.equals(l, r)
    if (#l ~= #r) then
        return false
    end

    for k, _ in pairs(l) do
        if (r[k] == nil) then
            return false
        end
    end

    return true
end


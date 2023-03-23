
function test(test_func)
    if not pcall(debug.getlocal, 4, 1) then
        return
    end

    test_func()
end

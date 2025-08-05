local TestEZ = {}

function TestEZ.describe(name, fn)
    print("[DESCRIBE] " .. name)
    fn()
end

function TestEZ.it(name, fn)
    local ok, err = pcall(fn)
    if ok then
        print("[PASS] " .. name)
    else
        print("[FAIL] " .. name .. ": " .. err)
    end
end

function TestEZ.itSKIP(name)
    print("[SKIP] " .. name)
end

return TestEZ

local failures = 0

function expect(actual)
    return {
        to = {
            equal = function(expected)
                if actual ~= expected then error("expected "..tostring(expected).." got "..tostring(actual)) end
            end,
            be = {
                greaterThan = function(value)
                    if actual <= value then error("expected > "..tostring(value)..", got "..tostring(actual)) end
                end,
                ok = function()
                    if not actual or actual == 0 then error("expected value to be truthy") end
                end
            }
        }
    }
end

function it(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        print("Test failed: "..name..": "..err)
        failures = failures + 1
    end
end

function describe(name, fn)
    fn()
end

local spec = dofile("tests/tests/TestEZ/init.spec.lua")
spec()

if failures > 0 then
    os.exit(1)
else
    print("All tests PASS")
end

local TestEZ = require('ServerScriptService.Tests.TestEZ')

return function()
    TestEZ.describe('Test B', function()
        TestEZ.it('passes', function()
            assert(true)
        end)
    end)
end

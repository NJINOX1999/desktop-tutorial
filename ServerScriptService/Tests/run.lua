package.path = package.path .. ';./?/init.lua;./?.lua'

local tests = {
    require('ServerScriptService.Tests.testA_spec'),
    require('ServerScriptService.Tests.testB_spec'),
    require('ServerScriptService.Tests.testC_spec'),
    require('ServerScriptService.Tests.testD_spec'),
    require('ServerScriptService.Tests.testE_spec'),
}

for _, test in ipairs(tests) do
    test()
end

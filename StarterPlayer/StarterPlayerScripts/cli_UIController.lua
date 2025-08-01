--[[
    Simple UI controller starting client scripts
]]

local UIController = {}
local Input = require(script.Parent.cli_Input)

function UIController.init()
    Input.init()
end

return UIController

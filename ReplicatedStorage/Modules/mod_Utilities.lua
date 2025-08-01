--[[
    Shared utility functions.
]]

local Utilities = {}

function Utilities.printTable(tbl)
    for k, v in pairs(tbl) do
        print(k, v)
    end
end

return Utilities

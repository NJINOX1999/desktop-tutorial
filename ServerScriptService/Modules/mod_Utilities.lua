-- Shared utility functions
local Utilities = {}

function Utilities.printTable(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        print(string.rep(' ', indent) .. k, v)
    end
end

return Utilities

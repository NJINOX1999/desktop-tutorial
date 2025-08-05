-- Shared utility functions
local Utilities = {}

function Utilities.printTable(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        print(string.rep(' ', indent) .. k, v)
    end
end

function Utilities.addXP(player, amount)
    local Config = require(game:GetService('ReplicatedStorage').Config)
    local LevelService = require(script.Parent.mod_LevelService)
    local data = player._data
    if data then
        local diff = Config.DifficultyModifiers[Config.Difficulty]
        local mult = diff and diff.XP or 1
        data.XP = (data.XP or 0) + math.floor(amount * mult)
        player:SetAttribute('XP', data.XP)
        LevelService.check(player)
    end
end

return Utilities

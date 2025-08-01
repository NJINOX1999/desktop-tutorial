local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Config = require(ReplicatedStorage.Modules.mod_Config)

local LevelService = {}

function LevelService.check(player)
    local data = player._data
    if not data then return end
    local level = data.Level or 1
    local xp = data.XP or 0
    local nextXp = Config.LevelXP[level]
    local leveled = false
    while nextXp and xp >= nextXp do
        xp = xp - nextXp
        level = level + 1
        nextXp = Config.LevelXP[level]
        leveled = true
    end
    data.Level = level
    data.XP = xp
    if leveled then
        -- expand turret limit via attribute for BuildHandler
        player:SetAttribute('Level', level)
    end
end

return LevelService

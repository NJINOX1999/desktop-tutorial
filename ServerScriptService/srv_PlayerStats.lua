--!nolint UnknownType

-- Grants XP on monster kills and updates player level/tower limit
local Players = game:GetService('Players')
local Utilities = require(script.Parent.Modules.mod_Utilities)
local Config = require(game:GetService('ReplicatedStorage').Config)

local function updateLimit(plr)
    local level = plr:GetAttribute('Level') or 1
    plr:SetAttribute('TowerLimit', Config.BaseTurretLimit + math.max(0, level - 1))
end

Players.PlayerAdded:Connect(function(plr)
    local data = plr._data or {Level = 1}
    plr:SetAttribute('Level', data.Level)
    updateLimit(plr)
    plr:GetAttributeChangedSignal('Level'):Connect(function()
        updateLimit(plr)
    end)
end)

_G.EventBus.Bind('MonsterKilled', function(plr, xp)
    if typeof(plr) ~= 'Instance' then return end
    Utilities.addXP(plr, xp or 0)
    updateLimit(plr)
end)

return {}

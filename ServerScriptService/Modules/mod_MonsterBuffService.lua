local ReplicatedStorage = game:GetService('ReplicatedStorage')
local cfgModule = ReplicatedStorage.Modules.mod_Config
local Config = type(cfgModule) == 'table' and cfgModule or require(cfgModule)

local MonsterBuffService = {}

function MonsterBuffService.apply(monster)
    if not _G.crystalLost then
        return
    end
    local hum = monster:FindFirstChildOfClass('Humanoid')
    if hum then
        hum.WalkSpeed = hum.WalkSpeed * Config.CrystalBuffMultiplier
        hum.MaxHealth = hum.MaxHealth * Config.CrystalBuffMultiplier
        hum.Health = hum.MaxHealth
    end
    local dmgMul = monster:GetAttribute('DamageMul') or 1
    monster:SetAttribute('DamageMul', dmgMul * Config.CrystalBuffDamageMultiplier)
end

return MonsterBuffService


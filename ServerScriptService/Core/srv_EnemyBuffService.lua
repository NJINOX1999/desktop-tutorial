local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Config = require(ReplicatedStorage.Modules.mod_Config)

local EnemyBuffService = {}
EnemyBuffService.BoostActive = false

function EnemyBuffService.Apply(monster)
    if not EnemyBuffService.BoostActive then
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

_G.EnemyBuffService = EnemyBuffService
return EnemyBuffService

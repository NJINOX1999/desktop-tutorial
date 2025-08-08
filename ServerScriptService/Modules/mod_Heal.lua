local cfgModule = game:GetService('ReplicatedStorage').Modules.mod_Config
local Config = type(cfgModule) == 'table' and cfgModule or require(cfgModule)

local Heal = {}
local cooldowns = {}

local function distance(a, b)
    local pa = a.Position
    local pb = b.Position
    local dx = (pa.X - pb.X)
    local dy = (pa.Y - pb.Y)
    local dz = (pa.Z - pb.Z)
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function Heal.tryHeal(healer, target)
    if not healer or not target then
        return false
    end
    if cooldowns[target] and os.clock() - cooldowns[target] < Config.HealCooldown then
        return false
    end
    if not (healer.Character and target.Character) then
        return false
    end
    local hhrp = healer.Character:FindFirstChild('HumanoidRootPart')
    local thrp = target.Character:FindFirstChild('HumanoidRootPart')
    local hum = target.Character:FindFirstChildOfClass('Humanoid')
    if not (hhrp and thrp and hum) then
        return false
    end
    if hum.Health <= 0 then
        return false
    end
    if hum.Health > hum.MaxHealth * 0.5 then
        return false
    end
    if distance(hhrp, thrp) > 10 then
        return false
    end
    hum.Health = math.min(hum.MaxHealth * 0.5, hum.Health + hum.MaxHealth * 0.5)
    cooldowns[target] = os.clock()
    return true
end

return Heal


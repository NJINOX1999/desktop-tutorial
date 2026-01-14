local Players = game:GetService("Players")

local CombatService = {}

function CombatService.new(config)
    local self = {
        Config = config,
        Cooldowns = {},
    }

    return setmetatable(self, { __index = CombatService })
end

local function isAlive(humanoid)
    return humanoid and humanoid.Health > 0
end

function CombatService:canAttack(player)
    local last = self.Cooldowns[player] or 0
    return os.clock() - last >= self.Config.Combat.Cooldown
end

function CombatService:markAttack(player)
    self.Cooldowns[player] = os.clock()
end

function CombatService:getTargets(attacker)
    local character = attacker.Character
    if not character then
        return {}
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return {}
    end

    local hitbox = Instance.new("Part")
    hitbox.Size = self.Config.Combat.HitboxSize
    hitbox.CFrame = root.CFrame * self.Config.Combat.HitboxOffset
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Anchored = true
    hitbox.Parent = workspace

    local targets = {}
    for _, part in ipairs(workspace:GetPartsInPart(hitbox)) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model ~= character then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local player = Players:GetPlayerFromCharacter(model)
            if humanoid and player and isAlive(humanoid) then
                targets[player] = humanoid
            end
        end
    end

    hitbox:Destroy()

    local list = {}
    for player, humanoid in pairs(targets) do
        table.insert(list, { Player = player, Humanoid = humanoid })
    end

    return list
end

function CombatService:applyDamage(attacker, targetHumanoid)
    targetHumanoid:TakeDamage(self.Config.Combat.BaseDamage)

    local root = targetHumanoid.Parent:FindFirstChild("HumanoidRootPart")
    if root then
        local force = Instance.new("BodyVelocity")
        force.Velocity = (root.Position - attacker.Character.HumanoidRootPart.Position).Unit
            * self.Config.Combat.Knockback
        force.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        force.Parent = root
        game:GetService("Debris"):AddItem(force, 0.15)
    end
end

return CombatService

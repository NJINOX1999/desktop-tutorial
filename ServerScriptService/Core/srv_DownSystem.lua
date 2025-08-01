local Players = game:GetService('Players')
local Config = require(game:GetService('ReplicatedStorage').Modules.mod_Config)
local Remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')
local RE_RequestRevive = Remotes:WaitForChild('RE_RequestRevive')
local RE_RequestHeal = Remotes:WaitForChild('RE_RequestHeal')

local downed = {}
local reviveActions = {}
local healCooldowns = {}

local function onCharacterAdded(player, char)
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    hum.Died:Connect(function()
        if downed[player] then return end
        downed[player] = {timer = os.clock()}
        hum.Health = 1
        hum.PlatformStand = true
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        onCharacterAdded(plr, char)
    end)
end)

RE_RequestRevive.OnServerEvent:Connect(function(healer, target)
    if typeof(target) ~= 'Instance' or not target:IsA('Player') then return end
    local info = downed[target]
    if not info then return end
    if (healer.Character and healer.Character:FindFirstChild('HumanoidRootPart')
        and target.Character and target.Character:FindFirstChild('HumanoidRootPart')) then
        if (healer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude < 6 then
            task.delay(Config.ReviveTime, function()
                revive(target, healer)
            end)
        end
    end
end)

RE_RequestHeal.OnServerEvent:Connect(function(healer, target)
    if healCooldowns[healer] and os.clock() - healCooldowns[healer] < Config.HealCooldown then return end
    if target and target.Character and target.Character:FindFirstChildOfClass('Humanoid') then
        local hum = target.Character.Humanoid
        local start = os.clock()
        task.delay(Config.HealTime, function()
            if os.clock() - start >= Config.HealTime and hum.Health > 0 then
                hum.Health = hum.MaxHealth
                healCooldowns[healer] = os.clock()
            end
        end)
    end
end)

local function revive(target, healer)
    local info = downed[target]
    if not info then return end
    downed[target] = nil
    if target.Character and target.Character:FindFirstChildOfClass('Humanoid') then
        local h = target.Character.Humanoid
        h.PlatformStand = false
        h.Health = h.MaxHealth
    end
end

_G.EventBus.Bind('Heartbeat', function()
    for plr, info in pairs(downed) do
        if os.clock() - info.timer > Config.DownTime then
            if plr.Character then
                plr.Character:BreakJoints()
            end
            downed[plr] = nil
        end
    end
end)

return {}

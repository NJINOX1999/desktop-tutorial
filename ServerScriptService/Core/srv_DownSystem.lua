local Players = game:GetService('Players')
Players.CharacterAutoLoads = false
local Config = require(game:GetService('ReplicatedStorage').Modules.mod_Config)
local Crystal = require(script.Parent.Parent.Modules.mod_Crystal)
local Remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')
local RE_RequestRevive = Remotes:WaitForChild('RE_RequestRevive')
local RE_RequestHeal = Remotes:WaitForChild('RE_RequestHeal')
local RE_PlayerSpawnRequest = Remotes:WaitForChild('RE_PlayerSpawnRequest')

local downed = {}
local reviveActions = {}
local Heal = require(script.Parent.Parent.Modules.mod_Heal)

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

local function onCharacterAdded(player, char)
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    hum.Died:Connect(function()
        if downed[player] then return end
        downed[player] = {timer = os.clock()}
        hum.Health = 1
        hum.PlatformStand = true
        if Crystal:ShouldGameOver() then
            _G.EventBus.Fire('GameOver')
        end
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        onCharacterAdded(plr, char)
    end)
end)

RE_PlayerSpawnRequest.OnServerEvent:Connect(function(plr)
    if workspace:FindFirstChild('Crystal') then
        plr:LoadCharacter()
    end
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
    Heal.tryHeal(healer, target)
end)

_G.EventBus.Bind('Heartbeat', function()
    for plr, info in pairs(downed) do
        if os.clock() - info.timer > Config.DownTime then
            if _G.Buyback and _G.Buyback.Capture then
                _G.Buyback.Capture(plr)
            end
            if plr.Character then
                plr.Character:BreakJoints()
            end
            downed[plr] = nil
            if Crystal:ShouldGameOver() then
                _G.EventBus.Fire('GameOver')
            end
        end
    end
end)

return {}

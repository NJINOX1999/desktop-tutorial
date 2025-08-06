local Players = game:GetService('Players')
Players.CharacterAutoLoads = false
local Config = require(game:GetService('ReplicatedStorage').Modules.mod_Config)
local Remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')
local RE_StartHeal = Remotes:WaitForChild('RE_StartHeal')
local RE_StopHeal = Remotes:WaitForChild('RE_StopHeal')
local RE_PlayerSpawnRequest = Remotes:WaitForChild('RE_PlayerSpawnRequest')

local downed = {}
local actions = {}
local healCooldowns = {}

local function revive(target)
    local info = downed[target]
    if not info then return end
    downed[target] = nil
    if target.Character and target.Character:FindFirstChildOfClass('Humanoid') then
        local h = target.Character.Humanoid
        h.PlatformStand = false
        h.Health = h.MaxHealth
    end
end

local function startRevive(healer, target)
    if healer == target or downed[healer] or not downed[target] then return end
    if not (healer.Character and target.Character) then return end
    local hRoot = healer.Character:FindFirstChild('HumanoidRootPart')
    local tRoot = target.Character:FindFirstChild('HumanoidRootPart')
    if not hRoot or not tRoot then return end
    if (hRoot.Position - tRoot.Position).Magnitude > 10 then return end
    actions[healer] = {target = target, start = os.clock(), mode = 'revive'}
end

local function tryHeal(healer, target)
    if healer == target or downed[healer] or downed[target] then return end
    if healCooldowns[target] and os.clock() - healCooldowns[target] < Config.HealCooldown then return end
    if not (healer.Character and target.Character) then return end
    local hRoot = healer.Character:FindFirstChild('HumanoidRootPart')
    local tRoot = target.Character:FindFirstChild('HumanoidRootPart')
    local hum = target.Character:FindFirstChildOfClass('Humanoid')
    if not hRoot or not tRoot or not hum then return end
    if hum.Health <= 0 or hum.Health >= hum.MaxHealth * 0.5 then return end
    if (hRoot.Position - tRoot.Position).Magnitude > 10 then return end
    actions[healer] = {target = target, start = os.clock(), mode = 'heal'}
end

local function onCharacterAdded(player, char)
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    hum.Died:Connect(function()
        if downed[player] then return end
        downed[player] = {timer = os.clock()}
        hum.Health = 1
        hum.PlatformStand = true
        -- game loop will handle game over when all players are down and crystal is destroyed
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

RE_StartHeal.OnServerEvent:Connect(function(healer, target)
    if typeof(target) ~= 'Instance' or not target:IsA('Player') then return end
    if downed[target] then
        startRevive(healer, target)
    else
        tryHeal(healer, target)
    end
end)

RE_StopHeal.OnServerEvent:Connect(function(healer)
    actions[healer] = nil
end)

_G.EventBus.Bind('Heartbeat', function()
    for healer, action in pairs(actions) do
        local target = action.target
        if not target or not target.Character or not healer.Character then
            actions[healer] = nil
        else
            local hRoot = healer.Character:FindFirstChild('HumanoidRootPart')
            local tRoot = target.Character:FindFirstChild('HumanoidRootPart')
            local hum = target.Character:FindFirstChildOfClass('Humanoid')
            if not hRoot or not tRoot or not hum then
                actions[healer] = nil
            elseif (hRoot.Position - tRoot.Position).Magnitude > 10 then
                actions[healer] = nil
            elseif action.mode == 'revive' then
                if not downed[target] then
                    actions[healer] = nil
                elseif os.clock() - action.start >= Config.ReviveTime then
                    revive(target)
                    actions[healer] = nil
                end
            else
                if downed[target] or hum.Health <= 0 then
                    actions[healer] = nil
                elseif os.clock() - action.start >= Config.HealTime then
                    hum.Health = math.min(hum.Health + hum.MaxHealth * 0.5, hum.MaxHealth * 0.5)
                    healCooldowns[target] = os.clock()
                    actions[healer] = nil
                end
            end
        end
    end

    for plr, info in pairs(downed) do
        if os.clock() - info.timer > Config.DownTime then
            if _G.Buyback and _G.Buyback.Capture then
                _G.Buyback.Capture(plr)
            end
            if plr.Character then
                plr.Character:BreakJoints()
            end
            downed[plr] = nil
        end
    end
end)

return {}

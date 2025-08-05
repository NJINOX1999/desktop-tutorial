--!nolint UnknownType

-- Manages player down state, revives and coin-based buyback respawns
local Players = game:GetService('Players')
Players.CharacterAutoLoads = false

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Config = require(ReplicatedStorage:WaitForChild('Config'))
local Crystal = require(script.Parent.Modules.mod_Crystal)
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')

local RE_RequestRevive = RemoteEvents:WaitForChild('RE_RequestRevive')
local RE_RequestHeal = RemoteEvents:WaitForChild('RE_RequestHeal')
local RE_PlayerSpawnRequest = RemoteEvents:WaitForChild('RE_PlayerSpawnRequest')
local RE_RequestBuyback = RemoteEvents:WaitForChild('RE_RequestBuyback')
local RE_ShowBuybackRespawn = RemoteEvents:WaitForChild('RE_ShowBuybackRespawn')
local RE_UpdateCoins = RemoteEvents:WaitForChild('RE_UpdateCoins')

local downed = {}
local healCooldowns = {}
local dead = {}

local function revive(target)
    local info = downed[target]
    if not info then return end
    downed[target] = nil
    if info.hum then
        info.hum.PlatformStand = false
        info.hum.WalkSpeed = info.ws or 16
        info.hum.JumpPower = info.jp or 50
        info.hum.Health = info.hum.MaxHealth
    end
end

local function setDown(plr, hum)
    if downed[plr] then return end
    downed[plr] = {timer = os.clock(), hum = hum, ws = hum.WalkSpeed, jp = hum.JumpPower}
    hum.Health = 1
    hum.PlatformStand = true
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    dead[plr] = nil
end

local function onCharacterAdded(plr, char)
    dead[plr] = nil
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    hum.Died:Connect(function()
        if downed[plr] then return end
        setDown(plr, hum)
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

Players.PlayerRemoving:Connect(function(plr)
    downed[plr] = nil
    dead[plr] = nil
    healCooldowns[plr] = nil
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
    if healer.Character and healer.Character:FindFirstChild('HumanoidRootPart') and target.Character and target.Character:FindFirstChild('HumanoidRootPart') then
        if (healer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude < 6 then
            local start = os.clock()
            task.delay(Config.ReviveTime, function()
                if downed[target] and os.clock() - start >= Config.ReviveTime then
                    revive(target)
                end
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

RE_RequestBuyback.OnServerEvent:Connect(function(plr)
    if not dead[plr] then return end
    local cost = Config.RespawnBuybackPrice or 0
    local data = plr._data or {Coins = 0}
    if data.Coins < cost then return end
    data.Coins -= cost
    local ls = plr:FindFirstChild('leaderstats')
    if ls and ls:FindFirstChild('Coins') then
        ls.Coins.Value = data.Coins
        RE_UpdateCoins:FireClient(plr, ls.Coins.Value)
    end
    dead[plr] = nil
    plr:LoadCharacter()
end)

_G.EventBus.Bind('Heartbeat', function()
    for plr, info in pairs(downed) do
        if os.clock() - info.timer > Config.DownTime then
            if plr.Character then
                plr.Character:BreakJoints()
            end
            downed[plr] = nil
            dead[plr] = true
            RE_ShowBuybackRespawn:FireClient(plr, Config.RespawnBuybackPrice)
            if Crystal:ShouldGameOver() then
                _G.EventBus.Fire('GameOver')
            end
        end
    end
end)

return {}

-- Handles monster wave spawning logic
local ServerStorage = game:GetService('ServerStorage')

local MonsterAI = require(script.Parent.Parent.Modules.mod_MonsterAI)
local MonsterBuffService = require(script.Parent.Parent.Modules.mod_MonsterBuffService)
local Config = require(game:GetService('ReplicatedStorage').Config)
local RemoteEvents = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local RE_UpdateWave = RemoteEvents:WaitForChild('RE_UpdateWave')

local WaveManager = {}
WaveManager.currentWave = 0
WaveManager.dayLoop = nil

local spawnFolder = workspace:FindFirstChild('SpawnPoints')

local function getWaveInfo(index)
    local diff = Config.DifficultyModifiers[Config.Difficulty] or {}
    local base = Config.WaveBaseCount + index * Config.WaveCountIncrement
    local count = math.floor(base * (diff.SpawnCount or 1))
    local hpMul = (1 + index * Config.WaveHealthIncrement) * (diff.Health or 1)
    local dmgMul = (1 + index * Config.WaveDamageIncrement) * (diff.Damage or 1)
    return {count = count, hpMul = hpMul, dmgMul = dmgMul, boss = index % 10 == 0}
end

function WaveManager:SpawnWave(index)
    local info = getWaveInfo(index)
    if not spawnFolder then return end
    local types = Config.WaveMonsters[index] or Config.WaveMonsters.default
    for i = 1, info.count do
        local spawnPoint = spawnFolder:GetChildren()[((i-1) % #spawnFolder:GetChildren())+1]
        local tName = types[((i-1) % #types) + 1]
        local typeInfo = Config.MonsterTypes[tName] or Config.MonsterTypes.Default
        local template = ServerStorage.Enemies:FindFirstChild(typeInfo.Model)
        if template and spawnPoint then
            local monster = template:Clone()
            monster.Name = tName
            monster.Parent = workspace.RuntimeObjects
            monster.HumanoidRootPart.CFrame = spawnPoint.CFrame
            local hum = monster:FindFirstChildOfClass('Humanoid')
            if hum then
                hum.MaxHealth = typeInfo.Health * info.hpMul
                hum.Health = hum.MaxHealth
                hum.WalkSpeed = typeInfo.Speed
                monster:SetAttribute('DamageMul', info.dmgMul * (typeInfo.Damage / 5))
                MonsterBuffService.apply(monster)
            end
            MonsterAI.new(monster):Start()
        end
    end
    if info.boss then
        local bossTemplate = ServerStorage.Enemies:FindFirstChild('Boss')
        if bossTemplate and #spawnFolder:GetChildren() > 0 then
            local spawnPoint = spawnFolder:GetChildren()[1]
            local boss = bossTemplate:Clone()
            boss.Parent = workspace.RuntimeObjects
            boss.HumanoidRootPart.CFrame = spawnPoint.CFrame
            MonsterAI.new(boss):Start()
        end
    end
    RE_UpdateWave:FireAllClients(index)
end

_G.EventBus.Bind('NightStart', function()
    WaveManager.currentWave  = WaveManager.currentWave + 1
    WaveManager:SpawnWave(WaveManager.currentWave)
end)

_G.EventBus.Bind('GameOver', function()
    for _, obj in ipairs(workspace.RuntimeObjects:GetChildren()) do
        if obj:FindFirstChildOfClass('Humanoid') then
            obj:Destroy()
        end
    end
    WaveManager.currentWave = 0
    RE_UpdateWave:FireAllClients(0)
end)

_G.EventBus.Bind('CrystalPlaced', function()
    if WaveManager.currentWave == 0 then
        WaveManager:SpawnWave(0)
    end
end)

local function daySpawnLoop()
    while true do
        task.wait(Config.DaySpawnInterval)
        if not _G.isNight and math.random() < Config.DaySpawnChance then
            WaveManager:SpawnWave(WaveManager.currentWave)
        end
    end
end

_G.EventBus.Bind('DayStart', function()
    if not WaveManager.dayLoop then
        WaveManager.dayLoop = task.spawn(daySpawnLoop)
    end
end)

_G.EventBus.Bind('NightStart', function()
    if WaveManager.dayLoop then
        task.cancel(WaveManager.dayLoop)
        WaveManager.dayLoop = nil
    end
end)

return WaveManager

-- Handles monster wave spawning logic
local ServerStorage = game:GetService('ServerStorage')

local MonsterAI = require(script.Parent.Parent.Modules.mod_MonsterAI)
local Config = require(game:GetService('ReplicatedStorage').Modules.mod_Config)
local remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')
local RE_UpdateWave = remotes:WaitForChild('RE_UpdateWave')

local WaveManager = {}
WaveManager.currentWave = 0
WaveManager.dayLoop = nil

local spawnFolder = workspace:FindFirstChild('SpawnPoints')

local function CalculateWaveSize(index)
    return math.floor(Config.WaveBaseCount * (1 + (index - 1) * Config.WaveScale))
end

local function getWaveInfo(index)
    local diff = Config.DifficultyModifiers[Config.Difficulty] or {}
    local base = CalculateWaveSize(index)
    local count = math.floor(base * (diff.SpawnCount or 1))
    local hpMul = (1 + (index - 1) * Config.WaveHealthIncrement) * (diff.Health or 1)
    local dmgMul = (1 + (index - 1) * Config.WaveDamageIncrement) * (diff.Damage or 1)
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
        local template = ServerStorage.Assets.Monsters:FindFirstChild(typeInfo.Model)
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
                if _G.EnemyBuffService then
                    _G.EnemyBuffService.Apply(monster)
                end
            end
            MonsterAI.new(monster):Start()
        end
    end
    if info.boss then
        local bossTemplate = ServerStorage.Assets.Bosses:FindFirstChild('Boss')
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

function WaveManager:SpawnRandomDayEnemy()
    if not spawnFolder then return end
    local points = spawnFolder:GetChildren()
    local types = Config.WaveMonsters.default
    if #points == 0 or #types == 0 then return end
    local spawnPoint = points[math.random(#points)]
    local tName = types[math.random(#types)]
    local typeInfo = Config.MonsterTypes[tName] or Config.MonsterTypes.Default
    local template = ServerStorage.Assets.Monsters:FindFirstChild(typeInfo.Model)
    if template and spawnPoint then
        local monster = template:Clone()
        monster.Name = tName
        monster.Parent = workspace.RuntimeObjects
        monster.HumanoidRootPart.CFrame = spawnPoint.CFrame
        local hum = monster:FindFirstChildOfClass('Humanoid')
        if hum then
            hum.MaxHealth = typeInfo.Health
            hum.Health = hum.MaxHealth
            hum.WalkSpeed = typeInfo.Speed
            monster:SetAttribute('DamageMul', (typeInfo.Damage / 5))
            if _G.EnemyBuffService then
                _G.EnemyBuffService.Apply(monster)
            end
        end
        MonsterAI.new(monster):Start()
    end
end

function WaveManager:StartWave()
    if not _G.IsNight or not _G.IsNight() then
        return
    end
    self.currentWave = self.currentWave + 1
    self:SpawnWave(self.currentWave)
end

_G.EventBus.Bind('NightStart', function()
    if WaveManager.dayLoop then
        task.cancel(WaveManager.dayLoop)
        WaveManager.dayLoop = nil
    end
    WaveManager:StartWave()
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
        WaveManager:StartWave()
    end
end)

local function daySpawnLoop()
    while true do
        task.wait(Config.DaySpawnInterval)
        if _G.IsNight and _G.IsNight() then
            continue
        end
        for _ = 1, math.random(1, 3) do
            WaveManager:SpawnRandomDayEnemy()
        end
    end
end

_G.EventBus.Bind('DayStart', function()
    if not WaveManager.dayLoop then
        WaveManager.dayLoop = task.spawn(daySpawnLoop)
    end
end)

return WaveManager

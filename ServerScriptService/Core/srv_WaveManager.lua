-- Handles monster wave spawning logic
local ServerStorage = game:GetService('ServerStorage')
local Players = game:GetService('Players')

local MonsterAI = require(script.Parent.Parent.Modules.mod_MonsterAI)

local WaveManager = {}
WaveManager.currentWave = 0

local spawnFolder = workspace:FindFirstChild('SpawnPoints')

local function getWaveInfo(index)
    local base = 5 + index * 2
    local hpMul = 1 + index * 0.1
    local dmgMul = 1 + index * 0.05
    return {count = base, hpMul = hpMul, dmgMul = dmgMul, boss = index % 10 == 0}
end

function WaveManager:SpawnWave(index)
    local info = getWaveInfo(index)
    if not spawnFolder then return end
    for i = 1, info.count do
        local spawnPoint = spawnFolder:GetChildren()[((i-1) % #spawnFolder:GetChildren())+1]
        local template = ServerStorage.Assets.Monsters:FindFirstChild('Zombie')
        if template and spawnPoint then
            local monster = template:Clone()
            monster.Parent = workspace.RuntimeObjects
            monster.HumanoidRootPart.CFrame = spawnPoint.CFrame
            if monster:FindFirstChildOfClass('Humanoid') then
                monster.Humanoid.MaxHealth  = monster.Humanoid.MaxHealth *  info.hpMul
                monster.Humanoid.Health = monster.Humanoid.MaxHealth
                monster.Humanoid.WalkSpeed = monster.Humanoid.WalkSpeed * info.dmgMul
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
end

_G.EventBus.Bind('NightStart', function()
    WaveManager.currentWave  = WaveManager.currentWave + 1
    WaveManager:SpawnWave(WaveManager.currentWave)
end)

return WaveManager

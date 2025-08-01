--[[
    Wave Manager
    Spawns simple monsters each wave.
]]

local MonsterAI = require(game.ServerScriptService.Modules.mod_MonsterAI)

local WaveManager = { currentWave = 0 }

local defaultSpawn = Vector3.new(0, 5, 0)

function WaveManager:runWave()
    self.currentWave += 1
    print("Running wave", self.currentWave)

    local spawnFolder = workspace:FindFirstChild("SpawnPoints")
    local spawns = {}
    if spawnFolder then
        for _,p in ipairs(spawnFolder:GetChildren()) do
            if p:IsA("BasePart") then
                table.insert(spawns, p.Position)
            end
        end
    end
    if #spawns == 0 then
        table.insert(spawns, defaultSpawn)
    end

    local count = 2 + self.currentWave
    for i=1,count do
        local pos = spawns[((i-1) % #spawns) + 1]
        MonsterAI.spawn(pos)
    end
end

return WaveManager

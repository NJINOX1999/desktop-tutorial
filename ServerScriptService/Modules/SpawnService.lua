local SpawnService = {}

function SpawnService.new(config)
    local self = {
        Config = config,
    }

    return setmetatable(self, { __index = SpawnService })
end

function SpawnService:getSpawnPoints()
    local arena = workspace:FindFirstChild(self.Config.Spawn.ArenaFolderName)
    if not arena then
        return {}
    end
    local folder = arena:FindFirstChild(self.Config.Spawn.SpawnFolderName)
    if not folder then
        return {}
    end
    return folder:GetChildren()
end

function SpawnService:getRandomSpawn()
    local spawns = self:getSpawnPoints()
    if #spawns == 0 then
        return nil
    end
    return spawns[math.random(1, #spawns)]
end

function SpawnService:spawnProfile(profile)
    local player = profile.Player
    if not player.Character then
        player:LoadCharacter()
    end

    local character = player.Character
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        return
    end

    local spawnPoint = self:getRandomSpawn()
    if spawnPoint then
        root.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
    else
        root.CFrame = CFrame.new(self.Config.Spawn.FallbackSpawn)
    end

    humanoid.Health = humanoid.MaxHealth
    profile.Alive = true
end

return SpawnService

local Players = game:GetService("Players")

local PlayerService = {}

local function createLeaderstats(player, defaults)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    for statName, value in pairs(defaults) do
        local stat = Instance.new("IntValue")
        stat.Name = statName
        stat.Value = value
        stat.Parent = leaderstats
    end

    return leaderstats
end

function PlayerService.createProfile(player, defaults)
    local profile = {
        Player = player,
        Alive = false,
        Lives = 0,
        LastHitTime = 0,
        LastAttacker = nil,
    }

    createLeaderstats(player, defaults)
    return profile
end

function PlayerService.applyKO(profile)
    local leaderstats = profile.Player:FindFirstChild("leaderstats")
    if leaderstats then
        local kos = leaderstats:FindFirstChild("KOs")
        if kos then
            kos.Value += 1
        end
        local streak = leaderstats:FindFirstChild("Streak")
        if streak then
            streak.Value += 1
        end
        local score = leaderstats:FindFirstChild("Score")
        if score then
            score.Value += 1
        end
    end
end

function PlayerService.applyWO(profile)
    local leaderstats = profile.Player:FindFirstChild("leaderstats")
    if leaderstats then
        local wos = leaderstats:FindFirstChild("WOs")
        if wos then
            wos.Value += 1
        end
        local streak = leaderstats:FindFirstChild("Streak")
        if streak then
            streak.Value = 0
        end
    end
end

function PlayerService.resetRoundStats(profile)
    local leaderstats = profile.Player:FindFirstChild("leaderstats")
    if leaderstats then
        local streak = leaderstats:FindFirstChild("Streak")
        if streak then
            streak.Value = 0
        end
    end
end

function PlayerService.resetAllStats(player, defaults)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for statName, value in pairs(defaults) do
            local stat = leaderstats:FindFirstChild(statName)
            if stat then
                stat.Value = value
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats:Destroy()
    end
end)

return PlayerService

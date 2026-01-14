local MatchService = {}

function MatchService.new(config, playerService, spawnService)
    local self = {
        Config = config,
        PlayerService = playerService,
        SpawnService = spawnService,
        State = "Intermission",
        TimeRemaining = 0,
        ActivePlayers = {},
        RoundWinners = {},
    }

    return setmetatable(self, { __index = MatchService })
end

function MatchService:resetRound()
    self.ActivePlayers = {}
    self.RoundWinners = {}
    self.TimeRemaining = self.Config.Game.RoundDuration
    self.State = "Round"
end

function MatchService:startIntermission()
    self.State = "Intermission"
    self.TimeRemaining = self.Config.Game.IntermissionDuration
end

function MatchService:registerPlayer(profile)
    self.ActivePlayers[profile.Player] = profile
end

function MatchService:unregisterPlayer(player)
    self.ActivePlayers[player] = nil
end

function MatchService:getAliveCount()
    local count = 0
    for _, profile in pairs(self.ActivePlayers) do
        if profile.Alive then
            count += 1
        end
    end
    return count
end

function MatchService:checkWinner()
    for _, profile in pairs(self.ActivePlayers) do
        local leaderstats = profile.Player:FindFirstChild("leaderstats")
        local score = leaderstats and leaderstats:FindFirstChild("Score")
        if score and score.Value >= self.Config.Game.ScoreToWin then
            return profile.Player
        end
    end
    return nil
end

function MatchService:spawnAll()
    for _, profile in pairs(self.ActivePlayers) do
        self.SpawnService:spawnProfile(profile)
    end
end

function MatchService:tick(dt)
    self.TimeRemaining -= dt
    if self.TimeRemaining <= 0 then
        return true
    end
    return false
end

return MatchService

local Config = {}

Config.Game = {
    RoundDuration = 180,
    IntermissionDuration = 20,
    MinPlayersToStart = 2,
    MaxLives = 0,
    ScoreToWin = 10,
}

Config.Combat = {
    BaseDamage = 25,
    Cooldown = 0.6,
    Knockback = 40,
    HitboxSize = Vector3.new(5, 5, 5),
    HitboxOffset = CFrame.new(0, 0, -3),
}

Config.Spawn = {
    SpawnFolderName = "Spawns",
    ArenaFolderName = "Arena",
    FallbackSpawn = Vector3.new(0, 6, 0),
}

Config.Stats = {
    Default = {
        KOs = 0,
        WOs = 0,
        Streak = 0,
        Score = 0,
    },
}

return Config

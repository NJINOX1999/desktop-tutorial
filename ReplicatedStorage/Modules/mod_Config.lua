-- Shared configuration constants
local Config = {}

Config.Difficulty = "Normal" -- Easy, Normal, Hard
Config.DifficultyModifiers = {
    Easy = {SpawnCount = 0.75, Damage = 0.75, Health = 0.75, XP = 0.5},
    Normal = {SpawnCount = 1, Damage = 1, Health = 1, XP = 1},
    Hard = {SpawnCount = 1.5, Damage = 1.5, Health = 1.25, XP = 1.5},
}

Config.DayLength = 600
Config.NightLength = 600
Config.BaseTurretLimit = 3
Config.TowerCost = 10
Config.LevelXP = {100, 250, 450, 700, 1000}

-- gameplay rules
Config.VillageRadius = 50 -- spawn monsters outside this radius
Config.DaySpawnInterval = 30
Config.DaySpawnChance = 0.05
Config.NightSpawnInterval = 10
Config.NightSpawnChance = 1
Config.CrystalBuffMultiplier = 1.5
Config.DownTime = 60
Config.ReviveTime = 15
Config.HealCooldown = 60
Config.HealTime = 15

Config.WaveBaseCount = 5
Config.WaveCountIncrement = 2
Config.WaveHealthIncrement = 0.1
Config.WaveDamageIncrement = 0.05

Config.Weapons = {
    Hands = {Damage = 5, Range = 5},
    Stick = {Damage = 8, Range = 6},
    Bow = {Damage = 15, Range = 60, Ammo = 1}
}

Config.MonsterTypes = {
    Default = {Model = 'Zombie', Health = 100, Speed = 16, Damage = 5},
    Tank = {Model = 'Zombie', Health = 300, Speed = 10, Damage = 15},
    Speedy = {Model = 'Zombie', Health = 80, Speed = 24, Damage = 5}
}

Config.WaveMonsters = {
    default = {'Default'},
    [3] = {'Default', 'Speedy'},
    [5] = {'Default', 'Tank'}
}

Config.MaxPlayers = 6

Config.StartWeapon = 'Hands'
Config.StartAmmo = 0

return Config

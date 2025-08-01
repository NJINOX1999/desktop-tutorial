-- Shared configuration constants
local Config = {}

-- difficulty settings
Config.Difficulty = "Normal" -- Easy, Normal, Hard
Config.XPMultipliers = {
    Easy = 0.5,
    Normal = 1,
    Hard = 1.5,
}

Config.DayLength = 600
Config.NightLength = 600
Config.MaxTurretsPerPlayer = 3
Config.TowerCost = 10

-- gameplay rules
Config.VillageRadius = 50 -- spawn monsters outside this radius
Config.DaySpawnInterval = 30
Config.DaySpawnChance = 0.05
Config.CrystalEvacTime = 180
Config.CrystalBuffMultiplier = 1.5
Config.DownTime = 60
Config.ReviveTime = 15
Config.HealCooldown = 60
Config.HealTime = 15

Config.WeaponDamage = {
    Fist = 5,
    Stick = 8,
}

Config.MaxPlayers = 6

return Config

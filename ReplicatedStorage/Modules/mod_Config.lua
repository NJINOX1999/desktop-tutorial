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

return Config

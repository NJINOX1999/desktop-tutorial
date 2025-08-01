--[[
    Shared configuration values.
]]

local Config = {
    MaxPlayers = 6,

    DayLength = 600,   -- seconds
    NightLength = 600, -- seconds

    WaveInterval = 60, -- time between waves at night
    SafeRadius = 50,   -- monsters cannot spawn within this distance from the crystal
}

return Config

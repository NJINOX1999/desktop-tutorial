--!strict
local Config = {}

Config.Save = {
    Retries = 5,
    BackoffBase = 0.5,
}

Config.NetLimits = {
    Calls = 20,
    Window = 5,
}

return Config

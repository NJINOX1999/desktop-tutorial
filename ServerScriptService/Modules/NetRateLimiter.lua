--!strict
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Config = require(ReplicatedStorage.Config.GameConfig)

local limits = Config.NetLimits or {Calls = 20, Window = 5}
local state: {[string]: {count: number, t: number}} = {}

local NetRateLimiter = {}

function NetRateLimiter.Allow(player: Player, remoteName: string): boolean
    local key = (player.UserId .. ':' .. remoteName)
    local now = os.clock()
    local entry = state[key]
    if entry then
        if now - entry.t > limits.Window then
            entry.t = now
            entry.count = 1
        else
            entry.count += 1
        end
    else
        entry = {count = 1, t = now}
        state[key] = entry
    end
    if entry.count > limits.Calls then
        return false
    end
    return true
end

return NetRateLimiter

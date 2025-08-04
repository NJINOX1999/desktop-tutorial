-- Game loop managing day/night cycle and wave timer
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Config = require(ReplicatedStorage.Modules.mod_Config)

local DAY_LENGTH = Config.DayLength -- seconds
local NIGHT_LENGTH = Config.NightLength -- seconds
local CYCLE_LENGTH = DAY_LENGTH + NIGHT_LENGTH

local timeOfDay = 0
local isNight = false
_G.isNight = false

-- simple event dispatcher stored in _G
local callbacks = {}
local function bind(name, fn)
    callbacks[name] = callbacks[name] or {}
    table.insert(callbacks[name], fn)
end
local function fire(name, ...)
    local list = callbacks[name]
    if list then
        for _, fn in ipairs(list) do
            fn(...)
        end
    end
end
_G.EventBus = {Bind = bind, Fire = fire}

local ResourceManager = require(script.Parent.Modules.mod_ResourceManager)
ResourceManager:Init()
local Crystal = require(script.Parent.Modules.mod_Crystal)
local remotes = ReplicatedStorage:WaitForChild('Remotes')
local reDay = remotes:FindFirstChild('RE_DayStart')
local reNight = remotes:FindFirstChild('RE_NightStart')
local reTime = remotes:FindFirstChild('RE_TimeOfDayChanged')
local reSetDiff = remotes:FindFirstChild('RE_SetDifficulty')
local reGameOver = remotes:FindFirstChild('RE_GameOver')
local function checkTransitions()
    if not isNight and timeOfDay >= DAY_LENGTH then
        isNight = true
        _G.isNight = true
        fire('NightStart')
        if reNight then reNight:FireAllClients() end
    elseif isNight and timeOfDay >= CYCLE_LENGTH then
        isNight = false
        _G.isNight = false
        timeOfDay = timeOfDay - CYCLE_LENGTH
        fire('DayStart')
        if reDay then reDay:FireAllClients() end
    end
    fire('TimeOfDayChanged', timeOfDay, isNight)
    if reTime then reTime:FireAllClients(timeOfDay, isNight) end
end

RunService.Heartbeat:Connect(function(dt)
    timeOfDay = timeOfDay + dt
    checkTransitions()
    _G.EventBus.Fire('Heartbeat', dt)
    if Crystal:ShouldGameOver() then
        fire('GameOver')
    end
end)

if reSetDiff then
    reSetDiff.OnServerEvent:Connect(function(player, diff)
        if player ~= game:GetService('Players'):GetPlayers()[1] then
            return
        end
        if diff == 'Easy' or diff == 'Normal' or diff == 'Hard' then
            Config.Difficulty = diff
        end
    end)
end

if reGameOver then
    _G.EventBus.Bind('GameOver', function()
        reGameOver:FireAllClients()
    end)
end

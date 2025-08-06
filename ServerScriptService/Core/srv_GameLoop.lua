-- Game loop managing day/night cycle and wave timer
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Config = require(ReplicatedStorage.Modules.mod_Config)

local DAY_LENGTH = Config.DayLength -- seconds
local NIGHT_LENGTH = Config.NightLength -- seconds
local CYCLE_LENGTH = DAY_LENGTH + NIGHT_LENGTH

local GameState = {CrystalDestroyed = false}
_G.GameState = GameState

local timeOfDay = 0
local isNight = false
_G.isNight = false
local function IsNight()
    return isNight
end
_G.IsNight = IsNight
local gameRunning = true

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
local reAssignCrystal = remotes:FindFirstChild('RE_AssignCrystal')

local function resetGame()
    Crystal:Reset()
    GameState.CrystalDestroyed = false
    if _G.EnemyBuffService then
        _G.EnemyBuffService.BoostActive = false
    end
    local host = Players:GetPlayers()[1]
    if host then
        local tools = game:GetService('ServerStorage'):FindFirstChild('Tools')
        local template = tools and tools:FindFirstChild('CrystalTool')
        local backpack = host:FindFirstChildOfClass('Backpack') or host:WaitForChild('Backpack')
        if template and backpack then
            local tool = template:Clone()
            tool.Parent = backpack
        end
        if reAssignCrystal then reAssignCrystal:FireClient(host) end
    end
    timeOfDay = 0
    isNight = false
    _G.isNight = false
    fire('DayStart')
    if reDay then reDay:FireAllClients() end
    gameRunning = true
end
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
    if not gameRunning then return end
    timeOfDay = timeOfDay + dt
    checkTransitions()
    _G.EventBus.Fire('Heartbeat', dt)
    if GameState.CrystalDestroyed then
        local alive = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            local hum = plr.Character and plr.Character:FindFirstChild('Humanoid')
            if hum and hum.Health > 0 then
                alive = alive + 1
            end
        end
        if alive == 0 then
            gameRunning = false
            fire('GameOver')
            task.delay(20, function()
                resetGame()
                if reGameOver then
                    reGameOver:FireAllClients('Reset')
                end
            end)
        end
        return
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
        reGameOver:FireAllClients('Lost')
    end)
end

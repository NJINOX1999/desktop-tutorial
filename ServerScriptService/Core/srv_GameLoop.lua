-- Game loop managing day/night cycle and wave timer
local RunService = game:GetService('RunService')

local DAY_LENGTH = 600 -- seconds
local NIGHT_LENGTH = 600 -- seconds
local CYCLE_LENGTH = DAY_LENGTH + NIGHT_LENGTH

local timeOfDay = 0
local isNight = false

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
local function checkTransitions()
    if not isNight and timeOfDay >= DAY_LENGTH then
        isNight = true
        fire('NightStart')
    elseif isNight and timeOfDay >= CYCLE_LENGTH then
        isNight = false
        timeOfDay = timeOfDay - CYCLE_LENGTH
        fire('DayStart')
    end
    fire('TimeOfDayChanged', timeOfDay, isNight)
end

RunService.Heartbeat:Connect(function(dt)
    timeOfDay = timeOfDay + dt
    checkTransitions()
end)

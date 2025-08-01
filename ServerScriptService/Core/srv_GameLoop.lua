--[[
    Islebound: Last Defenders - Simplified Game Loop
    Cycles through gather, build and defend phases.
]]

local Config = require(game.ReplicatedStorage.Modules.mod_Config)
local WaveManager = require(script.Parent.srv_WaveManager)
local ResourceManager = require(game.ServerScriptService.Modules.mod_ResourceManager)

local GameLoop = {}

function GameLoop:start()
    print("Game loop started")
    ResourceManager.init()
    while true do
        print("Day phase")
        task.wait(Config.DayLength)

        print("Night phase")
        local finish = os.clock() + Config.NightLength
        while os.clock() < finish do
            WaveManager:runWave()
            task.wait(Config.WaveInterval)
        end
    end
end

return GameLoop

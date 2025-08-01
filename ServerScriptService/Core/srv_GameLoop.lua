--[[
    Islebound: Last Defenders - Simplified Game Loop
    Cycles through gather, build and defend phases.
]]

local WaveManager = require(script.Parent.srv_WaveManager)
local ResourceManager = require(game.ServerScriptService.Modules.mod_ResourceManager)

local GameLoop = {}
GameLoop.phaseLength = 10

function GameLoop:start()
    print("Game loop started")
    ResourceManager.init()
    while true do
        -- gather phase
        print("Gather phase")
        task.wait(self.phaseLength)
        -- build phase
        print("Build phase")
        task.wait(self.phaseLength)
        -- defend phase
        print("Defend phase")
        WaveManager:runWave()
        task.wait(self.phaseLength)
    end
end

return GameLoop

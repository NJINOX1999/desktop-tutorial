--[[
    Minimal client input handler
    Press 'B' to request a build at your character position.
]]

local BuildSystem = require(script.Parent.cli_BuildSystem)
local UserInputService = game:GetService("UserInputService")

local Input = {}

function Input.init()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.B then
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character.PrimaryPart then
                BuildSystem.requestBuild(player.Character.PrimaryPart.Position + Vector3.new(0,0,-5))
            end
        end
    end)
end

return Input

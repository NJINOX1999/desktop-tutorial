local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local AnimManager = require(ReplicatedStorage.Modules.mod_AnimationManager)

local player = Players.LocalPlayer

local function bindCharacter(char)
    local hum = char:WaitForChild('Humanoid')
    hum.Died:Connect(function()
        AnimManager.play(hum, 'Anim_Death')
    end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
    bindCharacter(player.Character)
end

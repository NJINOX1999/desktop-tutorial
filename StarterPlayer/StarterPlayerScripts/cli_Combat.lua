local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RE_Fire = ReplicatedStorage.Remotes:WaitForChild('RE_FireWeapon')

local player = Players.LocalPlayer
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum or hum.Health <= 0 then return end
    RE_Fire:FireServer(mouse.Hit.Position)
end)

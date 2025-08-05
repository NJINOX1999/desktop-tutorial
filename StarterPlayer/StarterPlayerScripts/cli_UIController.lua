local Players = game:GetService('Players')

local player = Players.LocalPlayer

player.CharacterAdded:Connect(function()
    local gui = player:WaitForChild('PlayerGui')
    local hud = gui:FindFirstChild('ScreenGui_HUD')
    if hud then
        hud.Enabled = true
    end
end)

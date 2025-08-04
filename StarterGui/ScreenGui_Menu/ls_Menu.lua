local ReplicatedStorage = game:GetService('ReplicatedStorage')
local remotes = ReplicatedStorage:WaitForChild('Remotes')
local RE_PlayerSpawnRequest = remotes:WaitForChild('RE_PlayerSpawnRequest')
local RE_SetDifficulty = remotes:WaitForChild('RE_SetDifficulty')
local RE_GameOver = remotes:WaitForChild('RE_GameOver')

local gui = script.Parent
local playButton = gui:WaitForChild('PlayButton')

playButton.MouseButton1Click:Connect(function()
    RE_PlayerSpawnRequest:FireServer()
end)

for _, name in ipairs({'Easy','Normal','Hard'}) do
    local btn = gui:FindFirstChild(name .. 'Button')
    if btn then
        btn.MouseButton1Click:Connect(function()
            RE_SetDifficulty:FireServer(name)
        end)
    end
end

RE_GameOver.OnClientEvent:Connect(function()
    playButton.Visible = true
end)

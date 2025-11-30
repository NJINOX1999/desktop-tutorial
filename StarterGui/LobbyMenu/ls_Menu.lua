local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local RE_PlayerSpawnRequest = RemoteEvents:WaitForChild('RE_PlayerSpawnRequest')
local RE_SetDifficulty = RemoteEvents:WaitForChild('RE_SetDifficulty')
local RE_GameOver = RemoteEvents:WaitForChild('RE_GameOver')

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

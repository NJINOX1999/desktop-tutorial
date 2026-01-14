local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local remotes = ReplicatedStorage:WaitForChild('Remotes')
local RE_PlayerSpawnRequest = remotes:WaitForChild('RE_PlayerSpawnRequest')
local RE_SetDifficulty = remotes:WaitForChild('RE_SetDifficulty')
local RE_GameOver = remotes:WaitForChild('RE_GameOver')
local RE_SelectSlot = remotes:WaitForChild('RE_SelectSlot')

local gui = script.Parent
local startButton = gui:WaitForChild('StartButton')
local slots = gui:WaitForChild('Slots')
local difficultyFrame = gui:WaitForChild('Difficulty')

local player = Players.LocalPlayer

local function isHost()
    return player:GetAttribute('Host') == true
end

local function tryStart()
    if #Players:GetPlayers() <= 6 then
        RE_PlayerSpawnRequest:FireServer()
    end
end

if isHost() then
    startButton.Visible = true
    startButton.MouseButton1Click:Connect(tryStart)
else
    startButton.Visible = false
end

for i = 1, 3 do
    local btn = slots:FindFirstChild('Slot' .. i)
    if btn then
        btn.MouseButton1Click:Connect(function()
            if isHost() then
                RE_SelectSlot:FireServer(i)
            end
        end)
    end
end

for _, name in ipairs({'Easy','Normal','Hard'}) do
    local btn = difficultyFrame:FindFirstChild(name .. 'Button')
    if btn then
        btn.MouseButton1Click:Connect(function()
            if isHost() then
                RE_SetDifficulty:FireServer(name)
            end
        end)
    end
end

RE_GameOver.OnClientEvent:Connect(function()
    if isHost() then
        startButton.Visible = true
    end
end)

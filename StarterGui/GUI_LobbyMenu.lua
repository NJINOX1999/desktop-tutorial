local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local remotes = ReplicatedStorage:WaitForChild('Remotes')
local RF_SetSlot = remotes:WaitForChild('RF_SetDataSlot')
local RE_SetDifficulty = remotes:WaitForChild('RE_SetDifficulty')
local RE_PlayerSpawnRequest = remotes:WaitForChild('RE_PlayerSpawnRequest')

local player = Players.LocalPlayer
local gui = script.Parent

-- Slot selection
local slotButtons = {}
for i = 1, 3 do
    local btn = gui:WaitForChild('Slot' .. i .. 'Button')
    slotButtons[i] = btn
    btn.MouseButton1Click:Connect(function()
        RF_SetSlot:InvokeServer(i)
    end)
end

-- Difficulty selection
for _, name in ipairs({'Easy', 'Normal', 'Hard'}) do
    local btn = gui:FindFirstChild(name .. 'Button')
    if btn then
        btn.MouseButton1Click:Connect(function()
            RE_SetDifficulty:FireServer(name)
        end)
    end
end

-- Start game
local startButton = gui:WaitForChild('StartButton')
startButton.MouseButton1Click:Connect(function()
    RE_PlayerSpawnRequest:FireServer()
    gui.Enabled = false
end)

-- Guests only wait for host
if not player:GetAttribute('IsHost') then
    for _, btn in ipairs(slotButtons) do
        btn.Visible = false
    end
    startButton.Visible = false
    local waiting = gui:FindFirstChild('WaitingLabel')
    if waiting then
        waiting.Visible = true
    end
end


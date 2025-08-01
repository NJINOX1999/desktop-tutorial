local player = game.Players.LocalPlayer
local gui = Instance.new('ScreenGui')
local waveLabel = Instance.new('TextLabel')
waveLabel.Size = UDim2.fromScale(0.2,0.05)
waveLabel.Position = UDim2.fromScale(0.4,0)
waveLabel.Parent = gui
local xpBar = Instance.new('Frame')
xpBar.Size = UDim2.fromScale(0.4,0.02)
xpBar.Position = UDim2.fromScale(0.3,0.95)
xpBar.BackgroundColor3 = Color3.new(0,1,0)
xpBar.Parent = gui

gui.Parent = player:WaitForChild('PlayerGui')

local remotes = game.ReplicatedStorage:WaitForChild('Remotes')
remotes.RE_NightStart.OnClientEvent:Connect(function()
    waveLabel.Text = "Night incoming"
end)

local Players = game:GetService('Players')
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')

-- remove the default Roblox loading screen
pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

local player = Players.LocalPlayer
local gui = Instance.new('ScreenGui')
 gui.IgnoreGuiInset = true
 gui.Parent = player:WaitForChild('PlayerGui')
local label = Instance.new('TextLabel')
 label.Size = UDim2.new(1, 0, 1, 0)
 label.BackgroundTransparency = 1
 label.TextColor3 = Color3.new(1, 1, 1)
 label.TextScaled = true
 label.Text = 'Loading...'
 label.Parent = gui

-- gather assets to preload
local assets = {}
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA('Animation') or obj:IsA('MeshPart') or obj:IsA('Texture') or obj:IsA('Sound') or obj:IsA('Decal') then
        table.insert(assets, obj)
    end
end
pcall(function()
    ContentProvider:PreloadAsync(assets)
end)

gui:Destroy()

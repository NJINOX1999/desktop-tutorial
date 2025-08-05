-- Client-side build placement preview and request
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local remotes = ReplicatedStorage:WaitForChild('Remotes')
local BuildRequest = remotes:WaitForChild('RE_BuildRequest')
local RE_BuildMessage = remotes:WaitForChild('RE_BuildMessage')
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local preview
local canPlace = false
local BuildValidator = require(ReplicatedStorage.Modules.mod_BuildValidator)

local StarterGui = game:GetService('StarterGui')

local BuildSystem = {}

RE_BuildMessage.OnClientEvent:Connect(function(text)
    pcall(function()
        StarterGui:SetCore('SendNotification', {Title = 'Build', Text = text})
    end)
end)

function BuildSystem:RequestBuild(itemId, cframe)
    if canPlace then
        BuildRequest:FireServer(itemId, cframe.Position, cframe.Rotation)
        if preview then preview:Destroy() preview = nil end
    end
end

function BuildSystem:ShowPreview(model)
    if preview then preview:Destroy() end
    preview = model:Clone()
    preview.Parent = workspace.CurrentCamera
    for _, d in ipairs(preview:GetDescendants()) do
        if d:IsA('BasePart') then
            d.Transparency = 0.5
            d.CanCollide = false
        end
    end
end

function BuildSystem:Update()
    if not preview then return end
    local cf = mouse.Hit
    preview:SetPrimaryPartCFrame(cf)
    if BuildValidator:CanPlace(cf.Position) then
        canPlace = true
        for _, d in ipairs(preview:GetDescendants()) do
            if d:IsA('BasePart') then
                d.Color = Color3.fromRGB(0, 255, 0)
            end
        end
    else
        canPlace = false
        for _, d in ipairs(preview:GetDescendants()) do
            if d:IsA('BasePart') then
                d.Color = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

function BuildSystem:SetGhostColor(color)
    if not preview then return end
    for _, d in ipairs(preview:GetDescendants()) do
        if d:IsA('BasePart') then
            d.Color = color
        end
    end
end

game:GetService('RunService').RenderStepped:Connect(function()
    BuildSystem:Update()
end)

return BuildSystem

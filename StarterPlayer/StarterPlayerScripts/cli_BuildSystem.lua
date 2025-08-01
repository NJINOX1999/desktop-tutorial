-- Client-side build placement preview and request
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local BuildRequest = ReplicatedStorage.Remotes:WaitForChild('RE_BuildRequest')

local BuildSystem = {}

function BuildSystem:RequestBuild(itemId, cframe)
    BuildRequest:FireServer(itemId, cframe.Position, cframe.Rotation)
end

return BuildSystem

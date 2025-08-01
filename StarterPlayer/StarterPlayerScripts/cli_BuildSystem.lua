--[[
    Simple client build request
]]

local BuildSystem = {}
local buildRemote = game.ReplicatedStorage.Remotes:FindFirstChild("RE_BuildRequest")

function BuildSystem.requestBuild(position)
    if buildRemote then
        buildRemote:FireServer(position)
    end
end

return BuildSystem

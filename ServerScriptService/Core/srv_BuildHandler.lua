--[[
    Handles build requests from clients by spawning simple walls.
]]

local BuildValidator = require(game.ServerScriptService.Modules.mod_BuildValidator)
local re = require(game.ReplicatedStorage.Remotes.RE_BuildRequest)

local runtimeFolder = workspace:FindFirstChild("RuntimeObjects") or Instance.new("Folder", workspace)
runtimeFolder.Name = "RuntimeObjects"

re.OnServerEvent:Connect(function(player, position)
    if BuildValidator.canPlace(player, position) then
        local wall = Instance.new("Part")
        wall.Name = "Wall"
        wall.Size = Vector3.new(4, 4, 1)
        wall.Position = position
        wall.Anchored = true
        wall.Parent = runtimeFolder
    end
end)

return true

--[[
    Simple Resource Manager
    Spawns resource nodes at predetermined positions.
]]

local ResourceManager = {}

local resources = {
    {pos = Vector3.new(10, 2, 0), respawn = 30},
    {pos = Vector3.new(-10, 2, 5), respawn = 30}
}

local runtimeFolder = workspace:FindFirstChild("RuntimeObjects") or Instance.new("Folder", workspace)
runtimeFolder.Name = "RuntimeObjects"

local function spawnNode(data)
    local node = Instance.new("Part")
    node.Name = "Tree"
    node.Size = Vector3.new(2,4,2)
    node.Position = data.pos
    node.Anchored = true
    node.Parent = runtimeFolder
    node.Touched:Connect(function(hit)
        local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
        if hum then
            node:Destroy()
            task.delay(data.respawn, function()
                spawnNode(data)
            end)
        end
    end)
end

function ResourceManager.init()
    for _,data in ipairs(resources) do
        spawnNode(data)
    end
end

return ResourceManager

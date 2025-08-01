--[[
    Simple Resource Manager
    Spawns resource nodes at predetermined positions.
]]

local ResourceManager = {}

local resources = {
    {type = "Tree",  pos = Vector3.new(10, 2, 0),  respawn = 60},
    {type = "Tree",  pos = Vector3.new(-12, 2, 6), respawn = 60},
    {type = "Rock",  pos = Vector3.new(20, 2, -8), respawn = 90},
    {type = "Iron",  pos = Vector3.new(-18, 2, -5), respawn = 120},
}

local runtimeFolder = workspace:FindFirstChild("RuntimeObjects") or Instance.new("Folder", workspace)
runtimeFolder.Name = "RuntimeObjects"

local function spawnNode(data)
    local node = Instance.new("Part")
    node.Name = data.type or "Node"
    node.Size = Vector3.new(2,4,2)
    node.Position = data.pos
    node.Anchored = true
    node.Parent = runtimeFolder

    local used = false
    node.Touched:Connect(function(hit)
        if used then return end
        local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
        if hum then
            used = true
            local loot = Instance.new("Part")
            loot.Name = node.Name .. "Drop"
            loot.Size = Vector3.new(1,1,1)
            loot.Position = node.Position + Vector3.new(0,2,0)
            loot.Anchored = false
            loot.Parent = runtimeFolder
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

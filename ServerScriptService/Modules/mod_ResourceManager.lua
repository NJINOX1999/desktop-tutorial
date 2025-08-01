-- Manages respawn for breakable trees and nodes
local CollectionService = game:GetService('CollectionService')
local ServerStorage = game:GetService('ServerStorage')

local ResourceManager = {}
ResourceManager.trees = {}

local treePrefab = ServerStorage.Assets.Trees:FindFirstChild('BreakableTree')
local nodePrefab = ServerStorage.Assets.Trees:FindFirstChild('BreakableNode')

function ResourceManager:Respawn(info)
    local prefab = info.prefab
    if not prefab then return end
    local clone = prefab:Clone()
    clone:SetPrimaryPartCFrame(info.cframe)
    clone.Parent = info.parent
    self:Register(clone, prefab)
end

function ResourceManager:Register(object, prefab)
    local info = {instance = object, prefab = prefab or object, parent = object.Parent, cframe = object:GetPrimaryPartCFrame()}
    table.insert(self.trees, info)
    object.Destroying:Connect(function()
        task.delay(300, function()
            self:Respawn(info)
        end)
    end)
end

function ResourceManager:Init()
    -- search the entire workspace for plugin placed trees/nodes so respawn works
    -- even for objects outside the Map folder (e.g. near the village)
    for _, obj in ipairs(CollectionService:GetTagged('PluginTree')) do
        if obj:IsDescendantOf(workspace) and treePrefab then
            local cf = obj:GetPrimaryPartCFrame()
            local parent = obj.Parent
            obj:Destroy()
            local clone = treePrefab:Clone()
            clone:SetPrimaryPartCFrame(cf)
            clone.Parent = parent
            self:Register(clone, treePrefab)
        end
    end
    for _, obj in ipairs(CollectionService:GetTagged('PluginNode')) do
        if obj:IsDescendantOf(workspace) and nodePrefab then
            local cf = obj:GetPrimaryPartCFrame()
            local parent = obj.Parent
            obj:Destroy()
            local clone = nodePrefab:Clone()
            clone:SetPrimaryPartCFrame(cf)
            clone.Parent = parent
            self:Register(clone, nodePrefab)
        end
    end
end

return ResourceManager

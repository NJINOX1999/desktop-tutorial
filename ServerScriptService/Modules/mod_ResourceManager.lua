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
    if not workspace:FindFirstChild('Map') then return end
    for _, obj in ipairs(workspace.Map:GetDescendants()) do
        if CollectionService:HasTag(obj, 'PluginTree') and treePrefab then
            local clone = treePrefab:Clone()
            clone:SetPrimaryPartCFrame(obj:GetPrimaryPartCFrame())
            clone.Parent = obj.Parent
            obj:Destroy()
            self:Register(clone, treePrefab)
        elseif CollectionService:HasTag(obj, 'PluginNode') and nodePrefab then
            local clone = nodePrefab:Clone()
            clone:SetPrimaryPartCFrame(obj:GetPrimaryPartCFrame())
            clone.Parent = obj.Parent
            obj:Destroy()
            self:Register(clone, nodePrefab)
        end
    end
end

return ResourceManager

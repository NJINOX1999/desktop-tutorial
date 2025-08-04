local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local RE = RS.Remotes:WaitForChild('RE_LootPickup')

local function onPrompt(prompt)
    local loot = prompt.Parent
    RE:FireServer(loot)
end

workspace.ChildAdded:Connect(function(obj)
    if obj:IsA('Part') and (obj:GetAttribute('Coins') or obj:GetAttribute('ItemId')) then
        local prompt = Instance.new('ProximityPrompt')
        prompt.ActionText = 'Pickup'
        prompt.ObjectText = obj.Name
        prompt.Parent = obj
        prompt.Triggered:Connect(onPrompt)
    end
end)

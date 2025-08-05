-- Placeholder crafting service
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RF_Craft = ReplicatedStorage.Remotes:WaitForChild('RF_CraftItem')

RF_Craft.OnServerInvoke = function(player, recipe)
    -- TODO: implement crafting logic
    return false
end

return {}

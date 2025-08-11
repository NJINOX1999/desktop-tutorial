-- Placeholder crafting service
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RF_Craft = ReplicatedStorage.Remotes:WaitForChild('RF_CraftItem')
local NetRateLimiter = require(script.Parent.Parent.Modules.NetRateLimiter)

RF_Craft.OnServerInvoke = function(player, recipe)
    if not NetRateLimiter.Allow(player, RF_Craft.Name) then return false end
    -- TODO: implement crafting logic
    return false
end

return {}

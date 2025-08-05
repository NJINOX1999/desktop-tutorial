local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Crafting = require(ReplicatedStorage.Modules.mod_Crafting)
local RF_Craft = ReplicatedStorage.RemoteFunctions:WaitForChild('RF_CraftItem')

RF_Craft.OnServerInvoke = function(player, recipe)
    if typeof(recipe) ~= 'string' or not player._data then
        return false
    end
    local ok, result = Crafting:Craft(player._data.Inventory, recipe)
    return ok and result or false
end

return Crafting

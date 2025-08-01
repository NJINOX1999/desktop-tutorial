-- Handles loot pickup requests from clients
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RE = ReplicatedStorage.Remotes:WaitForChild('RE_LootPickup')

RE.OnServerEvent:Connect(function(player, loot)
    if typeof(loot) ~= 'Instance' or not loot:IsDescendantOf(workspace.RuntimeObjects) then
        return
    end
    local value = tonumber(loot:GetAttribute('Coins'))
    if value then
        if player._data then
            player._data.Coins = player._data.Coins + value
        end
    end
    loot:Destroy()
end)

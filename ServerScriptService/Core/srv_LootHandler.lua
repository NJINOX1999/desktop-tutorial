-- Handles loot pickup requests from clients
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RE = ReplicatedStorage.Remotes:WaitForChild('RE_LootPickup')

RE.OnServerEvent:Connect(function(player, loot)
    if typeof(loot) ~= 'Instance' or not loot:IsDescendantOf(workspace.RuntimeObjects) then
        return
    end
    local value = tonumber(loot:GetAttribute('Coins'))
    if value and player._data then
        player._data.Coins = player._data.Coins + value
        local ls = player:FindFirstChild('leaderstats')
        if ls and ls:FindFirstChild('Coins') then
            ls.Coins.Value = player._data.Coins
        end
    end
    local itemId = loot:GetAttribute('ItemId')
    if itemId and player._data then
        player._data.Inventory[itemId] = (player._data.Inventory[itemId] or 0) + (loot:GetAttribute('Qty') or 1)
        if itemId == 'CrystalShard' and player.Character then
            local hum = player.Character:FindFirstChildOfClass('Humanoid')
            if hum then
                hum.WalkSpeed = hum.WalkSpeed + 5
                task.delay(10, function()
                    if hum.Parent then hum.WalkSpeed = hum.WalkSpeed - 5 end
                end)
            end
        end
    end
    loot:Destroy()
end)

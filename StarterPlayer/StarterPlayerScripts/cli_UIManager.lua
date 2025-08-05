local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('Remotes')

-- Placeholder UI manager; handlers will be filled when GUI is implemented

Remotes:WaitForChild('RE_UpdateHUD').OnClientEvent:Connect(function(data)
    -- TODO: update HUD elements with data
end)

Remotes:WaitForChild('RE_ToggleShop').OnClientEvent:Connect(function()
    -- TODO: toggle shop interface
end)

Remotes:WaitForChild('RE_ShowGameOver').OnClientEvent:Connect(function()
    -- TODO: show game over screen
end)

Remotes:WaitForChild('RE_SetDifficulty').OnClientEvent:Connect(function(diff)
    -- TODO: reflect new difficulty in UI
end)

Remotes:WaitForChild('RE_ShowBuyback').OnClientEvent:Connect(function(items)
    -- TODO: display buyback menu with items
end)

Remotes:WaitForChild('RE_SetGhostColor').OnClientEvent:Connect(function(color)
    -- TODO: set build ghost model color
end)

Remotes:WaitForChild('RE_UpdateXPBar').OnClientEvent:Connect(function(current, max)
    -- TODO: update XP progress bar
end)

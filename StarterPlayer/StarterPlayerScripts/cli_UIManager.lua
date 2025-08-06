local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('Remotes')
local UserInputService = game:GetService('UserInputService')
local BuildSystem = require(script.Parent.cli_BuildSystem)

local currentItem
local assets = ReplicatedStorage:WaitForChild('Assets', 5)
local towers = assets and assets:FindFirstChild('Towers')

-- HUD and shop events remain placeholders
Remotes:WaitForChild('RE_UpdateHUD').OnClientEvent:Connect(function(_)
end)

Remotes:WaitForChild('RE_ToggleShop').OnClientEvent:Connect(function()
end)

Remotes:WaitForChild('RE_ShowGameOver').OnClientEvent:Connect(function()
end)

Remotes:WaitForChild('RE_SetDifficulty').OnClientEvent:Connect(function(_diff)
end)

Remotes:WaitForChild('RE_ShowBuyback').OnClientEvent:Connect(function(_items)
end)

Remotes:WaitForChild('RE_UpdateXPBar').OnClientEvent:Connect(function(_current, _max)
end)

-- start tower placement from server or UI
Remotes:WaitForChild('RE_StartTowerPlacement').OnClientEvent:Connect(function(itemId)
    if towers then
        local model = towers:FindFirstChild(itemId)
        if model then
            currentItem = itemId
            BuildSystem:ShowPreview(model)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if currentItem and input.UserInputType == Enum.UserInputType.MouseButton1 then
        BuildSystem:RequestBuild(currentItem, BuildSystem:GetPreviewCFrame())
        currentItem = nil
    elseif currentItem and input.KeyCode == Enum.KeyCode.Escape then
        BuildSystem:Cancel()
        currentItem = nil
    end
end)

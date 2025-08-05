local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('Remotes')

local player = Players.LocalPlayer
local gui = player:WaitForChild('PlayerGui')

local function getGui(name)
    return gui:FindFirstChild(name)
end

Remotes:WaitForChild('RE_UpdateHUD').OnClientEvent:Connect(function(data)
    local hud = getGui('ScreenGui_HUD')
    if not hud then return end
    if data.Coins and hud:FindFirstChild('CoinLabel') then
        hud.CoinLabel.Text = string.format('Coins: %d', data.Coins)
    end
    if data.HP and hud:FindFirstChild('HPLabel') then
        hud.HPLabel.Text = string.format('HP: %d', data.HP)
    end
    if data.Ammo and hud:FindFirstChild('AmmoLabel') then
        hud.AmmoLabel.Text = string.format('Ammo: %d', data.Ammo)
    end
end)

Remotes:WaitForChild('RE_ToggleShop').OnClientEvent:Connect(function()
    local shop = getGui('ScreenGui_Shop')
    if shop then
        shop.Enabled = not shop.Enabled
    end
end)

Remotes:WaitForChild('RE_ShowGameOver').OnClientEvent:Connect(function()
    local menu = getGui('ScreenGui_Menu')
    if menu then
        menu.Enabled = true
    end
end)

Remotes:WaitForChild('RE_SetDifficulty').OnClientEvent:Connect(function(diff)
    local menu = getGui('ScreenGui_Menu')
    local label = menu and menu:FindFirstChild('DifficultyLabel')
    if label then
        label.Text = 'Difficulty: ' .. diff
    end
end)

Remotes:WaitForChild('RE_ShowBuyback').OnClientEvent:Connect(function()
    local open = Remotes:WaitForChild('RE_BuybackOpen')
    open:FireServer()
end)

Remotes:WaitForChild('RE_SetGhostColor').OnClientEvent:Connect(function(color)
    local build = require(player.PlayerScripts:WaitForChild('cli_BuildSystem'))
    if build and build.SetGhostColor then
        build:SetGhostColor(color)
    end
end)

Remotes:WaitForChild('RE_UpdateXPBar').OnClientEvent:Connect(function(current, max)
    local hud = getGui('ScreenGui_HUD')
    if hud and hud:FindFirstChild('XPLabel') then
        hud.XPLabel.Text = string.format('XP: %d/%d', current, max)
    end
end)

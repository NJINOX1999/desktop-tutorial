local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')

local player = Players.LocalPlayer
local gui = player:WaitForChild('PlayerGui')

local function getGui(name)
    return gui:FindFirstChild(name)
end

RemoteEvents:WaitForChild('RE_UpdateHUD').OnClientEvent:Connect(function(data)
    local hud = getGui('MainHUD')
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

RemoteEvents:WaitForChild('RE_ToggleShop').OnClientEvent:Connect(function()
    local shopMenu = getGui('ShopMenu')
    local shop = shopMenu and shopMenu:FindFirstChild('ShopGui')
    if shop then
        shop.Enabled = not shop.Enabled
    end
end)

RemoteEvents:WaitForChild('RE_ShowGameOver').OnClientEvent:Connect(function()
    local menu = getGui('LobbyMenu')
    if menu then
        menu.Enabled = true
    end
end)

RemoteEvents:WaitForChild('RE_SetDifficulty').OnClientEvent:Connect(function(diff)
    local menu = getGui('LobbyMenu')
    local label = menu and menu:FindFirstChild('DifficultyLabel')
    if label then
        label.Text = 'Difficulty: ' .. diff
    end
end)

RemoteEvents:WaitForChild('RE_ShowBuyback').OnClientEvent:Connect(function()
    local open = RemoteEvents:WaitForChild('RE_BuybackOpen')
    open:FireServer()
end)

RemoteEvents:WaitForChild('RE_SetGhostColor').OnClientEvent:Connect(function(color)
    local build = require(player.PlayerScripts:WaitForChild('cli_BuildSystem'))
    if build and build.SetGhostColor then
        build:SetGhostColor(color)
    end
end)

RemoteEvents:WaitForChild('RE_UpdateXPBar').OnClientEvent:Connect(function(current, max)
    local hud = getGui('MainHUD')
    if hud and hud:FindFirstChild('XPLabel') then
        hud.XPLabel.Text = string.format('XP: %d/%d', current, max)
    end
end)

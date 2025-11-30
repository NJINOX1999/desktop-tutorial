-- Handles shop toggling and purchases
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local RemoteFunctions = ReplicatedStorage:WaitForChild('RemoteFunctions')
local RE_ToggleShop = RemoteEvents:WaitForChild('RE_ToggleShop')
local RF_BuyItem = RemoteFunctions:WaitForChild('RF_BuyItem')
local RE_UpdateCoins = RemoteEvents:WaitForChild('RE_UpdateCoins')
local RE_UpdateAmmo = RemoteEvents:WaitForChild('RE_UpdateAmmo')
local Config = require(ReplicatedStorage.Config)

local prices = {
    Ammo = 5,
}

RE_ToggleShop.OnServerEvent:Connect(function(player)
    RE_ToggleShop:FireClient(player)
end)

RF_BuyItem.OnServerInvoke = function(player, item)
    if typeof(item) ~= 'string' then return false end
    local cost = prices[item]
    if not cost or not player._data or player._data.Coins < cost then
        return false
    end
    player._data.Coins = player._data.Coins - cost
    local ls = player:FindFirstChild('leaderstats')
    if ls and ls:FindFirstChild('Coins') then
        ls.Coins.Value = player._data.Coins
        RE_UpdateCoins:FireClient(player, ls.Coins.Value)
    end
    if item == 'Ammo' then
        player._data.Ammo = Config.StartAmmo
        player:SetAttribute('Ammo', player._data.Ammo)
        RE_UpdateAmmo:FireClient(player, player._data.Ammo)
    end
    return true
end

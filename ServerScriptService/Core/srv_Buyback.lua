local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Config = require(ReplicatedStorage.Modules.mod_Config)

local buyRemote = Instance.new('RemoteFunction')
buyRemote.Name = 'RF_BuyBack'
buyRemote.Parent = ReplicatedStorage.Remotes

local lostInventories = {}

_G.EventBus.Bind('GameOver', function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr._data then
            lostInventories[plr.UserId] = plr._data.Inventory
            plr._data.Inventory = {}
        end
    end
end)

buyRemote.OnServerInvoke = function(player)
    local inv = lostInventories[player.UserId]
    if not inv then return false end
    if player._data and player._data.Coins >= 10000 then
        player._data.Coins = player._data.Coins - 10000
        player._data.Inventory = inv
        lostInventories[player.UserId] = nil
        return true
    end
    return false
end

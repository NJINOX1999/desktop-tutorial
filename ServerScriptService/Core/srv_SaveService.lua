local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Config = require(ReplicatedStorage.Config)
local DataStore2 = require(script.Parent.Parent.Modules.mod_DataStore2)

local SAVE_INTERVAL = 120
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local RemoteFunctions = ReplicatedStorage:WaitForChild('RemoteFunctions')
local RF_SetSlot = RemoteFunctions:WaitForChild('RF_SetDataSlot')
local RE_UpdateCoins = RemoteEvents:WaitForChild('RE_UpdateCoins')
local RE_UpdateAmmo = RemoteEvents:WaitForChild('RE_UpdateAmmo')

local function getDefaultData()
    return {
        version = 1,
        Coins = 0,
        Level = 1,
        XP = 0,
        Inventory = {},
        Turrets = {},
        Pets = {},
        Settings = {Music = true, Particles = true},
        Weapon = Config.StartWeapon,
        Ammo = Config.StartAmmo
    }
end

local function getKey(player)
    local slot = player:GetAttribute('DataSlot') or 1
    return string.format('%d_%d', player.UserId, slot)
end

local function loadPlayer(player)
    local key = getKey(player)
    local data
    if player:GetAttribute('IsHost') then
        data = DataStore2:Get(key)
    end
    if not data then
        data = getDefaultData()
    end
    player._data = data
    player:SetAttribute('Level', data.Level or 1)
    player:SetAttribute('XP', data.XP or 0)
end

local function savePlayer(player)
    if not player or not player.UserId then return end
    if not player:GetAttribute('IsHost') then return end
    local key = getKey(player)
    local data = player._data or getDefaultData()
    DataStore2:Save(key, data)
end

local function setupLeaderstats(plr)
    local ls = Instance.new('Folder')
    ls.Name = 'leaderstats'
    ls.Parent = plr
    local coins = Instance.new('IntValue')
    coins.Name = 'Coins'
    coins.Value = plr._data.Coins or 0
    coins.Parent = ls
    coins.Changed:Connect(function(v)
        RE_UpdateCoins:FireClient(plr, v)
    end)
    RE_UpdateCoins:FireClient(plr, coins.Value)
end

Players.PlayerAdded:Connect(function(player)
    local first = Players:GetPlayers()[1]
    if player == first then
        player:SetAttribute('IsHost', true)
        player:SetAttribute('DataSlot', 1)
        loadPlayer(player)
    else
        player._data = getDefaultData()
        player:SetAttribute('Level', 1)
    end
    player._data.Weapon = player._data.Weapon or Config.StartWeapon
    player._data.Ammo = player._data.Ammo or Config.StartAmmo
    player:SetAttribute('Ammo', player._data.Ammo)
    RE_UpdateAmmo:FireClient(player, player._data.Ammo)
    player:GetAttributeChangedSignal('Ammo'):Connect(function()
        RE_UpdateAmmo:FireClient(player, player:GetAttribute('Ammo'))
    end)
    setupLeaderstats(player)
end)

RF_SetSlot.OnServerInvoke = function(player, slot)
    if not player:GetAttribute('IsHost') then
        return false
    end
    if typeof(slot) ~= 'number' or slot < 1 or slot > 3 then
        return false
    end
    player:SetAttribute('DataSlot', slot)
    loadPlayer(player)
    return true
end
Players.PlayerRemoving:Connect(function(player)
    if player:GetAttribute('IsHost') then
        savePlayer(player)
    end
end)
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute('IsHost') then
            savePlayer(player)
        end
    end
end)

while true do
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute('IsHost') then
            savePlayer(player)
        end
    end
    task.wait(SAVE_INTERVAL)
end

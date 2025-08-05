local Players = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SAVE_STORE = DataStoreService:GetDataStore('SaveSlots')
local SAVE_INTERVAL = 120

local remotes = ReplicatedStorage:WaitForChild('Remotes')
local RF_SetSlot = remotes:WaitForChild('RF_SetDataSlot')
local RE_UpdateCoins = remotes:WaitForChild('RE_UpdateCoins')
local RE_UpdateAmmo = remotes:WaitForChild('RE_UpdateAmmo')

local function getDefaultData()
    return {
        Coins = 0,
        Level = 1,
        XP = 0,
        Inventory = {},
        Turrets = {},
        Pets = {},
        Settings = {Music = true, Particles = true},
        Weapon = 1,
        Ammo = 0
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
        local success, result = pcall(function()
            return SAVE_STORE:GetAsync(key)
        end)
        if success and result then
            data = result
        end
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
    pcall(function()
        SAVE_STORE:SetAsync(key, data)
    end)
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
    if #Players:GetPlayers() > 6 then
        player:Kick('Server is full')
        return
    end
    local first = Players:GetPlayers()[1]
    if player == first then
        player:SetAttribute('IsHost', true)
        player:SetAttribute('DataSlot', 1)
        loadPlayer(player)
    else
        player._data = getDefaultData()
        player:SetAttribute('Level', 1)
    end
    player._data.Weapon = player._data.Weapon or 1
    player._data.Ammo = player._data.Ammo or 0
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


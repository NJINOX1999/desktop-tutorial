local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStoreService = game:GetService('DataStoreService')
local NetRateLimiter = require(script.Parent.Parent.Modules.NetRateLimiter)

local Config = require(ReplicatedStorage.Modules.mod_Config)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local playerStore = DataStoreService:GetDataStore('IsleboundData', 'v2')
local lockStore = DataStoreService:GetDataStore('IsleboundLocks', 'v1')

local SAVE_INTERVAL = 120
local remotes = ReplicatedStorage:WaitForChild('Remotes')
local RF_SetSlot = remotes:WaitForChild('RF_SetDataSlot')
local RE_UpdateCoins = remotes:WaitForChild('RE_UpdateCoins')
local RE_UpdateAmmo = remotes:WaitForChild('RE_UpdateAmmo')

local function waitBudget(reqType)
    while DataStoreService:GetRequestBudgetForRequestType(reqType) <= 0 do
        task.wait(0.1)
    end
end

local function retry(fn, reqType)
    local retries = GameConfig.Save.Retries or 5
    local delay = GameConfig.Save.BackoffBase or 0.5
    for _ = 1, retries do
        waitBudget(reqType)
        local ok, result = pcall(fn)
        if ok then
            return result
        end
        task.wait(delay)
        delay *= 2
    end
    warn('DataStore request failed after retries')
    return nil
end

local function acquireLock(userId)
    local key = ('session:%d'):format(userId)
    local acquired = false
    retry(function()
        lockStore:UpdateAsync(key, function(current)
            if current then
                return current
            end
            acquired = true
            return true
        end)
    end, Enum.DataStoreRequestType.UpdateAsync)
    return acquired
end

local function releaseLock(userId)
    local key = ('session:%d'):format(userId)
    retry(function()
        lockStore:RemoveAsync(key)
    end, Enum.DataStoreRequestType.UpdateAsync)
end

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
        Ammo = Config.StartAmmo,
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
        data = retry(function()
            return playerStore:GetAsync(key)
        end, Enum.DataStoreRequestType.GetAsync)
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
    retry(function()
        playerStore:UpdateAsync(key, function()
            return data
        end)
    end, Enum.DataStoreRequestType.UpdateAsync)
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
        if acquireLock(player.UserId) then
            loadPlayer(player)
        else
            warn('Save slot locked for player')
            player._data = getDefaultData()
            player:SetAttribute('SaveLocked', true)
        end
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
    if not NetRateLimiter.Allow(player, RF_SetSlot.Name) then
        return false
    end
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
        releaseLock(player.UserId)
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute('IsHost') then
            savePlayer(player)
            releaseLock(player.UserId)
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

-- DataStore v2 save service
local DataStoreService = game:GetService('DataStoreService')
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SAVE_INTERVAL = 120
local store = DataStoreService:GetDataStore('IsleboundData', 'v2')
local RF_SetSlot = ReplicatedStorage.Remotes:WaitForChild('RF_SetDataSlot')

local function getDefaultData()
    return {
        version = 1,
        Coins = 0,
        Level = 1,
        XP = 0,
        Inventory = {},
        Turrets = {},
        Pets = {},
        Settings = {Music = true, Particles = true}
    }
end

local function getKey(player)
    local slot = player:GetAttribute('DataSlot') or 1
    return string.format('%d_%d', player.UserId, slot)
end

local function loadPlayer(player)
    local key = getKey(player)
    local success, data = pcall(function()
        return store:GetAsync(key)
    end)
    if not success or not data then
        data = getDefaultData()
    end
    player._data = data
end

local function savePlayer(player)
    if not player or not player.UserId then return end
    local key = getKey(player)
    local data = player._data or getDefaultData()
    local success, err = pcall(function()
        store:UpdateAsync(key, function()
            return data
        end)
    end)
    if not success then
        warn('Failed to save data for', player, err)
    end
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute('DataSlot', 1)
    loadPlayer(player)
end)

RF_SetSlot.OnServerInvoke = function(player, slot)
    if typeof(slot) ~= 'number' or slot < 1 or slot > 3 then
        return false
    end
    player:SetAttribute('DataSlot', slot)
    loadPlayer(player)
    return true
end
Players.PlayerRemoving:Connect(savePlayer)
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayer(player)
    end
end)

while true do
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayer(player)
    end
    task.wait(SAVE_INTERVAL)
end

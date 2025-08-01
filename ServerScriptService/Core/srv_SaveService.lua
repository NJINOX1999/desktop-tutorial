-- DataStore v2 save service
local DataStoreService = game:GetService('DataStoreService')
local Players = game:GetService('Players')

local SAVE_INTERVAL = 120
local store = DataStoreService:GetDataStore('IsleboundData', 'v2')

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

local function loadPlayer(player)
    local key = tostring(player.UserId)
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
    local key = tostring(player.UserId)
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

Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(savePlayer)

while true do
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayer(player)
    end
    task.wait(SAVE_INTERVAL)
end

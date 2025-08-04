local DataStoreService = game:GetService('DataStoreService')

local store = DataStoreService:GetDataStore('IsleboundData', 'v2')
local DataStore2 = {}

function DataStore2:Get(key)
    local success, data = pcall(function()
        return store:GetAsync(key)
    end)
    if success then
        return data
    end
    return nil
end

function DataStore2:Save(key, data)
    local _ = pcall(function()
        store:UpdateAsync(key, function()
            return data
        end)
    end)
end

return DataStore2


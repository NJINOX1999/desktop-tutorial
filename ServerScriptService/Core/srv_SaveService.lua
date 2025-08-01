--[[
    Save Service Stub
    Handles DataStore persistence for player data.
]]

local SaveService = {}

function SaveService:load(player)
    -- TODO: load data from Roblox DataStore
    print("Loading save for", player.Name)
    return {}
end

function SaveService:save(player, data)
    -- TODO: save data to Roblox DataStore
    print("Saving data for", player.Name)
end

return SaveService

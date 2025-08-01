-- Handles build requests from clients
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

local BuildRequest = ReplicatedStorage.Remotes:WaitForChild('RE_BuildRequest')
local BuildValidator = require(script.Parent.Parent.Modules.mod_BuildValidator)
local Config = require(ReplicatedStorage.Modules.mod_Config)
local Tower = require(script.Parent.Parent.Modules.mod_Tower)

local builtCounts = {}
local Players = game:GetService('Players')

BuildRequest.OnServerEvent:Connect(function(player, itemId, pos, rot)
    if typeof(pos) ~= 'Vector3' or typeof(rot) ~= 'Vector3' or type(itemId) ~= 'string' then
        return
    end
    local count = builtCounts[player] or 0
    if count >= Config.MaxTurretsPerPlayer then
        return
    end
    if not BuildValidator:CanPlace(pos) then
        return
    end
    local cost = Config.TowerCost
    local data = player._data
    if not data or data.Coins < cost then
        return
    end
    local tower = ServerStorage.Assets.Towers:FindFirstChild(itemId)
    if tower then
        local obj = tower:Clone()
        obj:SetAttribute('IsBuilding', true)
        if not obj:FindFirstChild('Health') then
            local h = Instance.new('IntValue')
            h.Name = 'Health'
            h.Value = 100
            h.Parent = obj
        end
        obj.Parent = workspace.RuntimeObjects
        obj:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z)))
        Tower.StartTracking(obj)
        builtCounts[player] = count + 1
        data.Coins = data.Coins - cost
        obj.Destroying:Connect(function()
            builtCounts[player] = math.max((builtCounts[player] or 1) - 1, 0)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    builtCounts[plr] = nil
end)

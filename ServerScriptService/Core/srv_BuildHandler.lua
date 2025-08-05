--!nolint UnknownType

type Vector3 = any
type Instance = any
type RaycastParams = any

-- Handles build requests from clients
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local BuildRequest = RemoteEvents:WaitForChild('RE_BuildRequest')
local RE_BuildMessage = RemoteEvents:WaitForChild('RE_BuildMessage')
local RE_UpdateCoins = RemoteEvents:WaitForChild('RE_UpdateCoins')
local BuildValidator = require(ReplicatedStorage.Modules.mod_BuildValidator)
local Config = require(ReplicatedStorage.Config)
local Tower = require(script.Parent.Parent.Modules.mod_Tower)

local builtCounts = {}
local Players = game:GetService('Players')
local structuresFolder = ServerStorage:FindFirstChild('Structures')

BuildRequest.OnServerEvent:Connect(function(player, itemId, pos, rot)
    if typeof(pos) ~= 'Vector3' or typeof(rot) ~= 'Vector3' or type(itemId) ~= 'string' then
        return
    end
    local data = player._data or {Level = 1, Coins = 0, Inventory = {}}
    if not BuildValidator:CanPlace(pos) then
        return
    end
    local tower = ServerStorage.Towers:FindFirstChild(itemId)
    if tower then
        local level = player:GetAttribute('Level') or data.Level or 1
        local maxLimit = Config.BaseTurretLimit + math.max(0, level - 1)
        local count = builtCounts[player] or 0
        if count >= maxLimit then
            return
        end
        local cost = Config.BuildPrices[itemId]
        if not cost then return end
        local ls = player:FindFirstChild('leaderstats')
        local coins = data.Coins
        if ls and ls:FindFirstChild('Coins') then
            coins = ls.Coins.Value
        end
        if coins < cost then
            RE_BuildMessage:FireClient(player, 'Not enough coins')
            return
        end
        coins = coins - cost
        data.Coins = coins
        if ls and ls:FindFirstChild('Coins') then
            ls.Coins.Value = coins
        end
        RE_UpdateCoins:FireClient(player, coins)
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
        obj.Destroying:Connect(function()
            builtCounts[player] = math.max((builtCounts[player] or 1) - 1, 0)
        end)
    elseif structuresFolder then
        local structure = structuresFolder:FindFirstChild(itemId)
        if not structure then return end
        local requirements = Config.StructureCosts[itemId]
        if not requirements then return end
        for res, amt in pairs(requirements) do
            if (data.Inventory[res] or 0) < amt then
                RE_BuildMessage:FireClient(player, 'Need ' .. res)
                return
            end
        end
        for res, amt in pairs(requirements) do
            data.Inventory[res] = data.Inventory[res] - amt
        end
        local obj = structure:Clone()
        obj:SetAttribute('IsBuilding', true)
        if not obj:FindFirstChild('Health') then
            local h = Instance.new('IntValue')
            h.Name = 'Health'
            h.Value = 100
            h.Parent = obj
        end
        obj.Parent = workspace.RuntimeObjects
        obj:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z)))
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    builtCounts[plr] = nil
end)

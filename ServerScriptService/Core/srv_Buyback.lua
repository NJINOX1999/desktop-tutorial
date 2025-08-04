local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('Remotes')
local RE_BuybackOpen = Remotes:WaitForChild('RE_BuybackOpen')
local RF_BuybackItem = Remotes:WaitForChild('RF_BuybackItem')
local Config = require(ReplicatedStorage.Modules.mod_Config)

local lost = {}

local function captureInventory(plr)
    local items = {}
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA('Tool') then
            tool.Parent = nil
            table.insert(items, {tool = tool, price = Config.BuybackPrice})
        end
    end
    local char = plr.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA('Tool') then
                tool.Parent = nil
                table.insert(items, {tool = tool, price = Config.BuybackPrice})
            end
        end
    end
    if #items > 0 then
        lost[plr] = items
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterRemoving:Connect(function()
        captureInventory(plr)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    lost[plr] = nil
end)

RE_BuybackOpen.OnServerEvent:Connect(function(plr)
    local data = {}
    for _, info in ipairs(lost[plr] or {}) do
        table.insert(data, {name = info.tool.Name, price = info.price})
    end
    RE_BuybackOpen:FireClient(plr, data)
end)

RF_BuybackItem.OnServerInvoke = function(plr, itemName)
    local items = lost[plr]
    if not items then return false end
    local stats = plr:FindFirstChild('leaderstats')
    if not stats or not stats:FindFirstChild('Coins') then return false end
    for i, info in ipairs(items) do
        if info.tool.Name == itemName and stats.Coins.Value >= info.price then
            stats.Coins.Value = stats.Coins.Value - info.price
            info.tool.Parent = plr.Backpack
            table.remove(items, i)
            return true
        end
    end
    return false
end

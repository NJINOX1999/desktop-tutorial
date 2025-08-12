-- Handles crystal placement and destruction events
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local NetRateLimiter = require(script.Parent.Parent.Modules.NetRateLimiter)
local CrystalModule = require(script.Parent.Parent.Modules.mod_Crystal)
local MonsterBuffService = require(script.Parent.Parent.Modules.mod_MonsterBuffService)
local ServerStorage = game:GetService('ServerStorage')
local remotes = ReplicatedStorage:WaitForChild('Remotes')
local rePlace = remotes:WaitForChild('RE_CrystalPlaced')
local reAssign = remotes:WaitForChild('RE_AssignCrystal')

local function spawnCrystal(pos)
    local crystal = Instance.new('Part')
    crystal.Name = 'Crystal'
    crystal.Size = Vector3.new(2,4,2)
    crystal.Anchored = true
    crystal.CFrame = CFrame.new(pos)
    crystal.Parent = workspace
    CrystalModule:Reset()
    _G.EventBus.Fire('CrystalPlaced')
end

local function giveCrystalItem(player)
    local tools = ServerStorage:FindFirstChild('Tools')
    local template = tools and tools:FindFirstChild('CrystalTool')
    if template then
        local tool = template:Clone()
        tool.Parent = player:FindFirstChildOfClass('Backpack') or player:WaitForChild('Backpack')
    end
end

rePlace.OnServerEvent:Connect(function(player, pos)
    if not NetRateLimiter.Allow(player, rePlace.Name) then return end
    if typeof(pos) ~= 'Vector3' then return end
    -- only host or assigned player may place
    if player ~= Players:GetPlayers()[1] then return end
    if workspace:FindFirstChild('Crystal') then return end
    spawnCrystal(pos)
end)

_G.EventBus.Bind('CrystalDestroyed', function()
    if CrystalModule:ShouldGameOver() then
        _G.EventBus.Fire('GameOver')
        return
    end
    for _, obj in ipairs(workspace.RuntimeObjects:GetChildren()) do
        MonsterBuffService.apply(obj)
    end
    local host = Players:GetPlayers()[1]
    if host then
        giveCrystalItem(host)
        reAssign:FireClient(host)
    end
end)

return {}

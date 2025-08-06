-- Handles crystal placement and destruction events
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local Players = game:GetService('Players')
local CrystalModule = require(script.Parent.Parent.Modules.mod_Crystal)
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
    if _G.GameState then
        _G.GameState.CrystalDestroyed = false
    end
    if _G.EnemyBuffService then
        _G.EnemyBuffService.BoostActive = false
    end
    _G.EventBus.Fire('CrystalPlaced')
end

local function giveCrystalItem(player)
    local tools = ServerStorage:FindFirstChild('Tools')
    local template = tools and tools:FindFirstChild('CrystalTool')
    local backpack = player:FindFirstChildOfClass('Backpack') or player:WaitForChild('Backpack')
    if template and backpack then
        local tool = template:Clone()
        tool.Parent = backpack
    end
end

rePlace.OnServerEvent:Connect(function(player, pos)
    if typeof(pos) ~= 'Vector3' then return end
    -- only host or assigned player may place
    if player ~= Players:GetPlayers()[1] then return end
    if workspace:FindFirstChild('Crystal') then return end
    spawnCrystal(pos)
end)

_G.EventBus.Bind('CrystalDestroyed', function()
    if _G.GameState then
        _G.GameState.CrystalDestroyed = true
    end
    if _G.EnemyBuffService then
        _G.EnemyBuffService.BoostActive = true
    end
    local host = Players:GetPlayers()[1]
    if host then
        giveCrystalItem(host)
        reAssign:FireClient(host)
    end
end)

return {}

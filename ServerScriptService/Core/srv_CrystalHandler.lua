-- Handles crystal placement and destruction events
local ReplicatedStorage = game:GetService('ReplicatedStorage')
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
    crystal.Parent = workspace.RuntimeObjects
    CrystalModule:Reset()
    _G.EventBus.Fire('CrystalPlaced')
end

rePlace.OnServerEvent:Connect(function(player, pos)
    if typeof(pos) ~= 'Vector3' then return end
    -- only host or assigned player may place
    if player ~= Players:GetPlayers()[1] then return end
    if workspace.RuntimeObjects:FindFirstChild('Crystal') then return end
    spawnCrystal(pos)
end)

_G.EventBus.Bind('CrystalDestroyed', function()
    if CrystalModule:ShouldGameOver() then
        _G.EventBus.Fire('GameOver')
        return
    end
    local host = Players:GetPlayers()[1]
    if host then
        reAssign:FireClient(host)
    end
end)

return {}

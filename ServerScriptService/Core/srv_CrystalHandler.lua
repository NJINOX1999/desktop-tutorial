--!nolint UnknownType

type Vector3 = any
type Instance = any
type CFrame = any

-- Handles crystal placement and destruction events
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local CrystalModule = require(script.Parent.Parent.Modules.mod_Crystal)
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local rePlace = RemoteEvents:WaitForChild('RE_CrystalPlaced')
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

rePlace.OnServerEvent:Connect(function(player, pos)
    if typeof(pos) ~= 'Vector3' then return end
    -- only host or assigned player may place
    if player ~= Players:GetPlayers()[1] then return end
    if workspace:FindFirstChild('Crystal') then return end
    spawnCrystal(pos)
end)

return {}

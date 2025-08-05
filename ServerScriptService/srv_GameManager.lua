--!nolint UnknownType

-- Coordinates game-wide events like crystal destruction and game over checks
local Players = game:GetService('Players')
local MonsterBuffService = require(script.Parent.Modules.mod_MonsterBuffService)
local Crystal = require(script.Parent.Modules.mod_Crystal)

local function spawnCrystal(position)
    local crystal = Instance.new('Part')
    crystal.Name = 'Crystal'
    crystal.Size = Vector3.new(2,4,2)
    crystal.Anchored = true
    crystal.CFrame = CFrame.new(position)
    crystal.Parent = workspace
    Crystal:Reset()
    _G.EventBus.Fire('CrystalPlaced')
end

_G.EventBus.Bind('CrystalPlaced', function()
    local crystal = workspace:FindFirstChild('Crystal')
    if crystal and crystal:IsA('BasePart') then
        _G.lastCrystalPos = crystal.Position
    end
end)

_G.EventBus.Bind('CrystalDestroyed', function()
    -- buff existing monsters
    for _, obj in ipairs(workspace.RuntimeObjects:GetChildren()) do
        if obj:FindFirstChildOfClass('Humanoid') then
            MonsterBuffService.apply(obj)
        end
    end
    if Crystal:ShouldGameOver() then
        _G.EventBus.Fire('GameOver')
        return
    end
    local pos = _G.lastCrystalPos or Vector3.new(0,5,0)
    spawnCrystal(pos)
end)

Players.PlayerRemoving:Connect(function()
    if Crystal:ShouldGameOver() then
        _G.EventBus.Fire('GameOver')
    end
end)

return {}

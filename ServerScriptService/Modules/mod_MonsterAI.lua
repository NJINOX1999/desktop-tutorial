-- Basic monster AI following project specification
local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')

local Crystal = require(script.Parent.mod_Crystal)
local DropTable = require(script.Parent.mod_DropTable)

local MonsterAI = {}
MonsterAI.__index = MonsterAI

function MonsterAI.new(model)
    local self = setmetatable({}, MonsterAI)
    self.model = model
    self.humanoid = model:FindFirstChildOfClass('Humanoid')
    self._path = nil
    self._target = nil
    if self.humanoid then
        self.humanoid.Died:Connect(function()
            local loot = DropTable:GetLoot(model.Name)
            if loot then
                local p = Instance.new('Part')
                p.Name = loot.itemId
                p.Position = model.PrimaryPart.Position
                p.Size = Vector3.new(1,1,1)
                p.Anchored = true
                p:SetAttribute('Coins', loot.qty or 1)
                p.Parent = workspace.RuntimeObjects
                task.delay(10, function()
                    if p.Parent then p:Destroy() end
                end)
            end
        end)
    end
    return self
end

function MonsterAI:getTarget()
    local nearest
    local dist = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and char:FindFirstChild('HumanoidRootPart') then
            local d = (char.HumanoidRootPart.Position - self.model.PrimaryPart.Position).Magnitude
            if d < 30 and d < dist then
                dist = d
                nearest = char.HumanoidRootPart
            end
        end
    end
    if nearest then return nearest end
    local crystal = workspace:FindFirstChild('Crystal')
    if crystal and crystal:IsA('BasePart') then
        return crystal
    end
    return nil
end

function MonsterAI:computePath(target)
    local path = PathfindingService:CreatePath()
    local success = pcall(function()
        path:ComputeAsync(self.model.PrimaryPart.Position, target.Position)
    end)
    if success and path.Status == Enum.PathStatus.Success then
        self._path = path:GetWaypoints()
    else
        self._path = nil
    end
end

function MonsterAI:moveAlongPath()
    if not self._path then return end
    local waypoint = self._path[1]
    if waypoint then
        table.remove(self._path, 1)
        self.humanoid:MoveTo(waypoint.Position)
    end
end

function MonsterAI:attack(target)
    if target:IsA('BasePart') then
        if target.Parent:FindFirstChildOfClass('Humanoid') then
            target.Parent.Humanoid:TakeDamage(5)
        elseif target.Name == 'Crystal' then
            Crystal:Damage(5)
        end
    end
end

function MonsterAI:update()
    if not self.humanoid or not self.model.PrimaryPart then return end
    local target = self:getTarget()
    if target and target ~= self._target then
        self._target = target
        self:computePath(target)
    end
    if self._path and #self._path > 0 then
        self:moveAlongPath()
    elseif target then
        if (target.Position - self.model.PrimaryPart.Position).Magnitude < 4 then
            self:attack(target)
        else
            self:computePath(target)
        end
    end
end

function MonsterAI:Start()
    task.spawn(function()
        while self.model.Parent do
            self:update()
            task.wait(1)
        end
    end)
end

return MonsterAI

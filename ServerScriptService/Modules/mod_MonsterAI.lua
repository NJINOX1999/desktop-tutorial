-- Basic monster AI following project specification
local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')

local Crystal = require(script.Parent.mod_Crystal)
local DropTable = require(script.Parent.mod_DropTable)
local Utilities = require(script.Parent.mod_Utilities)
local AnimUtil = require(script.Parent.mod_AnimationUtil)

local MonsterAI = {}
MonsterAI.__index = MonsterAI

function MonsterAI.new(model)
    local self = setmetatable({}, MonsterAI)
    self.model = model
    self.humanoid = model:FindFirstChildOfClass('Humanoid')
    self._path = nil
    self._target = nil
    self.damageBuffed = false
    if self.humanoid then
        self.walkAnim = nil
        self.attackAnim = nil
        self.deathAnim = nil
        local w = AnimUtil.load('MonsterWalk')
        if w then self.walkAnim = self.humanoid:LoadAnimation(w) end
        local a = AnimUtil.load('MonsterAttack')
        if a then self.attackAnim = self.humanoid:LoadAnimation(a) end
        local d = AnimUtil.load('MonsterDie')
        if d then self.deathAnim = self.humanoid:LoadAnimation(d) end
        self.humanoid.Died:Connect(function()
            if self.deathAnim then self.deathAnim:Play() end
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
            for _, plr in ipairs(Players:GetPlayers()) do
                Utilities.addXP(plr, 5)
            end
        end)
        _G.EventBus.Bind('CrystalDestroyed', function()
            if self.humanoid and self.humanoid.Health > 0 then
                self.humanoid.WalkSpeed = self.humanoid.WalkSpeed * require(game:GetService('ReplicatedStorage').Modules.mod_Config).CrystalBuffMultiplier
                self.damageBuffed = true
            end
        end)
        _G.EventBus.Bind('CrystalPlaced', function()
            if self.humanoid and self.humanoid.Health > 0 and self.damageBuffed then
                local mul = require(game:GetService('ReplicatedStorage').Modules.mod_Config).CrystalBuffMultiplier
                self.humanoid.WalkSpeed = self.humanoid.WalkSpeed / mul
                self.damageBuffed = false
            end
        end)
        if self.walkAnim then self.walkAnim:Play() end
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
    -- check for nearby buildings
    local closestBuild
    for _, obj in ipairs(workspace.RuntimeObjects:GetChildren()) do
        if obj:IsA('Model') and obj:GetAttribute('IsBuilding') then
            if obj.PrimaryPart then
                local d = (obj.PrimaryPart.Position - self.model.PrimaryPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closestBuild = obj.PrimaryPart
                end
            end
        end
    end
    if closestBuild then return closestBuild end
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
        local dmg = 5
        if self.damageBuffed then
            dmg = dmg * require(game:GetService('ReplicatedStorage').Modules.mod_Config).CrystalBuffMultiplier
        end
        if self.attackAnim then self.attackAnim:Play() end
        if target.Parent:FindFirstChildOfClass('Humanoid') then
            target.Parent.Humanoid:TakeDamage(dmg)
        elseif target.Parent:GetAttribute('IsBuilding') then
            if target.Parent:FindFirstChild('Health') then
                target.Parent.Health.Value = math.max(target.Parent.Health.Value - dmg, 0)
                if target.Parent.Health.Value <= 0 then
                    target.Parent:Destroy()
                end
            else
                target.Parent:Destroy()
            end
        elseif target.Name == 'Crystal' then
            Crystal:Damage(dmg)
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
        if self.walkAnim and not self.walkAnim.IsPlaying then
            self.walkAnim:Play()
        end
    elseif target then
        if (target.Position - self.model.PrimaryPart.Position).Magnitude < 4 then
            self:attack(target)
            if self.walkAnim then self.walkAnim:Stop() end
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

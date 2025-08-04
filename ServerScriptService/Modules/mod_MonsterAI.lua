-- Basic monster AI following project specification
local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')

local Crystal = require(script.Parent.mod_Crystal)
local DropTable = require(script.Parent.mod_DropTable)
local Utilities = require(script.Parent.mod_Utilities)
local AnimUtil = require(game:GetService('ReplicatedStorage').Modules.mod_AnimationManager)
local Config = require(game:GetService('ReplicatedStorage').Modules.mod_Config)

local MonsterAI = {}
MonsterAI.__index = MonsterAI

function MonsterAI.new(model)
    local self = setmetatable({}, MonsterAI)
    self.model = model
    self.humanoid = model:FindFirstChildOfClass('Humanoid')
    self._path = nil
    self._target = nil
    self._lastPathCompute = 0
    self.crystalBuffed = false
    if self.humanoid then
        self.walkAnim = AnimUtil.loadTrack(self.humanoid, 'Anim_Walk')
        self.attackAnim = AnimUtil.loadTrack(self.humanoid, 'Anim_Attack')
        self.deathAnim = AnimUtil.loadTrack(self.humanoid, 'Anim_Death')
        self.humanoid.Died:Connect(function()
            if self.deathAnim then self.deathAnim:Play() end
            local loots = DropTable:getDrops(model.Name)
            for _, loot in ipairs(loots) do
                local p = Instance.new('Part')
                p.Name = loot.itemId
                p.Position = model.PrimaryPart.Position + Vector3.new(0, 2, 0)
                p.Size = Vector3.new(1,1,1)
                p.Anchored = true
                if loot.itemId == 'Coin' then
                    p:SetAttribute('Coins', loot.qty)
                else
                    p:SetAttribute('ItemId', loot.itemId)
                    p:SetAttribute('Qty', loot.qty)
                end
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
            if self.humanoid and self.humanoid.Health > 0 and not self.crystalBuffed then
                self.humanoid.WalkSpeed = self.humanoid.WalkSpeed * Config.CrystalBuffMultiplier
                self.humanoid.MaxHealth = self.humanoid.MaxHealth * Config.CrystalBuffMultiplier
                self.humanoid.Health = self.humanoid.Health * Config.CrystalBuffMultiplier
                local mul = self.model:GetAttribute('DamageMul') or 1
                self.model:SetAttribute('DamageMul', mul * Config.CrystalBuffDamageMultiplier)
                self.crystalBuffed = true
            end
        end)
        _G.EventBus.Bind('CrystalPlaced', function()
            if self.humanoid and self.humanoid.Health > 0 and self.crystalBuffed then
                self.humanoid.WalkSpeed = self.humanoid.WalkSpeed / Config.CrystalBuffMultiplier
                self.humanoid.MaxHealth = self.humanoid.MaxHealth / Config.CrystalBuffMultiplier
                self.humanoid.Health = math.min(self.humanoid.Health, self.humanoid.MaxHealth)
                local mul = self.model:GetAttribute('DamageMul') or 1
                self.model:SetAttribute('DamageMul', mul / Config.CrystalBuffDamageMultiplier)
                self.crystalBuffed = false
            end
        end)
        if _G.crystalLost then
            self.crystalBuffed = true
        end
        if self.walkAnim then self.walkAnim:Play() end
    end
    return self
end

function MonsterAI:getTarget()
    local nearest
    local dist = 15
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and char:FindFirstChild('HumanoidRootPart') then
            local d = (char.HumanoidRootPart.Position - self.model.PrimaryPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = char.HumanoidRootPart
            end
        end
    end
    if nearest then return nearest end

    local closestBuild
    local buildDist = math.huge
    for _, obj in ipairs(workspace.RuntimeObjects:GetChildren()) do
        if obj:IsA('Model') and obj:GetAttribute('IsBuilding') and obj.PrimaryPart then
            local d = (obj.PrimaryPart.Position - self.model.PrimaryPart.Position).Magnitude
            if d < buildDist then
                buildDist = d
                closestBuild = obj.PrimaryPart
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
        local dmg = 5 * (self.model:GetAttribute('DamageMul') or 1)
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
    if target and (target ~= self._target or os.clock() - self._lastPathCompute > 3) then
        self._target = target
        self:computePath(target)
        self._lastPathCompute = os.clock()
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
            if os.clock() - self._lastPathCompute > 3 then
                self:computePath(target)
                self._lastPathCompute = os.clock()
            end
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

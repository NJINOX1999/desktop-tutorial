-- Simple tower behavior attacking nearby monsters
local RunService = game:GetService('RunService')

local Tower = {}
Tower.__index = Tower

function Tower.new(model)
    local self = setmetatable({}, Tower)
    self.model = model
    self.range = 30
    self.damage = 10
    self.cooldown = 1
    self._timer = 0
    return self
end

function Tower:findTarget()
    local nearest
    local dist = self.range
    for _, mob in ipairs(workspace.RuntimeObjects:GetChildren()) do
        local hum = mob:FindFirstChildOfClass('Humanoid')
        if hum and hum.Health > 0 and mob:FindFirstChild('HumanoidRootPart') then
            local d = (mob.HumanoidRootPart.Position - self.model.PrimaryPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = hum
            end
        end
    end
    return nearest
end

function Tower:step(dt)
    self._timer = self._timer + dt
    if self._timer < self.cooldown then return end
    self._timer = 0
    local target = self:findTarget()
    if target then
        target:TakeDamage(self.damage)
    end
end

function Tower.StartTracking(towerModel)
    local tower = Tower.new(towerModel)
    RunService.Heartbeat:Connect(function(dt)
        if towerModel.Parent then
            tower:step(dt)
        end
    end)
end

return Tower

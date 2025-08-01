-- Basic monster AI following project specification
local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')

local MonsterAI = {}
MonsterAI.__index = MonsterAI

function MonsterAI.new(model)
    local self = setmetatable({}, MonsterAI)
    self.model = model
    self.humanoid = model:FindFirstChildOfClass('Humanoid')
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

function MonsterAI:update()
    if not self.humanoid or not self.model.PrimaryPart then return end
    local target = self:getTarget()
    if target then
        self.humanoid:MoveTo(target.Position)
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

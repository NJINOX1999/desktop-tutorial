--[[
    Improved Monster AI
    Spawns humanoid based monsters that chase players or the crystal.
]]

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local MonsterAI = {}

local runtimeFolder = workspace:FindFirstChild("RuntimeObjects") or Instance.new("Folder", workspace)
runtimeFolder.Name = "RuntimeObjects"

local CrystalManager = require(game.ServerScriptService.Core.srv_CrystalManager)

local function findTarget(rootPart)
    local closest
    local dist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char and char.PrimaryPart then
            local d = (char.PrimaryPart.Position - rootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = char
            end
        end
    end
    if not closest then
        closest = CrystalManager.getCrystal()
    end
    return closest
end

local function followTarget(humanoid, rootPart, target)
    if not target or not target.PrimaryPart then return end
    local path = PathfindingService:CreatePath()
    local success = pcall(function()
        path:ComputeAsync(rootPart.Position, target.PrimaryPart.Position)
    end)
    if success and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(wp.Position)
            humanoid.MoveToFinished:Wait()
        end
    else
        humanoid:MoveTo(target.PrimaryPart.Position)
        humanoid.MoveToFinished:Wait()
    end
end

function MonsterAI.spawn(position)
    local model = Instance.new("Model")
    model.Name = "Monster"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 2)
    root.Position = position
    root.Anchored = false
    root.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.WalkSpeed = 12
    humanoid.MaxHealth = 50
    humanoid.Health = 50
    humanoid.Parent = model

    model.PrimaryPart = root
    model.Parent = runtimeFolder

    task.spawn(function()
        while humanoid.Health > 0 do
            local target = findTarget(root)
            if target then
                followTarget(humanoid, root, target)
                if target.PrimaryPart and (root.Position - target.PrimaryPart.Position).Magnitude < 4 then
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:TakeDamage(5)
                    elseif target.Name == "Crystal" then
                        CrystalManager.damage(5)
                    end
                end
            end
            task.wait(0.5)
        end
        model:Destroy()
    end)

    return model
end

return MonsterAI

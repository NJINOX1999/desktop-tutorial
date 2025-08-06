local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local RE_StartHeal = ReplicatedStorage.Remotes:WaitForChild('RE_StartHeal')
local RE_StopHeal = ReplicatedStorage.Remotes:WaitForChild('RE_StopHeal')

local player = Players.LocalPlayer

local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'DownPromptGui'
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild('PlayerGui')

local label = Instance.new('TextLabel')
label.Size = UDim2.new(0, 200, 0, 50)
label.Position = UDim2.new(0.5, -100, 0.8, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.Visible = false
label.Parent = screenGui

local currentTarget
local currentKey

local function findTarget()
    local char = player.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')
    if not root then
        return
    end
    local nearest, isDowned
    local dist = 10
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass('Humanoid')
            local root2 = plr.Character:FindFirstChild('HumanoidRootPart')
            if hum and root2 then
                local d = (root2.Position - root.Position).Magnitude
                if d <= dist and hum.Health > 0 then
                    local down = hum.PlatformStand
                    local healable = not down and hum.Health < hum.MaxHealth * 0.5
                    if down or healable then
                        nearest, isDowned = plr, down
                        dist = d
                    end
                end
            end
        end
    end
    return nearest, isDowned
end

RunService.Heartbeat:Connect(function()
    local target, downed = findTarget()
    if target then
        currentTarget = target
        if downed then
            label.Text = 'Hold E to Revive'
            currentKey = Enum.KeyCode.E
        else
            label.Text = 'Hold H to Heal'
            currentKey = Enum.KeyCode.H
        end
        label.Visible = true
    else
        label.Visible = false
        currentTarget = nil
        currentKey = nil
        RE_StopHeal:FireServer()
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if currentTarget and input.KeyCode == currentKey then
        RE_StartHeal:FireServer(currentTarget)
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == currentKey then
        RE_StopHeal:FireServer()
    end
end)

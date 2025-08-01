local tool = Instance.new('Tool')
tool.Name = 'CrystalTool'
local players = game:GetService('Players')
local remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')
local rePlace = remotes:WaitForChild('RE_CrystalPlaced')

tool.Activated:Connect(function()
    local player = tool.Parent and players:GetPlayerFromCharacter(tool.Parent)
    if player and player.Character then
        local root = player.Character:FindFirstChild('HumanoidRootPart')
        if root then
            rePlace:FireServer(root.Position + root.CFrame.LookVector * 5)
        end
    end
end)

return tool

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local RE_Revive = RemoteEvents:WaitForChild('RE_RequestRevive')
local RE_Heal = RemoteEvents:WaitForChild('RE_RequestHeal')
local RE_ToggleShop = RemoteEvents:WaitForChild('RE_ToggleShop')
local UIS = game:GetService('UserInputService')
local player = game.Players.LocalPlayer

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        local target = nil
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
                local rootPos = plr.Character.HumanoidRootPart.Position
                local myPos = player.Character and player.Character.HumanoidRootPart.Position
                if myPos and (rootPos - myPos).Magnitude < 6 then
                    target = plr
                    break
                end
            end
        end
        if target and target.Character and target.Character.Humanoid.Health <= 0 then
            RE_Revive:FireServer(target)
        elseif target then
            RE_Heal:FireServer(target)
        end
    end
    if input.KeyCode == Enum.KeyCode.B then
        RE_ToggleShop:FireServer()
    end
end)

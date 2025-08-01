local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RF_SetSlot = ReplicatedStorage.Remotes:WaitForChild('RF_SetDataSlot')
local player = game.Players.LocalPlayer

local gui = Instance.new('ScreenGui')
local frame = Instance.new('Frame')
frame.Size = UDim2.fromScale(0.3,0.3)
frame.Position = UDim2.fromScale(0.35,0.3)
frame.Parent = gui
for i=1,3 do
    local btn = Instance.new('TextButton')
    btn.Size = UDim2.fromScale(0.8,0.25)
    btn.Position = UDim2.fromScale(0.1, (i-1)*0.3+0.05)
    btn.Text = "Slot "..i
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        local ok = RF_SetSlot:InvokeServer(i)
        if ok then
            gui.Enabled = false
        end
    end)
end
gui.Parent = player:WaitForChild('PlayerGui')

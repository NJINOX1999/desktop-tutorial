local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteFunctions = ReplicatedStorage:WaitForChild('RemoteFunctions')
local RF_BuyItem = RemoteFunctions:WaitForChild('RF_BuyItem')
local Locale = require(ReplicatedStorage.Modules.mod_Locale).en

local gui = script.Parent
local btn = gui:WaitForChild('BuyAmmoButton')
local message = gui:FindFirstChild('MessageLabel')

gui.Enabled = false

btn.MouseButton1Click:Connect(function()
    local ok = RF_BuyItem:InvokeServer('Ammo')
    if message then
        message.Text = ok and (Locale.shop .. ': OK') or (Locale.shop .. ': Fail')
    end
end)

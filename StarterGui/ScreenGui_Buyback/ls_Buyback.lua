local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('Remotes')
local RE_BuybackOpen = Remotes:WaitForChild('RE_BuybackOpen')
local RF_BuybackItem = Remotes:WaitForChild('RF_BuybackItem')

local gui = script.Parent
local listFrame = gui:WaitForChild('ItemList')
local template = listFrame:WaitForChild('ItemTemplate')

gui.Enabled = false

local function clear()
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA('GuiButton') and child ~= template then
            child:Destroy()
        end
    end
end

RE_BuybackOpen.OnClientEvent:Connect(function(items)
    clear()
    for _, info in ipairs(items) do
        local btn = template:Clone()
        btn.Text = info.name .. ' - ' .. info.price .. 'c'
        btn.Visible = true
        btn.Parent = listFrame
        btn.MouseButton1Click:Connect(function()
            if RF_BuybackItem:InvokeServer(info.name) then
                btn:Destroy()
            end
        end)
    end
    gui.Enabled = true
end)

return {}

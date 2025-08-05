local tool = script.Parent
local Players = game:GetService('Players')

local previous = {}

local function setWeapon(plr, name)
    if plr._data then
        plr._data.Weapon = name
    end
end

tool.Equipped:Connect(function()
    local plr = Players:GetPlayerFromCharacter(tool.Parent)
    if plr then
        previous[plr] = (plr._data and plr._data.Weapon) or 'Hands'
        setWeapon(plr, 'Pickaxe')
    end
end)

tool.Unequipped:Connect(function()
    local plr = Players:GetPlayerFromCharacter(tool.Parent)
    if plr then
        setWeapon(plr, previous[plr] or 'Hands')
    end
end)

local tool = script.Parent
local Players = game:GetService("Players")

local function setWeaponType(character, value)
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		player:SetAttribute("WeaponType", value)
	end
end

tool.Equipped:Connect(function()
	local character = tool.Parent
	setWeaponType(character, "Sword")
end)

tool.Unequipped:Connect(function()
	local character = tool.Parent
	setWeaponType(character, "Fists")
end)

tool.AncestryChanged:Connect(function()
	local character = tool.Parent
	if character and character:IsA("Model") then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			setWeaponType(character, "Fists")
		end
	end
end)

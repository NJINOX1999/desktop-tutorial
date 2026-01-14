local Hitbox = {}

local function getCharacterFromPart(part)
	if not part then return nil end
	local model = part:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return model
	end
	return nil
end

local function uniqueCharactersFromParts(parts)
	local found = {}
	for _, part in ipairs(parts) do
		local character = getCharacterFromPart(part)
		if character then
			found[character] = true
		end
	end
	local list = {}
	for character in pairs(found) do
		table.insert(list, character)
	end
	return list
end

function Hitbox.Box(cframe, size, overlapParams)
	local parts = workspace:GetPartBoundsInBox(cframe, size, overlapParams)
	return uniqueCharactersFromParts(parts)
end

function Hitbox.Radius(position, radius, overlapParams)
	local parts = workspace:GetPartBoundsInRadius(position, radius, overlapParams)
	return uniqueCharactersFromParts(parts)
end

return Hitbox

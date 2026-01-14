local StunService = {}

local activeStuns = {}

function StunService:IsStunned(character)
	return character:GetAttribute("Stunned") == true
end

function StunService:ApplyStun(character, duration)
	if not character or duration <= 0 then return end
	local token = os.clock()
	activeStuns[character] = token
	character:SetAttribute("Stunned", true)

	task.delay(duration, function()
		if activeStuns[character] == token then
			activeStuns[character] = nil
			if character then
				character:SetAttribute("Stunned", false)
			end
		end
	end)
end

return StunService

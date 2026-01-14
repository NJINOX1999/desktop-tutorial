local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local CombatEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CombatEvent")

local function onSkill(actionName, inputState)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	local skillId = tonumber(actionName:match("Skill(%d)"))
	if skillId then
		CombatEvent:FireServer(skillId)
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("Skill1", onSkill, false, Enum.KeyCode.Q)
ContextActionService:BindAction("Skill2", onSkill, false, Enum.KeyCode.E)
ContextActionService:BindAction("Skill3", onSkill, false, Enum.KeyCode.R)
ContextActionService:BindAction("Skill4", onSkill, false, Enum.KeyCode.F)

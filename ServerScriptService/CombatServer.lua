local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatService = require(ReplicatedStorage.Modules.CombatService)
local CombatEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CombatEvent")

CombatEvent.OnServerEvent:Connect(function(player, skillId)
	CombatService:ActivateSkill(player, skillId)
end)

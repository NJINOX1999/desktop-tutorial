local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CombatConfig = require(script.Parent.CombatConfig)
local Hitbox = require(script.Parent.Hitbox)
local StunService = require(script.Parent.StunService)

local CombatService = {}

local cooldowns = {} -- cooldowns[player][weaponType][skill] = lastUseTime

local function isAlive(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0
end

local function getRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function getWeaponType(player)
	local wt = player:GetAttribute("WeaponType")
	if wt ~= "Sword" then
		return "Fists"
	end
	return "Sword"
end

local function canUseSkill(player, character)
	if not player or not character then return false end
	if not isAlive(character) then return false end
	if StunService:IsStunned(character) then return false end
	return true
end

local function getSkillConfig(weaponType, skillId)
	if weaponType == "Sword" then
		return CombatConfig.SWORD[skillId]
	end
	return CombatConfig.FISTS[skillId]
end

local function getCooldownTable(player, weaponType)
	cooldowns[player] = cooldowns[player] or {}
	cooldowns[player][weaponType] = cooldowns[player][weaponType] or {}
	return cooldowns[player][weaponType]
end

local function onCooldown(player, weaponType, skillId, cooldown)
	local now = os.clock()
	local tbl = getCooldownTable(player, weaponType)
	local last = tbl[skillId] or 0
	return (now - last) < cooldown
end

local function setCooldown(player, weaponType, skillId)
	local tbl = getCooldownTable(player, weaponType)
	tbl[skillId] = os.clock()
end

local function applyDamageAndKnockback(attacker, targets, damage, knockback)
	for _, character in ipairs(targets) do
		if character ~= attacker and isAlive(character) then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local root = getRoot(character)
			if humanoid then
				humanoid:TakeDamage(damage)
				StunService:ApplyStun(character, math.max(0.1, 0))
			end
			if root and knockback and knockback > 0 then
				local dir = (root.Position - getRoot(attacker).Position).Unit
				root.AssemblyLinearVelocity = dir * knockback
			end
		end
	end
end

local function overlapParamsFor(attacker)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {attacker}
	return params
end

local function doMeleeBox(attacker, config)
	local root = getRoot(attacker)
	if not root then return end
	local cframe = root.CFrame * CFrame.new(0, 0, -config.range)
	local targets = Hitbox.Box(cframe, config.size, overlapParamsFor(attacker))
	return targets
end

local function doRadius(attacker, radius)
	local root = getRoot(attacker)
	if not root then return end
	local targets = Hitbox.Radius(root.Position, radius, overlapParamsFor(attacker))
	return targets
end

local function dashForward(character, speed, time)
	local root = getRoot(character)
	if not root then return end
	local dir = root.CFrame.LookVector
	root.AssemblyLinearVelocity = dir * speed
	task.delay(time, function()
		if root then
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end
	end)
end

local function bladeWave(attacker, config)
	local root = getRoot(attacker)
	if not root then return end

	local projectile = Instance.new("Part")
	projectile.Name = "BladeWave"
	projectile.Size = Vector3.new(1,1,1)
	projectile.Shape = Enum.PartType.Ball
	projectile.Anchored = true
	projectile.CanCollide = false
	projectile.Transparency = 0.5
	projectile.Material = Enum.Material.Neon
	projectile.Color = Color3.fromRGB(120, 170, 255)
	projectile.CFrame = root.CFrame * CFrame.new(0, 1, -3)
	projectile.Parent = workspace

	local traveled = 0
	local lastPos = projectile.Position
	local con
	con = RunService.Heartbeat:Connect(function(dt)
		if not projectile or not projectile.Parent then
			if con then con:Disconnect() end
			return
		end
		local step = config.projectileSpeed * dt
		traveled += step
		projectile.CFrame = projectile.CFrame * CFrame.new(0, 0, -step)

		local targets = Hitbox.Radius(projectile.Position, config.projectileRadius, overlapParamsFor(attacker))
		applyDamageAndKnockback(attacker, targets, config.damage, config.knockback)
		for _, ch in ipairs(targets) do
			StunService:ApplyStun(ch, config.stun)
		end

		if traveled >= config.projectileRange then
			projectile:Destroy()
			if con then con:Disconnect() end
		end
		lastPos = projectile.Position
	end)
end

function CombatService:ActivateSkill(player, skillId)
	if typeof(skillId) ~= "number" then return end
	local character = player.Character
	if not canUseSkill(player, character) then return end

	local weaponType = getWeaponType(player)
	local config = getSkillConfig(weaponType, skillId)
	if not config then return end

	if weaponType == "Sword" and player:GetAttribute("WeaponType") ~= "Sword" then
		return
	end

	if onCooldown(player, weaponType, skillId, config.cooldown) then return end
	setCooldown(player, weaponType, skillId)

	if config.dashSpeed then
		dashForward(character, config.dashSpeed, config.dashTime or 0.2)
	end

	local targets = {}
	if config.size then
		targets = doMeleeBox(character, config) or {}
	elseif config.radius then
		targets = doRadius(character, config.radius) or {}
	end

	if config.name == "BladeWave" then
		bladeWave(character, config)
	else
		applyDamageAndKnockback(character, targets, config.damage, config.knockback)
		for _, ch in ipairs(targets) do
			StunService:ApplyStun(ch, config.stun)
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	cooldowns[player] = nil
end)

return CombatService

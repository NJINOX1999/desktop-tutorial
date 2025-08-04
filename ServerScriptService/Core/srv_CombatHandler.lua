-- Handles weapon firing and damage application
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local remotes = ReplicatedStorage:WaitForChild('Remotes')
local RE_Fire = remotes:WaitForChild('RE_FireWeapon')
local RE_UpdateAmmo = remotes:WaitForChild('RE_UpdateAmmo')
local Config = require(ReplicatedStorage.Modules.mod_Config)

local function getWeaponInfo(player)
    local weapon = (player._data and player._data.Weapon) or 'Hands'
    return Config.Weapons[weapon]
end

RE_Fire.OnServerEvent:Connect(function(player, targetPos)
    if typeof(targetPos) ~= 'Vector3' then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild('HumanoidRootPart')
    if not root then return end
    local info = getWeaponInfo(player)
    if not info then return end
    if info.Ammo then
        player._data.Ammo = player._data.Ammo or 0
        if player._data.Ammo < info.Ammo then return end
        player._data.Ammo = player._data.Ammo - info.Ammo
        player:SetAttribute('Ammo', player._data.Ammo)
        RE_UpdateAmmo:FireClient(player, player._data.Ammo)
    end
    local direction = (targetPos - root.Position).Unit * info.Range
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(root.Position, direction, params)
    if result then
        local hit = result.Instance
        local hum = hit.Parent:FindFirstChildOfClass('Humanoid') or hit.Parent.Parent and hit.Parent.Parent:FindFirstChildOfClass('Humanoid')
        if hum and hum.Health > 0 then
            hum:TakeDamage(info.Damage)
        end
    end
end)

return {}

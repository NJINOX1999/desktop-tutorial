-- Validates build placement requests
local Workspace = game:GetService('Workspace')

local BuildValidator = {}

function BuildValidator:CanPlace(position)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Workspace.Map}
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    local result = Workspace:Raycast(position + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), raycastParams)
    if not result or result.Instance:IsA('Terrain') then
        return false
    end
    -- check for overlap with other objects or characters
    local region = Region3.new(position - Vector3.new(2,2,2), position + Vector3.new(2,2,2))
    local parts = Workspace:FindPartsInRegion3(region, nil, 20)
    for _, p in ipairs(parts) do
        if p:IsDescendantOf(Workspace.RuntimeObjects) then
            return false
        end
        if p.Parent and p.Parent:FindFirstChildOfClass('Humanoid') then
            return false
        end
    end
    local spawns = Workspace:FindFirstChild('SpawnPoints')
    if spawns then
        for _, p in ipairs(spawns:GetChildren()) do
            if (p.Position - position).Magnitude < 10 then
                return false
            end
        end
    end
    local crystal = Workspace:FindFirstChild('Crystal')
    if crystal and (crystal.Position - position).Magnitude < 10 then
        return false
    end
    return true
end

return BuildValidator

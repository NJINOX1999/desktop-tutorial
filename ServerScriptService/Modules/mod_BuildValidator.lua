-- Validates build placement requests
local Workspace = game:GetService('Workspace')

local BuildValidator = {}

function BuildValidator:CanPlace(position)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Workspace.Map}
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    local result = Workspace:Raycast(position + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), raycastParams)
    if not result then
        return false
    end
    return true
end

return BuildValidator

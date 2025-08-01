--[[
    Build Validator Stub
    Ensures new structures can be placed legally.
]]

local BuildValidator = {}

function BuildValidator.canPlace(player, position)
    local region = Region3.new(position - Vector3.new(2,2,2), position + Vector3.new(2,2,2))
    local parts = workspace:FindPartsInRegion3(region, nil, math.huge)
    if #parts > 0 then
        return false
    end
    local rayResult = workspace:Raycast(position, Vector3.new(0,-10,0))
    return rayResult ~= nil
end

return BuildValidator

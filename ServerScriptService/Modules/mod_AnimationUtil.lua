local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Animations = ReplicatedStorage:WaitForChild('Animations')

local util = {}

function util.load(id)
    local anim = Animations:FindFirstChild(id)
    if anim then
        return anim
    end
end

return util

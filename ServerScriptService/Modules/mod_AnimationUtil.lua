local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Animations = ReplicatedStorage:WaitForChild('Animations')

local util = {}

-- Retrieves an animation instance by name
function util.load(id)
    return Animations:FindFirstChild(id)
end

-- Plays an animation on a humanoid and returns the track
function util.play(id, humanoid)
    local anim = util.load(id)
    if anim and humanoid then
        local track = humanoid:LoadAnimation(anim)
        track:Play()
        return track
    end
end

-- Stops a given animation track if it is playing
function util.stop(track)
    if track and track.IsPlaying then
        track:Stop()
    end
end

return util

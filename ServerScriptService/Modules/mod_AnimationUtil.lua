local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')
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

-- Preloads a single animation by id to avoid hitches on first play
function util.preload(id)
    local anim = util.load(id)
    if anim then
        ContentProvider:PreloadAsync({anim})
        return true
    end
    return false
end

-- Preloads all animations in the folder
function util.preloadAll()
    local assets = {}
    for _, child in ipairs(Animations:GetChildren()) do
        table.insert(assets, child)
    end
    if #assets > 0 then
        ContentProvider:PreloadAsync(assets)
    end
end

return util

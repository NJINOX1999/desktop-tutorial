local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')

local folder = ReplicatedStorage.Assets:WaitForChild('Animations')
local AnimationManager = {}

local function getAnimator(obj)
    if obj:IsA('Model') then
        local hum = obj:FindFirstChildOfClass('Humanoid')
        if hum then
            return hum:FindFirstChildOfClass('Animator') or Instance.new('Animator', hum)
        else
            local controller = obj:FindFirstChildOfClass('AnimationController')
                or Instance.new('AnimationController', obj)
            return controller:FindFirstChildOfClass('Animator') or Instance.new('Animator', controller)
        end
    elseif obj:IsA('Humanoid') or obj:IsA('AnimationController') then
        return obj:FindFirstChildOfClass('Animator') or Instance.new('Animator', obj)
    end
    return nil
end

function AnimationManager.get(name)
    return folder:FindFirstChild(name)
end

function AnimationManager.loadTrack(obj, name)
    local anim = AnimationManager.get(name)
    local animator = anim and getAnimator(obj)
    if anim and animator then
        return animator:LoadAnimation(anim)
    end
    return nil
end

function AnimationManager.play(obj, name)
    local track = AnimationManager.loadTrack(obj, name)
    if track then
        track:Play()
    end
    return track
end

function AnimationManager.stop(track)
    if track and track.IsPlaying then
        track:Stop()
    end
end

function AnimationManager.preloadAll()
    local list = {}
    for _, child in ipairs(folder:GetChildren()) do
        table.insert(list, child)
    end
    if #list > 0 then
        ContentProvider:PreloadAsync(list)
    end
end

return AnimationManager


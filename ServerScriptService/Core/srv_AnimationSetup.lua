local ReplicatedStorage = game:GetService('ReplicatedStorage')
local folder = ReplicatedStorage:FindFirstChild('Animations')
if folder then
    for _, module in ipairs(folder:GetChildren()) do
        if module:IsA('ModuleScript') then
            local ok, anim = pcall(require, module)
            if ok and typeof(anim) == 'Instance' then
                anim.Name = module.Name
                anim.Parent = folder
            end
        end
    end
end
return {}

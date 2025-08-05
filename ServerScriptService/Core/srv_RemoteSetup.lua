local ReplicatedStorage = game:GetService('ReplicatedStorage')

local function load(folderName)
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    if not folder then
        folder = Instance.new('Folder')
        folder.Name = folderName
        folder.Parent = ReplicatedStorage
    end
    for _, module in ipairs(folder:GetChildren()) do
        if module:IsA('ModuleScript') then
            local ok, obj = pcall(require, module)
            if ok and typeof(obj) == 'Instance' then
                obj.Name = module.Name
                obj.Parent = folder
            end
        end
    end
end

load('RemoteEvents')
load('RemoteFunctions')

return {}


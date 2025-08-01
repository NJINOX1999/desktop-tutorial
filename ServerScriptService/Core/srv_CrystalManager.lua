--[[
    Manages the central crystal object.
    Handles health and provides reference for monsters.
]]

local CrystalManager = {
    CrystalHealth = 100
}

local runtimeFolder = workspace:FindFirstChild("RuntimeObjects") or Instance.new("Folder", workspace)
runtimeFolder.Name = "RuntimeObjects"

local crystal

function CrystalManager.spawn()
    crystal = Instance.new("Part")
    crystal.Name = "Crystal"
    crystal.Size = Vector3.new(3,5,3)
    crystal.Position = Vector3.new(0,2.5,0)
    crystal.Anchored = true
    crystal.Parent = runtimeFolder
end

function CrystalManager.getCrystal()
    return crystal
end

function CrystalManager.damage(amount)
    CrystalManager.CrystalHealth -= amount
    if CrystalManager.CrystalHealth <= 0 then
        print("Crystal destroyed!")
    end
end

return CrystalManager

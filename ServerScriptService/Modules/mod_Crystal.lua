-- Crystal health manager
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RE_UpdateCrystalHP = ReplicatedStorage.Remotes:WaitForChild('RE_UpdateCrystalHP')

local Crystal = {}
Crystal.Health = 1000
Crystal.Destroyed = false

function Crystal:Reset()
    self.Health = 1000
    self.Destroyed = false
    RE_UpdateCrystalHP:FireAllClients(self.Health)
end

function Crystal:Damage(amount)
    self.Health = math.max(self.Health - amount, 0)
    RE_UpdateCrystalHP:FireAllClients(self.Health)
    if self.Health <= 0 and not self.Destroyed then
        self.Destroyed = true
        _G.EventBus.Fire('CrystalDestroyed')
    end
end

function Crystal:ShouldGameOver()
    if not self.Destroyed then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild('Humanoid') and plr.Character.Humanoid.Health > 0 then
            return false
        end
    end
    return true
end

return Crystal

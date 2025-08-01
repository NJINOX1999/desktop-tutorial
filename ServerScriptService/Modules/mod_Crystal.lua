-- Crystal health manager
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Config = require(ReplicatedStorage.Modules.mod_Config)

local Crystal = {}
Crystal.Health = 1000
Crystal.evacTimer = 0

function Crystal:Reset()
    self.Health = 1000
    self.evacTimer = 0
end

function Crystal:Damage(amount)
    self.Health = math.max(self.Health - amount, 0)
    if self.Health <= 0 and self.evacTimer == 0 then
        self.evacTimer = os.clock()
        _G.EventBus.Fire('CrystalDestroyed')
    end
end

function Crystal:ShouldGameOver()
    if self.evacTimer > 0 then
        return os.clock() - self.evacTimer > Config.CrystalEvacTime
    end
    return false
end

return Crystal

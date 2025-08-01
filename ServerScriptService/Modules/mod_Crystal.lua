-- Crystal health manager
local Crystal = {}
Crystal.Health = 1000

function Crystal:Damage(amount)
    self.Health = math.max(self.Health - amount, 0)
end

return Crystal

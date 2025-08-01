--[[
    Drop Table Stub
    Defines loot probabilities for monsters.
]]

local DropTable = {}

local tables = {
    Default = {
        {item = "Coin", chance = 0.8},
        {item = "CrystalShard", chance = 0.05},
    }
}

function DropTable.getDrops(monsterType)
    local result = {}
    local list = tables[monsterType] or tables.Default
    for _,entry in ipairs(list) do
        if math.random() < entry.chance then
            table.insert(result, {item = entry.item})
        end
    end
    return result
end

return DropTable

-- Handles enemy loot probabilities
local DropTable = {}

DropTable.tables = {
    Default = {
        {itemId = 'Coin', chance = 0.8, qty = 1},
        {itemId = 'CrystalShard', chance = 0.05, qty = 1}
    },
    Tank = {
        {itemId = 'Coin', chance = 1, qty = 3},
        {itemId = 'CrystalShard', chance = 0.1, qty = 1}
    },
    Speedy = {
        {itemId = 'Coin', chance = 0.9, qty = 2},
        {itemId = 'CrystalShard', chance = 0.03, qty = 1}
    }
}

function DropTable:getDrops(class)
    local tbl = self.tables[class]
    if not tbl then return {} end
    local drops = {}
    for _, entry in ipairs(tbl) do
        if math.random() < entry.chance then
            table.insert(drops, {itemId = entry.itemId, qty = entry.qty or 1})
        end
    end
    return drops
end

return DropTable

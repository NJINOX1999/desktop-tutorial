-- Handles enemy loot probabilities
local DropTable = {}

DropTable.tables = {
    Zombie = {
        {itemId = 'Knochen', chance = 0.5},
        {itemId = 'Kristallsplitter', chance = 0.05}
    }
}

function DropTable:GetLoot(class)
    local tbl = self.tables[class]
    if not tbl then return nil end
    for _, entry in ipairs(tbl) do
        if math.random() < entry.chance then
            return {itemId = entry.itemId, qty = 1}
        end
    end
    return nil
end

return DropTable

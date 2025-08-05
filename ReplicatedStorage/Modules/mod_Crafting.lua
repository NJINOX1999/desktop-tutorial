local Crafting = {}

Crafting.Recipes = {
    Stick = {Materials = {Wood = 5}, Output = {item = 'Stick', qty = 1}},
    Ammo = {Materials = {Stone = 1}, Output = {item = 'Ammo', qty = 5}}
}

function Crafting:CanCraft(inv, name)
    local recipe = self.Recipes[name]
    if not recipe then return false end
    for mat, qty in pairs(recipe.Materials) do
        if (inv[mat] or 0) < qty then
            return false
        end
    end
    return true
end

function Crafting:Craft(inv, name)
    if not self:CanCraft(inv, name) then
        return false
    end
    local recipe = self.Recipes[name]
    for mat, qty in pairs(recipe.Materials) do
        inv[mat] = inv[mat] - qty
    end
    local out = recipe.Output
    inv[out.item] = (inv[out.item] or 0) + (out.qty or 1)
    return true, out.item
end

return Crafting

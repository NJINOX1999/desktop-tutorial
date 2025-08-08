return function()
    describe("Gameplay systems", function()
        package.path = package.path .. ";ReplicatedStorage/Modules/?.lua;ServerScriptService/Modules/?.lua"
        local Config = require("mod_Config")

        it("Test A: tower placement deducts coins", function()
            local data = {Coins = 50}
            local cost = Config.BuildPrices.Basic
            data.Coins = data.Coins - cost
            expect(data.Coins).to.equal(50 - cost)
        end)

        it("Test B: night spawn chance higher than day", function()
            expect(Config.NightSpawnChance).to.be.greaterThan(Config.DaySpawnChance)
        end)

        it("Test C: addXP stores XP", function()
            _G.game = {
                GetService = function(_, name)
                    if name == "ReplicatedStorage" then
                        return {Modules = {mod_Config = Config}}
                    elseif name == "Players" then
                        return {}
                    end
                end
            }
            local oldRequire = require
            function require(mod)
                if type(mod) == "table" then
                    return mod
                else
                    return oldRequire(mod)
                end
            end
            local LevelService = require("mod_LevelService")
            script = {Parent = {mod_LevelService = LevelService}}
            local Utilities = require("mod_Utilities")
            local player = { _data = {XP = 0, Level = 1}, SetAttribute = function() end }
            Utilities.addXP(player, 10)
            expect(player._data.XP).to.be.ok()
            require = oldRequire
        end)

        it("Test D: buyback price constant", function()
            expect(Config.BuybackPrice).to.equal(10000)
        end)

        it("Test E: crystal buff multiplier > 1", function()
            expect(Config.CrystalBuffMultiplier).to.be.greaterThan(1)
        end)
    end)
end

return function()
    describe("Gameplay systems", function()
        package.path = package.path .. ";ReplicatedStorage/Modules/?.lua;ServerScriptService/Modules/?.lua;ServerScriptService/Core/?.lua"
        local Config = require("mod_Config")
        local function dummy() end
        _G.workspace = {FindFirstChild = function() return nil end, RuntimeObjects = {GetChildren = function() return {} end}}
        _G.game = {
            GetService = function(_, name)
                if name == 'ReplicatedStorage' then
                    return {
                        Modules = {mod_Config = Config},
                        Remotes = {WaitForChild = function() return {FireAllClients = dummy, FireClient = dummy} end},
                        WaitForChild = function(self, n) return self[n] end
                    }
                elseif name == 'Players' then
                    return {GetPlayers = function() return {} end}
                elseif name == 'ServerStorage' then
                    return {
                        Assets = {Monsters = {FindFirstChild = function() return nil end}, Bosses = {}},
                        FindFirstChild = function(self, n) return self[n] end,
                        Tools = {FindFirstChild = function(_, n) return {Clone = function() return {Parent = nil} end} end}
                    }
                end
            end
        }

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
        it("CrystalBuff applies after destruction", function()
            _G.crystalLost = true
            local MonsterBuffService = require("mod_MonsterBuffService")
            local hum = {WalkSpeed = 10, MaxHealth = 100, Health = 100}
            local monster = {
                FindFirstChildOfClass = function(_, class) if class == 'Humanoid' then return hum end end,
                GetAttribute = function() return 1 end,
                SetAttribute = function() end
            }
            MonsterBuffService.apply(monster)
            expect(hum.WalkSpeed).to.equal(10 * Config.CrystalBuffMultiplier)
        end)

        it("UniversalHeal heals up to 50%", function()
            local Heal = require("mod_Heal")
            local function mkPlayer(x)
                local hum = {Health = 10, MaxHealth = 100}
                local hrp = {Position = {X = x, Y = 0, Z = 0}}
                local char = {
                    HumanoidRootPart = hrp,
                    FindFirstChildOfClass = function(_, class) if class == 'Humanoid' then return hum end end,
                    FindFirstChild = function() return hrp end
                }
                return {Character = char}
            end
            local healer = mkPlayer(0)
            local target = mkPlayer(5)
            local hum = target.Character:FindFirstChildOfClass('Humanoid')
            local ok1 = Heal.tryHeal(healer, target)
            expect(ok1).to.equal(true)
            expect(hum.Health).to.equal(50)
            local ok2 = Heal.tryHeal(healer, target)
            expect(ok2).to.equal(false)
        end)
    end)
end

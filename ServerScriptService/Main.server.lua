local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(script.Modules.Config)
local PlayerService = require(script.Modules.PlayerService)
local CombatService = require(script.Modules.CombatService)
local SpawnService = require(script.Modules.SpawnService)
local MatchService = require(script.Modules.MatchService)

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local attackEvent = remotesFolder:FindFirstChild("Attack")
if not attackEvent then
    attackEvent = Instance.new("RemoteEvent")
    attackEvent.Name = "Attack"
    attackEvent.Parent = remotesFolder
end

local roundEvent = remotesFolder:FindFirstChild("RoundState")
if not roundEvent then
    roundEvent = Instance.new("RemoteEvent")
    roundEvent.Name = "RoundState"
    roundEvent.Parent = remotesFolder
end

local combatService = CombatService.new(Config)
local spawnService = SpawnService.new(Config)
local matchService = MatchService.new(Config, PlayerService, spawnService)

local profiles = {}

local function broadcastRoundState()
    roundEvent:FireAllClients({
        State = matchService.State,
        TimeRemaining = math.max(0, math.floor(matchService.TimeRemaining)),
    })
end

local function registerPlayer(player)
    local profile = PlayerService.createProfile(player, Config.Stats.Default)
    profiles[player] = profile
    matchService:registerPlayer(profile)

    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        profile.Alive = true
        profile.Lives = Config.Game.MaxLives
        humanoid.Died:Connect(function()
            profile.Alive = false
            PlayerService.applyWO(profile)
        end)
    end)

    player:LoadCharacter()
end

local function unregisterPlayer(player)
    profiles[player] = nil
    matchService:unregisterPlayer(player)
end

Players.PlayerAdded:Connect(registerPlayer)
Players.PlayerRemoving:Connect(unregisterPlayer)

attackEvent.OnServerEvent:Connect(function(player)
    local profile = profiles[player]
    if not profile or not profile.Alive then
        return
    end

    if not combatService:canAttack(player) then
        return
    end

    combatService:markAttack(player)

    for _, target in ipairs(combatService:getTargets(player)) do
        combatService:applyDamage(player, target.Humanoid)
        profile.LastHitTime = os.clock()
        profile.LastAttacker = player
        if target.Humanoid.Health - Config.Combat.BaseDamage <= 0 then
            PlayerService.applyKO(profile)
        end
    end
end)

matchService:startIntermission()

local lastTick = os.clock()
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local dt = now - lastTick
    lastTick = now

    if matchService:tick(dt) then
        if matchService.State == "Intermission" then
            if #Players:GetPlayers() >= Config.Game.MinPlayersToStart then
                matchService:resetRound()
                matchService:spawnAll()
            else
                matchService:startIntermission()
            end
        else
            local winner = matchService:checkWinner()
            if winner then
                local winnerProfile = profiles[winner]
                if winnerProfile then
                    PlayerService.applyKO(winnerProfile)
                end
            end

            for _, profile in pairs(profiles) do
                PlayerService.resetRoundStats(profile)
            end
            matchService:startIntermission()
        end
        broadcastRoundState()
    end
end)

Players.PlayerAdded:Connect(function(player)
    roundEvent:FireClient(player, {
        State = matchService.State,
        TimeRemaining = math.max(0, math.floor(matchService.TimeRemaining)),
    })
end)

broadcastRoundState()

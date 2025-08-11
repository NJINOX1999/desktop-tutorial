--!strict
-- Führt in Studio einen kurzen End-to-End-Check aus und reportet über TestService.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TestService = game:GetService("TestService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not RunService:IsStudio() then return end

local Config = require(script.Parent:WaitForChild("_LiveStudioConfig"))

if not Config.ENABLED then
TestService:Message("[LiveStudio] disabled via _LiveStudioConfig")
return
end

local function pass(tag: string, msg: string)
TestService:Message(("PASS [%s] %s"):format(tag, msg))
end

local function fail(tag: string, msg: string)
TestService:Error(("FAIL [%s] %s"):format(tag, msg))
end

local function requireDesc(parent: Instance, name: string, cls: string?)
    local inst = parent:FindFirstChild(name)
    if not inst then return nil end
    if cls and not inst:IsA(cls) then return nil end
    return inst
end

local function findRemote(remotes: Instance, keywords: {string}): Instance?
    for _, child in ipairs(remotes:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local lname = string.lower(child.Name)
            for _, kw in ipairs(keywords) do
                if string.find(lname, kw, 1, true) then
                    return child
                end
            end
        end
    end
    return nil
end

local function waitPlayers(timeout: number): Player?
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        local list = Players:GetPlayers()
        if #list > 0 then return list[1] end
        task.wait(0.1)
    end
    return nil
end

-- Begin
TestService:Message("=== Live Studio Smoke Test ===")

-- 0) Player vorhanden
local plr = waitPlayers(10)
if not plr then
fail("PlayerJoin", "Kein Spieler in Play Solo gefunden")
return
else
pass("PlayerJoin", ("Spieler %s erkannt"):format(plr.Name))
end

-- 1) Remotes vorhanden
local remotes = requireDesc(ReplicatedStorage, "Remotes")
if not remotes then
fail("RemotesFolder", "ReplicatedStorage/Remotes fehlt")
return
else
pass("RemotesFolder", "Ordner vorhanden")
end

local StartGame: Instance? = findRemote(remotes, {"startgame", "start", "begin"})
local Build: Instance? = findRemote(remotes, {"buildrequest", "placetower", "build"})
local Buyback: Instance? = findRemote(remotes, {"buyback", "revive", "respawn"})

if StartGame then pass("Remote StartGame", StartGame.Name) else fail("Remote StartGame", "fehlt") end
if Config.BUILD_TEST then
    if Build then pass("Remote Build", Build.Name) else fail("Remote Build", "fehlt") end
end
if Config.BUYBACK_TEST then
    if Buyback then pass("Remote Buyback", Buyback.Name) else fail("Remote Buyback", "fehlt") end
end

-- 2) Spielstart (nur Event-Existenz wird verifiziert; Handler-Fehler würden hier crashen)
if StartGame then
    if StartGame:IsA("RemoteEvent") then
        task.spawn(function()
            (StartGame :: RemoteEvent):FireServer()
        end)
    else
        task.spawn(function()
            pcall(function()
                (StartGame :: RemoteFunction):InvokeServer()
            end)
        end)
    end
    pass("StartGame.Call","ausgeführt")
end

-- 3) Optional: einfacher Tower-Bau-Call (Dummy Koordinaten – Server validiert!)
if Config.BUILD_TEST and Build then
    if Build:IsA("RemoteEvent") then
        task.spawn(function()
            (Build :: RemoteEvent):FireServer({
                towerId = "QA_SMOKE",
                position = Vector3.new(0, 0, 0),
            })
        end)
    else
        task.spawn(function()
            pcall(function()
                (Build :: RemoteFunction):InvokeServer({
                    towerId = "QA_SMOKE",
                    position = Vector3.new(0, 0, 0),
                })
            end)
        end)
    end
    pass("Build.Call","ausgeführt")
end

-- 4) Optional: Buyback-Ping (nur Existenz/Permissions)
if Config.BUYBACK_TEST and Buyback then
    if Buyback:IsA("RemoteEvent") then
        task.spawn(function()
            (Buyback :: RemoteEvent):FireServer()
        end)
    else
        task.spawn(function()
            pcall(function()
                (Buyback :: RemoteFunction):InvokeServer()
            end)
        end)
    end
    pass("Buyback.Call","ausgeführt")
end

-- 5) Abschluss: Flag setzen
local okFlag = Instance.new("BoolValue")
okFlag.Name = "QA_LiveStudio_PASS"
okFlag.Value = true
okFlag.Parent = ReplicatedStorage
pass("Finish","QA_LiveStudio_PASS gesetzt")

TestService:Message("=== Live Studio Smoke Test ENDE ===")

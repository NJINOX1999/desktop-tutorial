local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = Players.LocalPlayer

local Locale = require(ReplicatedStorage.Modules.mod_Locale).en
local RemoteEvents = ReplicatedStorage:WaitForChild('RemoteEvents')
local RE_UpdateCoins = RemoteEvents:WaitForChild('RE_UpdateCoins')
local RE_UpdateCrystalHP = RemoteEvents:WaitForChild('RE_UpdateCrystalHP')
local RE_UpdateAmmo = RemoteEvents:WaitForChild('RE_UpdateAmmo')
local RE_UpdateWave = RemoteEvents:WaitForChild('RE_UpdateWave')
local RE_TimeOfDayChanged = RemoteEvents:WaitForChild('RE_TimeOfDayChanged')

local gui = script.Parent
local coinLabel = gui:WaitForChild('CoinLabel')
local hpLabel = gui:WaitForChild('HPLabel')
local crystalLabel = gui:WaitForChild('CrystalLabel')
local waveLabel = gui:WaitForChild('WaveLabel')
local timeLabel = gui:WaitForChild('TimeLabel')
local ammoLabel = gui:WaitForChild('AmmoLabel')
local xpLabel = gui:WaitForChild('XPLabel')
local levelLabel = gui:WaitForChild('LevelLabel')

RE_UpdateCoins.OnClientEvent:Connect(function(value)
    coinLabel.Text = string.format('%s: %d', Locale.coins, value)
end)

RE_UpdateCrystalHP.OnClientEvent:Connect(function(value)
    crystalLabel.Text = string.format('%s: %d', Locale.crystal, value)
end)

RE_UpdateAmmo.OnClientEvent:Connect(function(value)
    ammoLabel.Text = string.format('%s: %d', Locale.ammo, value)
end)

RE_UpdateWave.OnClientEvent:Connect(function(wave)
    waveLabel.Text = string.format('%s %d', Locale.wave, wave)
end)

RE_TimeOfDayChanged.OnClientEvent:Connect(function(_, isNight)
    timeLabel.Text = isNight and Locale.night or Locale.day
end)

local function bindHumanoid(hum)
    if not hum then return end
    hpLabel.Text = string.format('%s: %d', Locale.hp, hum.Health)
    hum.HealthChanged:Connect(function(v)
        hpLabel.Text = string.format('%s: %d', Locale.hp, v)
    end)
end

player.CharacterAdded:Connect(function(char)
    bindHumanoid(char:WaitForChild('Humanoid'))
end)
if player.Character then
    bindHumanoid(player.Character:FindFirstChild('Humanoid'))
end

local function updateXP()
    xpLabel.Text = string.format('%s: %d', Locale.xp, player:GetAttribute('XP') or 0)
    levelLabel.Text = string.format('%s: %d', Locale.level, player:GetAttribute('Level') or 1)
end
player:GetAttributeChangedSignal('XP'):Connect(updateXP)
player:GetAttributeChangedSignal('Level'):Connect(updateXP)
updateXP()

local Players = game:GetService('Players')
Players.CharacterAutoLoads = false
Players.PlayerAdded:Connect(function(player)
    player:LoadCharacter()
end)

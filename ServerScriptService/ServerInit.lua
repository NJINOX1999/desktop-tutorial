local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")
require(Remotes.RE_BuildRequest)
require(Remotes.RE_DamageIndicator)
require(Remotes.RF_BuyItem)

local CrystalManager = require(script.Core.srv_CrystalManager)
CrystalManager.spawn()

require(script.Core.srv_BuildHandler)
local GameLoop = require(script.Core.srv_GameLoop)
GameLoop:start()

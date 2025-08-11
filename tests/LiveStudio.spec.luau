--!strict
local RunService = (game.GetService and game:GetService("RunService")) or {IsStudio = function() return false end}
return function()
    describe("LiveStudio Smoke Test (Studio-only)", function()
        it("skips outside Studio", function()
            if not RunService:IsStudio() then
                expect(true).to.equal(true)
                return
            end
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local flag = ReplicatedStorage:FindFirstChild("QA_LiveStudio_PASS")
            expect(flag ~= nil).to.equal(true)
        end)
    end)
end

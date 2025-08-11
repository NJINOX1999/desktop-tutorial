Live Studio Notes

The Studio smoke test runs automatically when Play Solo is started in Roblox Studio.
It verifies:
1. At least one Player joins.
2. ReplicatedStorage/Remotes exists and key remotes (StartGame, BuildRequest, Buyback) are present.
3. Each found remote receives a FireServer call for basic connectivity.
4. On success, ReplicatedStorage.QA_LiveStudio_PASS is created with value true.
Results appear in the Output window via TestService:Message/Error.

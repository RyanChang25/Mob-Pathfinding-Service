local SS_Service = game:GetService("ServerScriptService")
local MobService = require(SS_Service.ServerMain.MobService)
---------------------------------------------------------------

for i = 0,15,1 do -->>: As an example, I spawn 15 mobs to showcase the functionality
	local NewMob = MobService.new("Amber Golem", 2, 50, 6, 12, true, workspace.Spawners:FindFirstChild("Spawner"..tostring(math.random(1,4))).CFrame)
	-->>: Create Mob Object. (Name, Level, HP, Radius, Height, canJump, spawnCFrame) 
	-->>: Spawn CFrame is randomized between 4 parts in the workspace. These act as the spawners for the mobs.
	NewMob:SetProperties() -->>: Set Object Properties
	NewMob:SetAnimations() -->>: Set Object Animations
end

MobService.PathfindServiceLoop() -->>: Call to initilize the pathfind loop (Only once)

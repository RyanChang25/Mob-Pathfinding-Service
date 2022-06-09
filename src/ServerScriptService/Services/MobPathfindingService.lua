local PathfindingService = game:GetService('PathfindingService')
local RunService = game:GetService('RunService')
local CollectionService = game:GetService("CollectionService")
local MobService = {}
local MobsTable = {}
MobService.__index = MobService
-------------------------------------

local function findTarget(rootPart, dist) -->>: Simple search function to find players
	for i,v in pairs(workspace:GetChildren())do
		local humanoid = v:FindFirstChild("Humanoid")
		local head = v:FindFirstChild("Head")
		if humanoid and head and not CollectionService:HasTag(head.Parent, "Mob") then
			if (head.Position - rootPart.Position).magnitude < dist and humanoid.Health > 0 then
				return head
			end
		end
	end
end

function MobService.new(name, level, health, radius, height, canJump, cframe)

	local newMob = {}
	newMob._BaseHealth = health or 100
	newMob._EnemyType = name or "Dummy"
	newMob._Model = game.ReplicatedStorage[name]:Clone()
	newMob._Model.Parent = workspace.Enemies
	newMob._Distance = 70
	newMob._WalkSpeed = 8
	newMob._Radius = radius
	newMob._Height = height
	newMob._spawnCFrame = cframe
	newMob._CanJump = canJump
	newMob._Level = level
	
	table.insert(MobsTable, newMob) -->>: Insert into MobsTable for the pathfind loop function
	
	setmetatable(newMob, MobService)
	
	return newMob
end

function MobService:SetProperties() -->>: Sets important mob properties that aren't done in the .new function
	self._Model.Humanoid.Health = self._BaseHealth
	self._Model.Humanoid.WalkSpeed = self._WalkSpeed
	self._Model.Head.MobName.TextLabel.Text = "Lvl "..self._Level..". "..self._EnemyType
	self._Model:SetPrimaryPartCFrame(self._spawnCFrame)
end

function MobService:SetAnimations() -->>: Sets animations for the mob. More optimized approach as opposed to the default Roblox Animation script.
	
	local walking = self._Model.Walking.Value
	
	-->>: I placed the animations under the module service
	local IdleAnim = self._Model.Humanoid.Animator:LoadAnimation(script.IdleAnim)
	local runAnim = self._Model.Humanoid.Animator:LoadAnimation(script.RunAnim)
	
	IdleAnim:Play()
	
	self._Model.Humanoid.Running:Connect(function(speed)
		if speed > (1) then
			if not walking then
				walking = true
				runAnim:Play()
			end
		elseif speed == 0 then
			if walking then
				walking = false
				local ActiveTracks = self._Model.Humanoid.Animator:GetPlayingAnimationTracks()
				for _,v in pairs(ActiveTracks) do 
					if v.Name == "RunAnim" then
						v:Stop()
						IdleAnim:Play()
					end
				end
			end
		end
	end)
	
end

function MobService.PathfindServiceLoop()
	
	RunService.Heartbeat:Connect(function()	
		if #MobsTable ~= 0 then -->>: Makes sure there are existing mobs in the table
			local MobLoop = coroutine.wrap(function() -->>: Creates a thread to calculate the pathfind for the mob
				for i,v in pairs (MobsTable) do
					local head = findTarget(v._Model.HumanoidRootPart, v._Distance) -->>: Head returns the nearest player
					if head then
						local Path = PathfindingService:CreatePath({ -->>: Creates path and sets data according to the mob object
							AgentRadius = v._Radius,
							AgentHeight = v._Height,
							AgentCanJump = v._CanJump
						})
						Path:ComputeAsync(v._Model.HumanoidRootPart.Position, head.Position)
						if Path.Status == Enum.PathStatus.Success then -->>: Simple pathfind function. The mob will walk to the nearest player and jump if needed.
							local Nodes = Path:GetWaypoints()
							for i,nodeParts in pairs (Nodes) do
								if nodeParts.Action == Enum.PathWaypointAction.Jump then
									v._Model.Humanoid.Jump = true
								end
								v._Model.Humanoid:MoveTo(nodeParts.Position)
							end
						end
					end
				end
			end)()
		else
			print("Waiting for MobsTable to have objects...")
			repeat wait(1) until #MobsTable ~= 0 -->>: Will repeat a wait(1) in case the table is empty so it doesn't run heavily in the background.
		end
	end)
end

return MobService
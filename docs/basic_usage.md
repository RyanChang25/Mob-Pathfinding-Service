## Basic Usage

```
--(Remember to name your mob according! And place under Replicated Storage. In this example mine is called "Amber Golem".)

local NewMob = MobService.new("Amber Golem", 2, 50, 6, 12, true, workspace.Spawners:FindFirstChild("Spawner"..tostring(math.random(1,4))).CFrame)
-->>: Create Mob Object. (Name, Level, HP, Radius, Height, canJump, spawnCFrame)
-->>: Spawn CFrame is randomized between 4 parts in the workspace. These act as the spawners for the mobs.
NewMob:SetProperties() -->>: Set Object Properties
NewMob:SetAnimations() -->>: Set Object Animations (If any)

MobService.PathfindServiceLoop() -->>: Call to initilize the pathfind loop (Should only be called once)
```

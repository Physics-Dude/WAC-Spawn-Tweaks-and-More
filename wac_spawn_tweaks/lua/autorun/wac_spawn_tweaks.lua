--[[
-- Universal FIX for the random WAC spawn bug where some WAC entities spawn underground and/or explode.
-- Additional cvar tweaks include: Engine performance, auto maintenance on spawn, spawn frozen, aerodynamics modifiers.
]]--
if SERVER then
	CreateConVar("WACspawnTweaks_Spawn_Frozen", "0", {FCVAR_ARCHIVE},
	"Would you like your WAC spawned frozen?")
	
	CreateConVar("WACspawnTweaks_Regen_Seconds", "10", {FCVAR_ARCHIVE},
	"How many seconds should a WAC receive repair/maintenance for when first spawned", 1)
	
	CreateConVar("WACspawnTweaks_EnginePerf_Multiplier", "1.5", {FCVAR_ARCHIVE},
	"Modify engine performance for newly spawned WAC. 1=Original, 1.5=Good, 3=Arcade, 10=Kerbal", 1, 10)
	
	CreateConVar("WACspawnTweaks_AngleDrag_Multiplier", "2", {FCVAR_ARCHIVE},
	"Modify a newly spawned WAC's angular drag. 1=Original, 2=More realistic, 10=Cruse ship", 0, 10)
	
	--advanced cvars
	CreateConVar("WACspawnTweaks_Rail_Multiplier", "1", {FCVAR_ARCHIVE},
	" Modify how stable newly spawned WAC is on its path (aka Rail). Higher means less drift. 1=Original, 2=Casual, 100=Flying in honey", 1, 100)
	
	CreateConVar("WACspawnTweaks_PointForward_Ratio", "1", {FCVAR_ARCHIVE},
	"Modify a newly spawned WAC's desire to point forward while moving. 0.5=Top Gun Maverick, 1=Original", 0, 1)
	
	CreateConVar("WACspawnTweaks_Self-Lift_Ratio", "1", {FCVAR_ARCHIVE},
	"Modify a newly spawned WAC's desire to lift while moving. 0.5=Top Gun Maverick, 1=Original", 0, 1)
	
		
	hook.Add( "PlayerSpawnedSENT", "WACspawnTweaks", function(ply, ent)
	
		--only apply to WAC aircraft
		if not ent.isWacAircraft then return end
		
		--get the height of the thing and create an offset
		local minBounds, maxBounds = ent:GetCollisionBounds()
		local height = maxBounds.z - minBounds.z
		local toPos = ent:GetPos() + Vector( 0, 0, height/1.25)
		
		--freeze body disable collisions 
		local physv = ent:GetPhysicsObject()
		physv:EnableMotion(false)
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		
		local function WACReadyNow()
		
			--return body to normal
			if IsValid(ent) then 
				if GetConVar("WACspawnTweaks_Spawn_Frozen"):GetInt() == 0 then
					physv:EnableMotion(true)
				end
				ent:SetCollisionGroup(COLLISION_GROUP_NONE)
			end

			--give a little repair pat pats
			local maintenanceTime = GetConVar("WACspawnTweaks_Regen_Seconds"):GetInt()
			local maintenanceTimer = timer.Create("WACspawnTweaks_MaintenanceTimer", 1, maintenanceTime, function()
				if IsValid(ent) then
					ent:maintenance()
				else
					timer.Remove("WACspawnTweaks_MaintenanceTimer")
				end
			end)
			
			--apply tweaks
			timer.Simple(2, function()
				if IsValid(ent) then
				
					--values we will edit
					local engineThrust = ent.Agility.Thrust
					local engineForce = ent.EngineForce					
					
					--get configs
					local engineMultiplier = GetConVar("WACspawnTweaks_EnginePerf_Multiplier"):GetFloat()
					local angleDragStrength = GetConVar("WACspawnTweaks_AngleDrag_Multiplier"):GetFloat()
					local railMultiplier = GetConVar("WACspawnTweaks_Rail_Multiplier"):GetFloat() --advanced
					local rotationStrength = GetConVar("WACspawnTweaks_PointForward_Ratio"):GetFloat() --advanced
					local liftStrength = GetConVar("WACspawnTweaks_Self-Lift_Ratio"):GetFloat() --advanced
					
					--apply engine tweaks
					if engineThrust <= 1 then
						--its probably a heli
						ent.EngineForce = engineForce * engineMultiplier
					else
						--its probably a plane
						ent.Agility.Thrust = engineThrust * engineMultiplier
					end
					
					--apply aerodynamic tweaks
					ent.Aerodynamics.AngleDrag = ent.Aerodynamics.AngleDrag * angleDragStrength 
					
					--advanced aerodynamic tweaks
					ent.Aerodynamics.Rail = ent.Aerodynamics.Rail * railMultiplier
					ent.Aerodynamics.aeroRailRotor = ent.Aerodynamics.RailRotor * railMultiplier 
					
					ent.Aerodynamics.Rotation.Front = ent.Aerodynamics.Rotation.Front * rotationStrength
					ent.Aerodynamics.Rotation.Right = ent.Aerodynamics.Rotation.Right * rotationStrength --yaw strength
					ent.Aerodynamics.Rotation.Top = ent.Aerodynamics.Rotation.Top * rotationStrength
					
					ent.Aerodynamics.Lift.Front = ent.Aerodynamics.Lift.Front * liftStrength
					ent.Aerodynamics.Lift.Right = ent.Aerodynamics.Lift.Right * liftStrength
					ent.Aerodynamics.Lift.Top = ent.Aerodynamics.Lift.Top * liftStrength
					
				end
			end)
		end

		-- Check if any part of the PhysicsObject is intersecting the ground
		local trace = util.TraceLine({
			start = ent:GetPos(toPos) + maxBounds,
			endpos = ent:GetPos(toPos) + minBounds,
			filter = ent, 
			mask = MASK_SOLID 
		})

		if trace.Hit then
			-- The trace hit something, set the ent really high
			--local hitPos = trace.HitPos
			ent:SetPos(toPos)
			
			local lowerMe = timer.Create("WACspawnTweaks_lowerMe", 0, 20, function()
				if IsValid(ent) then
				--lower ent a little bit
					ent:SetPos(ent:GetPos() - Vector( 0, 0, 20))
					--test if ent intersects ground
					local microTrace = util.TraceLine({
						start = ent:GetPos(toPos)+maxBounds,
						endpos = ent:GetPos(toPos)+minBounds,
						filter = ent,
						mask = MASK_SOLID 
					})
					--if trace hits, move ent up a little and enable motion
					if microTrace.Hit then
						ent:SetPos(ent:GetPos() + Vector( 0, 0, 20))
						timer.Remove( "WACspawnTweaks_lowerMe" )
						timer.Simple(0.25, WACReadyNow)
					end
				else 
					timer.Remove( "WACspawnTweaks_lowerMe" )
				end
			end)
		else
			-- The trace did not hit anything
			timer.Simple(0.25, WACReadyNow)
		end
	end )
end


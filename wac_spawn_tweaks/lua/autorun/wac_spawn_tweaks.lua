--[[
-- Universal FIX for the random WAC spawn bug where some WAC entities spawn underground and/or explode.
-- Aditional cvar tweaks include: Engine performance cvar modifier, auto maintenance on spawn, spawn frozen.
]]--
if SERVER then
	CreateConVar("WACspawnTweaks_Spawn_Frozen", "0", {FCVAR_ARCHIVE},
	"Would you like your WAC spawned frozen?")
	
	CreateConVar("WACspawnTweaks_Regen_Seconds", "10", {FCVAR_ARCHIVE},
	"How many seconds should a wac recieve repair/maintenance for when first spawned", 1, 999)
	
	CreateConVar("WACspawnTweaks_EnginePerf_Multiplier", "2", {FCVAR_ARCHIVE},
	"Modify engine performance for newly spawned WAC. 1=Original, [2]=Good, 5=Arcade, 10=Pain", 1, 10)
	
	hook.Add( "PlayerSpawnedSENT", "WACspawnTweaks", function(ply, ent)
	
		--only apply if class string starts with 'wac_' and is an aircraft
		if string.sub(ent:GetClass(), 1, 4) ~= "wac_" then return end
		if ent.ClassName == "wac_aircraft_maintenance" then return end
		if ent.ClassName == "wac_seat_connector" then return end
		
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
					local engineThrust = ent.Agility.Thrust
					local engineForce = ent.EngineForce
					local multiplier = GetConVar("WACspawnTweaks_EnginePerf_Multiplier"):GetInt()
					
					if engineThrust <= 1 then
						--its probably a heli
						ent.EngineForce = engineForce * multiplier
						--print("new engineForce:", engineForce * multiplier)
					else
						--its probably a plane
						ent.Agility.Thrust = engineThrust * multiplier
						--print("new engineThrust:", engineThrust * multiplier)
					end
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


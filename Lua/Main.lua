-- A cooldown of tranformation.
local TF_TIMER_MAX = 20*TICRATE
-- Maximum fuel for jet mode
local FUEL_CAP = 500*TICRATE
-- Cool down of the missle show
local MISSILE_TIMER_MAX = 50*TICRATE

-- Maximum distance between missile and enemy at which lock-on will begin 
local MISSLE_LOCK_DISTANCE = 100*FRACUNIT

local land_sound_list = {2, sfx_sland1, sfx_sland2, sfx_sland3}
local jump_sound_list = {2, sfx_sjump1, sfx_sjump2, sfx_sjump3}

--Checks whether the mobject is valid and (optionally) has the correct skin 
rawset(_G, "Valid", function(mo, skin)
	return mo ~= nil and mo.valid == true and mo.skin == skin and mo.state ~= S_NULL --and mo.state ~= states[mo.state].deathstate
end)

--Switch to the Starscream skin
local function StartUp(player)
	if(Valid(player.mo)) then
		return false
	end
	player.mo.allow_tf_botjet = true
	-- Count down to zezo
	player.mo.tf_countdown = TF_TIMER_MAX
	player.mo.fuel_countdown = FUEL_CAP
	player.mo.missile_countdown = 0*TICRATE
end

--Switch off the Starscream skin
local function CleanUp(player)
	if(not Valid(player.mo)) then
		return false
	end
	player.mo.allow_tf_botjet = false
	player.mo.tf_countdown = 0
	player.mo.fuel_countdown = 0
	player.mo.missile_countdown = 0
end

-- Returns a sound and moves to another.
-- Requeres first member of a table to be an index
local function GetFollowSound(sound_list)
		if(sound_list[1] >= #sound_list) then
			sound_list[1] = 2
		else
			sound_list[1] = $ + 1
		end
		return sound_list[sound_list[1]]
end

-- Death of the missile
addHook("MobjMoveBlocked",
		function(mo)	
		
		end,
		MT_STARSCREAM_ROCKET)


addHook("MobjThinker", 
		function(mo)
			if(mo.lock == nil) then
				searchBlockmap("objects", 
					function(missile, enemy)
						
						local horiz_distance = R_PointToDist2(mo.x, mo.y, enemy.x, enemy.y)
						
						-- Lock on only is conditions are met
						if(enemy ~= nil and
						enemy ~= missile.target and
						enemy.flags & (MF_SHOOTABLE|MF_ENEMY) and 
						MISSLE_LOCK_DISTANCE >= horiz_distance) then
							
							missile.lock = enemy
							
							mo.angle = R_PointToAngle2(mo.x, mo.y, mo.lock.x, mo.lock.y)
							P_InstaThrust(mo, mo.angle, mo.info.speed)

							local vert_distance = mo.lock.z + mo.lock.height/2 - mo.z
							local time = FixedDiv(R_PointToDist2(mo.x, mo.y, enemy.x, enemy.y), mo.info.speed)
							P_SetObjectMomZ(mo, FixedDiv(vert_distance, time), false)

							return true
						end
					end,
					mo,
					mo.x-MISSLE_LOCK_DISTANCE*2,
					mo.x+MISSLE_LOCK_DISTANCE*2,
					mo.y-MISSLE_LOCK_DISTANCE*2,
					mo.y+MISSLE_LOCK_DISTANCE*2)
			else
				-- If there's a lock-on targer
				if(mo.valid and mo.lock.valid) then
					-- P_InstaThrust(mo, R_PointToAngle2(mo.x, mo.y, mo.lock.x, mo.lock.y), mo.info.speed)
					-- P_SetObjectMomZ(mo, (mo.lock.z - mo.z), false)
					-- mo.z = (mo.lock.z - mo.z)
					-- if(mo.lock.z ~= mo.z) then
					-- 	mo.z = $-mo.info.speed
					-- end

					
					-- mo.angle = $ + FixedAngle(FixedDiv(AngleFixed(R_PointToAngle2(mo.x, mo.y, mo.lock.x, mo.lock.y)), mo.info.speed))
					-- P_InstaThrust(mo, mo.angle, mo.info.speed)
				end
			end
		end,
		MT_STARSCREAM_ROCKET)


--The Base Thinker that plays before others,
--mostly used to record players input  before interacting with the abilities
addHook("PreThinkFrame", function()
	for player in players.iterate() do
		--Sets up or cleans up starscream's behavior and attributes when 
		--switched to or off starscream, respectfully
		if(player.mo.prevskin == nil or player.mo.prevskin ~= player.mo.skin) then
			if(player.mo.prevskin == "starscream") then
				CleanUp(player)
			elseif(player.mo.skin == "starscream") then
				StartUp(player)
			end
		end
	end
end)


--The Thinker that plays after other thikers,
--mostly used to clean up, record the previous state, 
--and jump and spin button holding
addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(Valid(player.mo, "starscream")) then
			player.mo.prevskin = player.mo.skin
		end
	end
end)


-- local walk_cap = 20
addHook("PlayerThink",
		function(player)
			if(not player or
			not player.mo or
			player.mo.skin ~= "starscream") then
				return
			end
			
			-- If player is a jet
			if(player.mo.state == S_JET_MODE) then
				player.mo.fuel_countdown = $-1*TICRATE -- decrease fuel in jet mode
				
				if(player.mo.fuel_countdown <= 0*TICRATE) then
					player.mo.state = S_JETBOT -- force to bot
					player.mo.fuel_countdown = FUEL_CAP -- reset fuel to max
				end
			-- If player is a bot
			elseif(player.mo.state == S_BOTJET) then 
				player.mo.fuel_countdown = FUEL_CAP 		-- reset to max fuel
				player.mo.allow_tf_botjet = false			-- not allow to tf into jet
			end
			
			-- End long sounds if they are not irrelevant anymore
			if(S_SoundPlaying(player.mo, sfx_swalk) and
			player.mo.state ~= S_PLAY_WALK) then
				S_StopSoundByID(player.mo, sfx_swalk)
			elseif(S_SoundPlaying(player.mo, sfx_srun) and
			player.mo.state ~= S_PLAY_RUN) then
				S_StopSoundByID(player.mo, sfx_srun)
			end
			
			
			-- Start specific sounds
			if(player.mo.eflags & MFE_JUSTHITFLOOR) then
				local sound = GetFollowSound(land_sound_list)
				if(not S_SoundPlaying(player.mo, sound)) then
					S_StartSound(player.mo, sound, player) 
				end
			elseif(player.mo.state == S_PLAY_RUN) then
				if(not S_SoundPlaying(player.mo, sfx_srun)) then
					S_StartSound(player.mo, sfx_srun, player)
				end
			elseif(player.mo.state == S_PLAY_WALK) then
				if(not S_SoundPlaying(player.mo, sfx_swalk)) then
					S_StartSound(player.mo, sfx_swalk, player)
				end
			elseif(player.mo.prevstate ~= S_PLAY_JUMP and
			player.mo.state == S_PLAY_JUMP) then
				local sound = GetFollowSound(jump_sound_list)
				if(not S_SoundPlaying(player.mo, sound))
					S_StartSound(player.mo, sound, player)
				end
			
			end
			
			-- Don't allow botjet tranformation if
			if(not player.mo.allow_tf_botjet and 					-- transformation is already not allowed
			player.mo.eflags & MFE_JUSTHITFLOOR) then	-- object is falling
				player.mo.allow_tf_botjet = true
			end
			
			-- Transform into bot if ..
			if(player.mo.state == S_JET_MODE and 
			(player.mo.eflags & MFE_JUSTHITFLOOR or  -- jet hit the floor
			player.mo.eflags & MFE_UNDERWATER)) then -- jet submerged under water
				player.mo.state = S_JETBOT
			end
			
			-- Transform into bot if being forced from the jet mode (jet state)
			if(player.mo.prevstate ~= nil and
			player.mo.prevstate == S_JET_MODE and
			player.mo.state ~= S_JET_MODE and
			player.mo.state ~= S_JETBOT) then
				player.mo.state = S_JETBOT
			end
			
			-- Countdowns the transformation cooldown
			if(player.mo.tf_countdown > 0*TICRATE) then
				player.mo.tf_countdown = $-1*TICRATE
			end
			-- Countdown the rocket launch cooldown
			if(player.mo.missile_countdown > 0*TICRATE) then
				player.mo.missile_countdown = $-1*TICRATE
			end
			
			-- Updates previous state
			player.mo.prevstate = player.mo.state
		end)
		
-- Executes each time the player is blocked by solid objects (not entities)
addHook("MobjMoveBlocked", 
		function(player_mo, collider)
			if(not player_mo or 
			player_mo.skin != "starscream" or
			player_mo.state ~= S_JET_MODE)
				return
			end
			
			player_mo.state = S_JETBOT
		end,
		MT_PLAYER)

-- Spin is pressed 
addHook("SpinSpecial", 
		function(player)
			if(player == nil or
			player.mo == nil or
			player.mo.skin ~= "starscream") then
				return
			end
			
			--Launch a missle
			if(player.mo.missile_countdown <= 0) then
				P_SPMAngle(player.mo, MT_STARSCREAM_ROCKET, player.mo.angle)
				player.mo.missile_countdown = MISSILE_TIMER_MAX
			end
		end,
		MT_PLAYER)
			
-- Executes when pressing jump button in the air
addHook("AbilitySpecial",
		function(player)
			-- Decide if transformation can 
			-- happen on players command
			if(player.mo.tf_countdown <= 0 and
			   (player.mo.state == S_JET_MODE or
			   player.mo.state == S_PLAY_JUMP or
			   player.mo.state == S_PLAY_FALL)) then
				
			    -- Transforming into jet when
				if(player.mo.allow_tf_botjet and					-- is allowed to
				not (player.mo.eflags & MFE_UNDERWATER) and	-- not underwater
				player.mo.state != S_JET_MODE) then		-- not already a jet
					player.mo.state = S_BOTJET
					player.mo.tf_countdown = TF_TIMER_MAX
				-- Transforming into bot
				elseif(player.mo.state == S_JET_MODE) then	-- when a jet
					player.mo.state = S_JETBOT
					player.mo.tf_countdown = TF_TIMER_MAX
				end
			end
		end)
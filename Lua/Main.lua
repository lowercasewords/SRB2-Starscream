//A cooldown of tranformation.
local TF_TIMER_MAX = 20*TICRATE
local FUEL_CAP = 500*TICRATE
local MISSILE_TIMER_MAX = 50*TICRATE

//Counts down to zezo
local tf_countdown = TF_TIMER_MAX
local fuel_countdown = FUEL_CAP
local missile_countdown = 0*TICRATE

local allow_tf_botjet = true

local land_sound_list = {2, sfx_sland1, sfx_sland2, sfx_sland3}
local jump_sound_list = {2, sfx_sjump1, sfx_sjump2, sfx_sjump3}

//Returns a sound and moves to another.
//Requeres first member of a table to be an index
local function GetFollowSound(sound_list)
		if(sound_list[1] >= #sound_list) then
			sound_list[1] = 2
		else
			sound_list[1] = $ + 1
		end
		return sound_list[sound_list[1]]
		
end

//Death of the missile
addHook("MobjMoveBlocked",
		function(mo)	
		
		end,
		MT_STARSCREAM_ROCKET)

addHook("MobjThinker", 
		function(mo)
			if(mo.lock == nil) then
				searchBlockmap("objects", 
					function(missile, enemy)
						if(enemy == nil or
						enemy== missile.target or
-- 						not (enemy.flags & MF_SHOOTABLE) or
						not (enemy.flags & MF_ENEMY)) then
-- 						not (enemy.flags & MF_BOSS)) then
							return
						end
				
						missile.lock = enemy
						return
					end,
					mo, 
					mo.x+FRACUNIT,
					mo.x-FRACUNIT,
					mo.y+FRACUNIT,
					mo.y-FRACUNIT)
			else
				if(mo.valid and mo.lock.valid) then
					P_InstaThrust(mo, R_PointToAngle2(mo.x, mo.y, mo.lock.x, mo.lock.y), mo.info.speed)
					if(mo.lock.z ~= mo.z) then
						mo.z = $-mo.info.speed
					end
				end
			end
		end,
		MT_STARSCREAM_ROCKET)

-- local walk_cap = 20
addHook("PlayerThink",
		function(player)
			if(not player or
			not player.mo or
			player.mo.skin != "starscream") then
				return
			end
			
			//If player is a jet
			if(player.mo.state == S_JET_MODE) then
				fuel_countdown = $-1*TICRATE //decrease fuel in jet mode
				
				if(fuel_countdown <= 0*TICRATE) then
					player.mo.state = S_JETBOT //force to bot
					fuel_countdown = FUEL_CAP //reset fuel to max
				end
			//If player is a bot
			elseif(player.mo.state == S_BOTJET) then 
				fuel_countdown = FUEL_CAP 		//reset to max fuel
				allow_tf_botjet = false			//not allow to tf into jet
			end
			
			//End long sounds if they are not irrelevant anymore
			if(S_SoundPlaying(player.mo, sfx_swalk) and
			player.mo.state ~= S_PLAY_WALK) then
				S_StopSoundByID(player.m, sfx_swalk)
			elseif(S_SoundPlaying(player.mo, sfx_srun) and
			player.mo.state ~= S_PLAY_RUN) then
				S_StopSoundByID(player.m, sfx_srun)
			end
			
			
			//Start specific sounds
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
			
			//Don't allow botjet tranformation if
			if(not allow_tf_botjet and 					//transformation is already not allowed
			player.mo.eflags & MFE_JUSTHITFLOOR) then	//object is falling
				allow_tf_botjet = true
			end
			
			//Transform into bot if ..
			if(player.mo.state == S_JET_MODE and 
			(player.mo.eflags & MFE_JUSTHITFLOOR or  //jet hit the floor
			player.mo.eflags & MFE_UNDERWATER)) then //jet submerged under water
				player.mo.state = S_JETBOT
			end
			
			//Transform into bot if being forced from the jet mode (jet state)
			if(player.mo.prevstate ~= nil and
			player.mo.prevstate == S_JET_MODE and
			player.mo.state ~= S_JET_MODE and
			player.mo.state ~= S_JETBOT) then
				player.mo.state = S_JETBOT
			end
			
			//Countdowns the transformation cooldown
			if(tf_countdown > 0*TICRATE) then
				tf_countdown = $-1*TICRATE
			end
			//Countdown the rocket launch cooldown
			if(missile_countdown > 0*TICRATE) then
				missile_countdown = $-1*TICRATE
			end
			
			//Updates previous state
			player.mo.prevstate = player.mo.state
		end)
		
//Executes each time the player is blocked by solid objects (not entities)
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

//Spin is pressed 
addHook("SpinSpecial", 
		function(player)
			if(player == nil or
			player.mo == nil or
			player.mo.skin ~= "starscream")
				return
			end
			
			if(missile_countdown <= 0) then
				P_SPMAngle(player.mo, MT_STARSCREAM_ROCKET, player.mo.angle)
				missile_countdown = MISSILE_TIMER_MAX
			end
		end,
		MT_PLAYER)
			
//Executes when pressing jump button in the air
addHook("AbilitySpecial",
		function(player)
			//Decide if transformation can 
			//happen on players command
			if(tf_countdown <= 0 and
			   (player.mo.state == S_JET_MODE or
			   player.mo.state == S_PLAY_JUMP or
			   player.mo.state == S_PLAY_FALL)) then
				
			    //Transforming into jet when
				if(allow_tf_botjet and					//is allowed to
				not (player.mo.eflags & MFE_UNDERWATER) and	//not underwater
				player.mo.state != S_JET_MODE) then		//not already a jet
					player.mo.state = S_BOTJET
					tf_countdown = TF_TIMER_MAX
				//Transforming into bot
				elseif(player.mo.state == S_JET_MODE) then	//when a jet
					player.mo.state = S_JETBOT
					tf_countdown = TF_TIMER_MAX
				end
			end
		end)
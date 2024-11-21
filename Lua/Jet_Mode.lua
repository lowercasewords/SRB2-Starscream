--Contains all functions of this file
--to be called outside of this file

local SPEED_CAP = 20*FRACUNIT
local SPEED_ADJ = 40
local BOOST_SPEED_CAP = 6*FRACUNIT

local VERT_SPEED_CAP = 20*FRACUNIT
local VERT_ACCELERATION = FRACUNIT
local VERT_GRAVITY = FRACUNIT

local SIDE_INPUT_CAP = 10

local ROLL_ANGLE_ADJ = ANG1
local roll_speed = 0

				
--Altering player inputs in jet mode
addHook("PreThinkFrame",
		function()
			for player in players.iterate() do
				if(player == nil or
				player.mo.skin != "starscream" or
				player.mo.state != S_JET_MODE) then
					continue
				end
				
				--Not allow moving forward on input
				player.cmd.forwardmove = 0
				--Limiting side movement on input
				if(player.cmd.sidemove > SIDE_INPUT_CAP) then
					player.cmd.sidemove = SIDE_INPUT_CAP
				elseif(player.cmd.sidemove < -SIDE_INPUT_CAP) then
					player.cmd.sidemove = -SIDE_INPUT_CAP
				end
				
				break --Stop looping if correct player was found
			end
		end)
		
addHook("PlayerThink",
		function(player)
			
			if(player.mo.skin != "starscream" or
			player.mo.state != S_JET_MODE) then
				return
			end
			
			
			--Constant movement speed
			player.mo.momy = (SPEED_ADJ-abs(player.mo.momz)/FRACUNIT)*sin(player.mo.angle)
			player.mo.momx = (SPEED_ADJ-abs(player.mo.momz)/FRACUNIT)*cos(player.mo.angle)
			
			--Rolling speed depends on horizontal turning speed
			roll_speed = FixedAngle(FRACUNIT/30)*mouse.dx
			
			--Rolling
			if(player.mo.rollangle < ANGLE_90
			and player.mo.rollangle > -ANGLE_90)
				player.mo.rollangle = $-roll_speed
			--Negative boundry
			elseif(player.mo.rollangle < -ANGLE_90)
				player.mo.rollangle = -ANGLE_90+ANG1
			--Positive boundry
			elseif(player.mo.rollangle > ANGLE_90)
				player.mo.rollangle = ANGLE_90-ANG1
			
			end
			
			--Roll negatively by default
			if(player.mo.rollangle < ANGLE_90
			and player.mo.rollangle >= 0)
				player.mo.rollangle = $-ROLL_ANGLE_ADJ
			end
			--Roll positively by default
			if(player.mo.rollangle > -ANGLE_90
			and player.mo.rollangle <= 0)
				player.mo.rollangle = $+ROLL_ANGLE_ADJ
			end
			
			--Constant jet sound
			if not S_SoundPlaying(player.mo, sfx_whoosh) then
				S_StartSound(player.mo, sfx_whoosh, player)
			end
			
			--Throttle up by pressing forward button
			if((input.gameControlDown(GC_BACKWARD) or input.joyAxis(JA_MOVE) > 0) and
			player.mo.momz < VERT_SPEED_CAP) then
				player.mo.momz = $+VERT_ACCELERATION--*input.joyAxis(JA_MOVE)/1000
-- 			end
			--Throttle up by pressing backward buttion
			elseif((input.gameControlDown(GC_FORWARD) or input.joyAxis(JA_MOVE) < 0) and
			player.mo.momz > -VERT_SPEED_CAP) then
				player.mo.momz = $-VERT_ACCELERATION--*input.joyAxis(JA_MOVE)/1000
-- 			end
			
			--Decrease vertical to speed to 0 if no inputs are made
			elseif(player.mo.momz > FRACUNIT)
				player.mo.momz = $-VERT_ACCELERATION/2
			--Increase to 0 if no inputs are made
			elseif(player.mo.momz < -FRACUNIT)
				player.mo.momz = $+VERT_ACCELERATION/2
			end
			
			--Throttle up by pressing backward buttion
-- 			if(player.mo.momz > -VERT_SPEED_CAP) then
-- 				if(input.gameControlDown(GC_FORWARD)) then
-- 					player.mo.momz = $-VERT_ACCELERATION
-- 				elseif(input.joyAxis(JA_MOVE) < 0) then
-- 					print("Down")
-- 					player.mo.momz = $-VERT_ACCELERATION
-- 				end
-- 			end
-- 			if(player.mo.momz < VERT_SPEED_CAP) then
-- 				if(input.gameControlDown(GC_BACKWARD)) then
-- 					player.mo.momz = $+VERT_ACCELERATION
-- 				elseif(input.joyAxis(JA_MOVE) > 0) then
-- 					player.mo.momz = $+VERT_ACCELERATION
-- 					print("Up")
-- 				end
-- 			end
-- 			--Balance to 0 if no inputs are made
-- 			elseif(player.mo.momz > 0) then
-- 				player.mo.momz = $-VERT_ACCELERATION
-- 			--Balance to 0 if no inputs are made
-- 			elseif(player.mo.momz < 0) then
-- 				player.mo.momz = $+VERT_ACCELERATION
-- 			end
			
			
-- 			print(player.cmd.angleturn*865536/ANG1)
-- 			print(player.cmd.buttons & BT_JUMP == true)
-- 			print(player.cmd.buttons & BT_JUMP == true)
-- 			--Throttle up by moving movement axis button down
-- 			elseif(input.joyAxis(JA_MOVE) > ) then
			
-- 			end
-- 			--Throttle down by moving movement axis button up
-- 			elseif(input.joyAxis(JA_MOVE) > ) then
			
-- 			end
			
				--Reach near 0 if no inputs are pressed
-- 			else
-- 				if(player.mo.momz > 0) then
-- 					player.mo.momz = $-VERT_ACCELERATION
-- 				elseif(player.mo.momz < 0) then
-- 					player.mo.momz = $+VERT_ACCELERATION
-- 				end
-- 			end
			
			
				--Gravity adjustment
-- 			player.mo.momz = $+VERT_GRAVITY
			
-- 			print("V: "..player.mo.momz)
-- 			print("S: "..player.speed)
-- 			print("A: "..aiming)
-- 			print("G: "..P_GetMobjGravity(player.mo))
		end)
		
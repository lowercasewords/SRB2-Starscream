
addHook("PlayerThink", 
		function(player)
			if(player == nil or
			player.mo == nil or
			player.mo.skin ~= "starscream" or
			player.mo.state == S_JET_MODE)
				return
			end
			
			
-- 			if(missile_countdown > 0*TICRATE) then
-- 				missile_countdown = $-1*TICRATE
				
-- 			end
		end)
		
addHook("SpinSpecial", 
		function(player)
			if(player == nil or
			player.mo == nil or
			player.mo.skin ~= "starscream" or
			player.mo.state == S_JET_MODE)
				return
			end
			
-- 			if(missile_countdown <= 0) then
-- 				P_SPMAngle(player.mo, MT_STARSCREAM_ROCKET, player.mo.angle)
-- 				missile_countdown = MISSILE_TIMER_MAX
-- 			end
-- 			print(missile.info.deathstate == 0)
-- 			if(missile.info.deathstate == 0) then
-- 				missile = nil
-- 			end
						/*P_SpawnPointMissile(player.mo,
												player.mo.x+100,
												player.mo.y+100,
												player.mo.z+100,
												MT_ROCKET,
												player.mo.x,
												player.mo.y,
												player.mo.z)
												*/
			/*
			local maxdist = 10//FixedMul(RING_DIST, player.mo.scale)
			local targetmobj = nil
			local x1 = player.mo.x+maxdist
			local x2 = player.mo.x-maxdist
			local y1 = player.mo.y+maxdist
			local y2 = player.mo.y-maxdist
			//Searching for enemies to lock-on to
			result = searchBlockmap("objects", 
							function(player_mo, foundmobj)
								if(foundmobj == nil or
								foundmobj == player_mo) then
									return
								end
-- 								print("ogx "..player_mo.x)
-- 								print("ogy "..player_mo.y)
-- 								print("px "..player.mo.x)
-- 								print("py "..player.mo.y)
-- 								print("x1 "..x1)
-- 								print("x2 "..x2)
-- 								print("y1 "..y1)
-- 								print("y2 "..y2)

								if(foundmobj.flags & MF_ENEMY) then
									print("assign")
									targetmobj = foundmobj
									return
-- 									P_TeleportMove(player_mo,
-- 									targetmobj.x, targetmobj.y, targetmobj.z)
								end
-- 								print("Shoot! "..i)
-- 								P_TeleportMove(player_mo,
-- 								foundmobj.x, foundmobj.y, foundmobj.z)
-- 								P_SpawnLockOn(player_mo.player, foundmobj, S_ROCKET)
							end,
							player.mo,
							x1,
							x2,
							y1,
							y2)
			if(targetmobj ~= nil)
				print("shoot")
				P_SpawnLockOn(player, targetmobj, S_ROCKET)
			end
			if(not result) then
				print("interrupted!")
			end
			*/
		end)
		
addHook("JumpSpinSpecial",
		function(player)
			if(player == nil or
			player.mo == nil or
			player.mo.skin ~= "starscream" or
			player.mo.state == S_JET_MODE)
				return
			end

-- 			print("called")
			player.mo.state = S_PLAY_CLIMB
		end)
		
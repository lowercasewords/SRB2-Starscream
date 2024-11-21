--Sprite definitions
freeslot("SPR2_JET_")
--State definitions
freeslot("S_JET_MODE", "S_JETBOT", "S_BOTJET", "S_ROCKET_EXPLOSION")
--Sound definitions
freeslot("sfx_nil", "sfx_jetbot", "sfx_botjet", 
"sfx_whoosh", "sfx_srun", "sfx_swalk", 
"sfx_sland1", "sfx_sland2", "sfx_sland3",
"sfx_sjump1", "sfx_sjump2", "sfx_sjump3")
freeslot("MT_STARSCREAM_ROCKET")

--Sound played when fell on the ground
sfxinfo[sfx_srun] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE
}

--Sound played when walking
sfxinfo[sfx_swalk] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE
}

--Sound played when fell on the ground
sfxinfo[sfx_sland1] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE|SF_X4AWAYSOUND
}
--Sound played when fell on the ground
sfxinfo[sfx_sland2] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE|SF_X4AWAYSOUND
}
--Sound played when fell on the ground
sfxinfo[sfx_sland3] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE|SF_X4AWAYSOUND
}
--Sound played when jumping
sfxinfo[sfx_sjump1] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE--|SF_X4AWAYSOUND
}
--Sound played when jumping
sfxinfo[sfx_sjump2] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE--|SF_X4AWAYSOUND
}
--Sound played when jumping
sfxinfo[sfx_sjump3] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE--|SF_X4AWAYSOUND
}

--Sound played when transforming into bot
sfxinfo[sfx_jetbot] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE
}
--Sound played when transforming into bot
sfxinfo[sfx_botjet] = {
	singular = true,
	priority = 64,
	flags = SF_TOTALLYSINGLE
}
--Constant sound during jet mode
sfxinfo[sfx_whoosh] = {
	singular = false,
	priority = 64,
	flags = SF_X4AWAYSOUND
}

--Transforms into the bot
local function A_TF_BOT()
	for player in players.iterate() do
		if(player == nil or
		player.mo == nil or
		player.mo.skin != "starscream") then
			continue
		end
		S_StartSound(player.mo, sfx_jetbot)
		player.mo.flags = $&~MF_NOGRAVITY
		player.mo.rollangle = 0
		break
	end
end

--Transforms into the jet
local function A_TF_JET()
	for player in players.iterate() do
		if(player == nil or
		player.mo == nil or
		player.mo.skin != "starscream") then
			continue
		end
		S_StartSound(player.mo, sfx_botjet)
		player.mo.flags = $|MF_NOGRAVITY
		break
	end
end

--State of jet
states[S_JET_MODE] = {
	sprite = SPR_PLAY,
	frame = SPR2_JET_,
	tics = -1,
	action = A_PlaySound,
	var1 = sfx_whoosh,
	var2 = 1,
	nextstate = S_JETBOT
}

--State between transformation
--into a jet
states[S_BOTJET] = {
	sprite = SPR_PLAY,
	frame = SPR2_JUMP,
	tics = 1,
	action = A_TF_JET,
	nextstate = S_JET_MODE
}

--State between transofmation
-- into a bot
states[S_JETBOT] = {
	sprite = SPR_PLAY,
	frame = SPR2_JUMP,
	tics = 1,
	action = A_TF_BOT,
	nextstate = S_PLAY_FALL
}

states[S_ROCKET_EXPLOSION] = {
	sprite = SPR_BMNB,
	tics = 0,
	nextstate = S_BIGMINE_BLAST1
}

mobjinfo[MT_STARSCREAM_ROCKET] = {
	spawnstate = S_TORPEDO,
	deathstate = S_ROCKET_EXPLOSION,
	xdeathstate = S_ROCKET_EXPLOSION,
	deathsound = sfx_s3k4e,
	seesound = sfx_brakrl,
	atacksound = sfx_brakrx,
	height = 5*FRACUNIT,
	radius = 5*FRACUNIT,
	damage = 1,
	speed = 50*FRACUNIT,
	flags = MF_NOGRAVITY|MF_MISSILE|MF2_SCATTER
}



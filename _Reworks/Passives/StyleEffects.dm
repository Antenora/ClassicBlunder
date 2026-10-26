/mob/var/tmp/last_style_effect = 0
/mob/var/tmp/last_aura_toss = 0
/obj/Skills/Buffs/var/tmp/last_super_charge = -500

/obj/Skills/AutoHit/Water_Wave
	Copyable = 0
	Area="Wider Wave"
	ComboMaster=1
	Distance = 5
	Size = 4
	DamageMult=1
	Slow = 0.25
	Chilling=5
	Knockback = 2
	TurfStrike=2
	TurfShift='WaterBlue.dmi'
	TurfShiftDuration=3
	Cooldown=5
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0

/mob/proc/can_use_style_effect(passive_name)
	if(last_style_effect == 0)
		return TRUE
	var/static_cd = glob.STYLE_EFFECT_CD
	if(passive_name == "BlindingVenom")
		static_cd += glob.BLINDINGVENOM_CD
	var/cd = static_cd
	if(!passive_name)
		for(var/x in list("AirBend", "WaveDancer", "EntanglingRoots", "BlindingVenom", "BloodEruption"))
			if(x in passive_handler.passives)
				if(passive_handler["[x]"] > 0)
					passive_name = x
		if(passive_name)
			cd = static_cd - ((static_cd/5)*passive_handler["[passive_name]"])
		return (last_style_effect + cd)
	else
		cd = static_cd - ((static_cd/5)*passive_handler["[passive_name]"])
		if((last_style_effect + cd) < world.time)
			return (last_style_effect + cd)
	return FALSE

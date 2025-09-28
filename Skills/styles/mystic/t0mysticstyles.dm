/mob/var/tmp/last_style_effect = 0
/mob/var/tmp/last_aura_toss = 0
/obj/Skills/Buffs/var/tmp/last_super_charge = -500
/obj/Skills/Buffs/NuStyle/MysticStyle
	StyleFor = 1.15
	passives = list("SpiritFlow" = 	1)
	Fire_Weaving
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/MysticStyle/Earth_Moving"="/obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker", \
				"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Black_Leg_Style")
		passives = list("SpiritFlow" = 1, "Burning" = 1, "Combustion" = 25)
		StyleFor = 1.3
		Finisher="/obj/Skills/Queue/Finisher/Dancing_Flame_Attack"
		StyleActive="Fire Weaving"
		ElementalOffense = "Fire"
		ElementalDefense = "Fire"
		ElementalClass = "Fire"
		verb/Fire_Weaving()
			set hidden=1
			src.Trigger(usr)
	Water_Bending
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/MysticStyle/Earth_Moving"="/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing",\
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Wind_Summoning"="/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer", \
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Plague_Bringer"="/obj/Skills/Buffs/NuStyle/MysticStyle/Bloodmancer")
		passives = list("SpiritFlow" = 1, "Chilling" = 1, "WaveDancer" = 1)
		StyleOff = 1.15
		Finisher="/obj/Skills/Queue/Finisher/Surfing_Stream"
		StyleActive="Water Bending"
		ElementalOffense = "Water"
		ElementalDefense = "Water"
		ElementalClass = "Water"
		verb/Water_Bending()
			set hidden=1
			src.Trigger(usr)
	Earth_Moving
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/MysticStyle/Water_Bending"="/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing")
		passives = list("SpiritFlow" = 1, "Shattering" = 1, "EntanglingRoots" = 1)
		StyleEnd = 1.15
		Finisher="/obj/Skills/Queue/Finisher/Unstoppable_Force"
		StyleActive="Earth Moving"
		ElementalOffense = "Earth"
		ElementalDefense = "Earth"
		ElementalClass = "Earth"
		verb/Earth_Moving()
			set hidden=1
			src.Trigger(usr)
	Wind_Summoning
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/MysticStyle/Fire_Weaving"="/obj/Skills/Buffs/NuStyle/MysticStyle/Inferno", \
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Water_Bending"="/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer")
		passives = list("SpiritFlow" = 1, "Shocking" = 1, "AirBend" = 1)
		StyleSpd = 1.15
		Finisher="/obj/Skills/Queue/Finisher/Whirlwind"
		StyleActive="Wind Summoning"
		ElementalOffense = "Wind"
		ElementalDefense = "Wind"
		ElementalClass = "Wind"
		verb/Wind_Summoning()
			set hidden=1
			src.Trigger(usr)
	Plague_Bringer
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Circuit_Breaker_Style", \
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Water_Bending"="/obj/Skills/Buffs/NuStyle/MysticStyle/Bloodmancer")
		passives = list("SpiritFlow" = 1, "Poisoning" = 1, "Rusting" = 1, "BlindingVenom" = 1)
		StyleDef = 1.15
		Finisher="/obj/Skills/Queue/Finisher/Acid_Rain"
		StyleActive="Plague Bringer"
		ElementalOffense = "Poison"
		ElementalDefense = "Poison"
		ElementalClass = "Poison"
		verb/Plague_Bringer()
			set hidden=1
			src.Trigger(usr)

/obj/Skills/AutoHit/Water_Wave
	Copyable = 0
	Area="Wider Wave"
	ComboMaster=1
	Distance = 5
	Size = 4
	AdaptRate = 1
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
		for(var/x in list("AirBend", "WaveDancer", "EntaglingRoots", "BlindingVenom", "BloodEruption"))
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
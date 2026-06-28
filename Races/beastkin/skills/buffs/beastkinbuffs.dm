


/obj/Skills/Queue/Racial/Beastkin/Savagery
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Ripped"
	DamageMult = 1.5
	Dominator = 2
	Finisher = 2
	AccuracyMult = 1.5
	HitMessage = "tears into their enemy!"
	HitSparkIcon = 'MasterSlash.dmi'
	HitSparkX=-16
	HitSparkY=-16
	EnergyCost = 2.5
	Cooldown = 45


	adjust(mob/p)
		DamageMult = 1.5 + (p.AscensionsAcquired * 0.25)
		Dominator = 2 + (p.AscensionsAcquired * 0.5)
		Finisher = 2 + (p.AscensionsAcquired * 0.5)
		Cooldown = 45 - (p.AscensionsAcquired * 5)

	verb/Savagery()
		set category = "Skills"
		adjust(usr)
		usr.SetQueue(src)


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Ripped // TODO: make the buffedaffected attackQ work correctly n make this scale
	TimerLimit = 15
	passives = list("PureReduction" = -0.5)
	adjust(mob/p)
		passives = list("PureReduction" = -0.5 - (0.25 * p.AscensionsAcquired)) // this is calling owner'a sc, which im aware of but fuck it
		TimerLimit = 15 + (5 * p.AscensionsAcquired)
	ActiveMessage = "'s body is ripped to shreds!"







/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Shapeshift
	var/datum/customBuff/c_buff = new()
	proc/init(mob/p)
		c_buff.init(p, src)
	adjust(mob/p)
		if(p.BuffOn(src))
			return
		if(!c_buff.check(p, src))
			return
		var/list/full2short = list("Strength" = "str", "Force" = "for", "Endurance" = "end", "Offense" = "off", "Defense" = "def", \
									"Speed" = "spd")
		for(var/x in full2short)
			var/raa = "[uppertext(copytext(full2short[x],1,2))][copytext(full2short[x], 2,4)]"
			vars["[raa]Mult"] = c_buff.statsadd.calc_stat(c_buff.statsmult.vars[x], TRUE)
			vars["[full2short[x]]Add"] = c_buff.statsadd.calc_stat(c_buff.statsadd.vars[x], TRUE)

		passives = c_buff.current_passives
	verb/Adjust_Shapeshifter()
		set category = "Utility"
		set hidden = 1
		if(!usr.BuffOn(src) && !c_buff.selecting_aguments)
			c_buff.adjust_custom_buff(usr, src)
			if(!c_buff.check(usr, src))
				return

/obj/Skills/Buffs/SlotlessBuffs/Racial/Blend_In
	Invisible = 22
	ActiveMessage = "blends into their surroundings"
	verb/Blend_In()
		set category = "Utility"
		set hidden = 1
		Trigger(usr)


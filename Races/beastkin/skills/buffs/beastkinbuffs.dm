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
		if(!usr.BuffOn(src) && !c_buff.selecting_aguments)
			c_buff.adjust_custom_buff(usr, src)
			if(!c_buff.check(usr, src))
				return

/obj/Skills/Buffs/SlotlessBuffs/Racial/Blend_In
	Invisible = 22
	ActiveMessage = "blends into their surroundings"
	verb/Blend_In()
		set category = "Utility"
		Trigger(usr)


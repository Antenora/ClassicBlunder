
/mob/proc/getTypeBonus(unarmed, spirit)
	if(spirit && HasSpiritualDamage())
		. += GetSpiritualDamage()

/mob/proc/getDuelistBonus(mob/defender)
	if(Target && HasDuelist())
		if(Target == defender)
			. += GetDuelist()

/obj/Skills/Buffs/proc/incrementLimit(mob/player, option)
	var/varLimit = option + "Limit"
	if(!vars[varLimit])
		return FALSE
	if(vars[option] ++ >= vars[varLimit])
		vars[option] = 0
		Trigger(player)
		return TRUE
	return FALSE

/mob/proc/triggerLimit(option)
	var/varName = option + "Hits"
	var/varLimit = option + "HitsLimit"
	var/list/varlist = list("ActiveBuff","SpecialBuff","SlotlessBuffs","StanceBuff","StyleBuff")
	if(HasPassive(varLimit, BuffsOnly = 1, NoMobVar = 1))
		for(var/x in varlist)
			if(vars[x])
				if(istype(vars[x], /list)) // must b slotlessbuffs
					for(var/buffs in vars[x]) // index it
						if(vars[x][buffs]) // index of an index, kind of autistic, make sure it exists though (it should but w/e)
							if(vars[x][buffs].vars[varLimit] != 0) // make sure its not 0 before we put it up
								vars[x][buffs].incrementLimit(src, varName) // yeah put it up
				else
					if(vars[x].vars[varLimit] != 0)
						vars[x].incrementLimit(src, varName)
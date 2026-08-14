/mob/Admin3/verb/changeStrikeFormula()
	if(!src.Alert("Live-tune the strike formula?")) return
	switch(input(src, "What one?") in list("Strike K", "Strike Scale", "DMG Power"))
		if("Strike K")
			glob.STRIKE_MITIGATION_K = input(src, "What value?") as num
		if("Strike Scale")
			glob.STRIKE_DAMAGE_SCALE = input(src, "What value?") as num
		if("DMG Power")
			glob.DMG_POWER_EXPONENT = input(src, "What value?") as num

/mob/proc/getStatDmg2(damage, unarmed, sword, sunlight, spirithand, autohit = FALSE)
	// ABILITY and DAMAGE roll should be first
	// so a queue should happen here vs later
	if(!unarmed&&!sword)
		if(EquippedSword())
			sword = 1
		else
			unarmed = 1
	var/statDamage
	statDamage = GetStr(1)
	if(autohit && !passive_handler["Divine Technique"])
		return statDamage
	statDamage += getDeterminationMeleeBonus()

	return statDamage


/mob/proc/getEndStat(n)
	return GetEnd(n) // who did this, was this me??






/mob/Admin4/verb/WhosAscended()
	for(var/mob/x in players)
		if(x.AscensionsUnlocked>0)
			src<<"[x] has [x.AscensionsUnlocked] Ascensions Unlocked!"
/mob/Admin3/verb/changeStrikeFormula()
	if(!src.Alert("Live-tune the strike formula?")) return
	switch(Ask(src, "What one?", "", null, "pick", list("Strike K", "Strike Scale", "DMG Power", "Atk Base", "HP per Vit", "HP Stat Base"), 0))
		if("Strike K")
			glob.STRIKE_MITIGATION_K = Ask(src, "What value?", "", null, "num", null, 0)
		if("Strike Scale")
			glob.STRIKE_DAMAGE_SCALE = Ask(src, "What value?", "", null, "num", null, 0)
		if("DMG Power")
			glob.DMG_POWER_EXPONENT = Ask(src, "What value?", "", null, "num", null, 0)
		if("Atk Base")
			glob.STRIKE_ATK_BASE = Ask(src, "What value?", "", null, "num", null, 0)
		if("HP per Vit")
			glob.HP_PER_VIT = Ask(src, "What value?", "", null, "num", null, 0)
		if("HP Stat Base")
			glob.HP_STAT_BASE = Ask(src, "What value?", "", null, "num", null, 0)

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
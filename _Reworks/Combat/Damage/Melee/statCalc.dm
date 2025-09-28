// SPIRIT STRIKE - USE FORCE AS BASE


// HYBRID STRIKE - USE STR AS BASE AND DO FORCE (TICK%) EXTRA DAMAGE (MULTIPLICATIVE)
// SPIRIT HAND - USE STR AS BASE AND ADD TICK% FOR DAMAGE (ADDITIVE)
// SPIRIT SWORD - USE STR AS BASE AND ADD TICK% FOR DAMAGE (ADDITIVE)


/mob/Admin3/verb/tryExperminetalAccuracy()
	var/accuracy = input(src, "On/Off") in list("On", "Off")
	switch(accuracy)
		if("On")
			EXPERIMENTAL_ACCURACY = TRUE

		if("Off")
			EXPERIMENTAL_ACCURACY = FALSE



/mob/Admin3/verb/changeEffectiveness()
	switch(input(src, "What one?") in list("DMG", "DMG End", "DMG Power", "Melee", "Projectile", "Grapple", "Autohit"))
		if("DMG")
			glob.DMG_STR_EXPONENT = input(src, "What value?") as num

		if("DMG End")
			glob.DMG_END_EXPONENT = input(src, "What value?") as num

		if("DMG Power")
			glob.DMG_POWER_EXPONENT = input(src, "What value?") as num
		if("Melee")
			glob.MELEE_EFFECTIVENESS = input(src, "What value?") as num

		if("Projectile")
			glob.PROJECTILE_EFFECTIVNESS = input(src, "What value?") as num

		if("Grapple")
			glob.GRAPPLE_EFFECTIVNESS = input(src, "What value?") as num

		if("Autohit")
			glob.AUTOHIT_EFFECTIVNESS = input(src, "What value?") as num





/mob/proc/getStatDmg2(damage, unarmed, sword, sunlight, spirithand, autohit = FALSE)
	// ABILITY and DAMAGE roll should be first
	// so a queue should happen here vs later
	if(!unarmed&&!sword)
		if(EquippedSword())
			sword = 1
		else
			unarmed = 1
	var/statDamage
	if(passive_handler.Get("IdealStrike"))
		if(GetFor() > GetStr())
			statDamage = GetFor()
		else
			statDamage = GetStr()
	else if(HasSpiritStrike())
		statDamage = GetFor(1)
	else
		statDamage = GetStr(1)
	if(passive_handler.Get("HardenedFrame"))
		statDamage = GetEnd(1)
	if(!glob.EXTRASTATSONAUTOHIT && autohit && !passive_handler["Divine Technique"])
		return statDamage
	var/endExtra = passive_handler.Get("CallousedHands")
	if(endExtra>0)
		statDamage += GetEnd(endExtra) 
	// there should only b one use case for this
	var/full_effeciency = passive_handler.Get("FullyEffecient")
	if(full_effeciency)
		if(GetFor() > GetStr())
			if((HasSpiritHand() || spirithand)&&unarmed)
				if(spirithand < GetSpiritHand())
					spirithand = GetSpiritHand()
				statDamage += GetStr(spirithand/4) 
			if((HasSpiritSword())&&sword)
				statDamage += GetStr(GetSpiritSword())
			if(HasHybridStrike())
				statDamage *=  1 + (GetStr(GetHybridStrike())/10)
			return statDamage
	// otherwise there is no problem
	if(HasSpiritHand()&&unarmed)
		if(spirithand > GetSpiritHand())
			statDamage += GetFor(spirithand/4) // this can b less lines
		else
			statDamage += GetFor(GetSpiritHand()/4)
	if(HasSpiritSword()&&sword)
		statDamage += GetFor(GetSpiritSword())
	if(HasHybridStrike())
		statDamage *=  1 + (GetFor(GetHybridStrike())/10)
	
	return statDamage


/mob/proc/getEndStat(n)
	return GetEnd(n) // who did this, was this me??






/mob/Admin4/verb/WhosAscended()
	for(var/mob/x in players)
		if(x.AscensionsUnlocked>0)
			src<<"[x] has [x.AscensionsUnlocked] Ascensions Unlocked!"

/*



if(src.UsingSunlight()||src.HasSpiritHand()&&(UnarmedAttack||SwordAttack))
		var/forModifier = 1
		if(src.StyleActive!="Sunlight"&&src.StyleActive!="Moonlight"&&src.StyleActive!="Atomic Karate"&&!src.CheckSpecial("Prana Burst"))
			forModifier = GetFor()**(1/2)
			Damage *= 1 + ((src.GetStr()*forModifier)/10)
		else
			forModifier = clamp(src.GetFor(0.5), 1.25, 2)
			Damage*= 1 + ((src.GetStr()*forModifier)/10)
	else if(SwordAttack&&src.HasSpiritSword())
		var/str = src.GetStr(src.GetSpiritSword())
		var/force = src.GetFor(src.GetSpiritSword())
		Damage*= 1 + ((str+force) / 10 )
	else if(src.HasHybridStrike())
		var/str = src.GetStr()
		var/force = src.GetFor(src.GetHybridStrike())
		Damage*= 1 + ((str+force) / 10)
	else if(src.HasSpiritStrike())
		Damage*= 1 + (src.GetFor() /10 )
	else
		Damage*= 1 + (src.GetStr() / 10)


*/
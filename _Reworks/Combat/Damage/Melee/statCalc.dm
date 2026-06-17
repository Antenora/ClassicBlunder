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
	var/endExtra = GetCallousedHands();
	var/greenExtra=0
	if(passive_handler.Get("Determination(Green)")||passive_handler.Get("Determination(White)"))
		greenExtra=GetEnd(round(ManaAmount/400,1))//(round(ManaAmount/100,1)*GetEnd(1))*0.2
		if(passive_handler.Get("Determination(White)"))
			greenExtra*=2.5
		statDamage+=greenExtra
	if(endExtra>0)
		var/endBonus = GetEnd(endExtra)
		if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
			src.Target.applyApathyBonus(endBonus)
		else
			statDamage += endBonus
	// there should only b one use case for this
	var/full_effeciency = passive_handler.Get("FullyEffecient")
	if(full_effeciency)
		if(GetFor() > GetStr())
			if((HasSpiritHand() || spirithand)&&unarmed)
				if(spirithand < GetSpiritHand())
					spirithand = GetSpiritHand()
				var/shBonus_fe = GetStr(spirithand)
				if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
					src.Target.applyApathyBonus(shBonus_fe)
				else
					statDamage += shBonus_fe
			if((HasSpiritSword())&&sword)
				var/ssBonus_fe = GetStr(GetSpiritSword())
				if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
					src.Target.applyApathyBonus(ssBonus_fe)
				else
					statDamage += ssBonus_fe
		if(HasHybridStrike())
			var/hsMult_fe = clamp(1+sqrt(GetStr(GetHybridStrike())/15),1,3)
			if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
				src.Target.applyApathyBonus(statDamage * (hsMult_fe - 1))
			else
				statDamage *= hsMult_fe
		if(HasPhysPleroma())
			var/ppMult_fe = clamp(1+sqrt(GetStr(GetPhysPleroma())/15),1,3)
			if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
				src.Target.applyApathyBonus(statDamage * (ppMult_fe - 1))
			else
				statDamage *= ppMult_fe
		return statDamage
	// otherwise there is no problem
	if(HasSpiritHand()&&unarmed)
		if(HasPhysPleroma())
			var/shBonus = spirithand > GetSpiritHand() ? GetStr(spirithand/4) : GetStr(GetSpiritHand()/4)
			if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
				src.Target.applyApathyBonus(shBonus)
			else
				statDamage += shBonus
		else
			var/shBonus = spirithand > GetSpiritHand() ? GetFor(spirithand/4) : GetFor(GetSpiritHand()/4)
			if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
				src.Target.applyApathyBonus(shBonus)
			else
				statDamage += shBonus
	if(HasSpiritSword()&&sword)
		var/ssBonus = HasPhysPleroma() ? GetStr(GetSpiritSword()) : GetFor(GetSpiritSword())
		if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
			src.Target.applyApathyBonus(ssBonus)
		else
			statDamage += ssBonus
	if(HasHybridStrike())
		var/hsMult = clamp(sqrt(1+GetFor(GetHybridStrike())/15),1,3)
		if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
			src.Target.applyApathyBonus(statDamage * (hsMult - 1))
		else
			statDamage *= hsMult
	if(HasPhysPleroma())
		var/ppMult = clamp(sqrt(1+GetStr(GetPhysPleroma())/15),1,3)
		if(src.Target && src.Target.passive_handler && src.Target.passive_handler.Get("ApathyFactor") && src.Target.isInHighTension() && src.Target.Health >= 30)
			src.Target.applyApathyBonus(statDamage * (ppMult - 1))
		else
			statDamage *= ppMult

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
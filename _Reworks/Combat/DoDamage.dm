/mob/proc/inStasis()
	return Stasis
// AI HANDLING
/mob/proc/handleAI(mob/defender)
	var/mob/Player/AI/aiTarget
	if(istype(defender, /mob/Player/AI))
		aiTarget = defender
		if(aiTarget.ai_adapting_power && !aiTarget.ai_power_adapted)
			aiTarget.ai_power_adapted = 1
			aiTarget.SetTarget(src)
			aiTarget.AIAvailablePower()
		if(!aiTarget.ai_team_fire && aiTarget.AllianceCheck(src))
			return FALSE
	return TRUE

/* DAMAGE HANDLING */

/mob/proc/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit)
	if(inStasis() || defender.inStasis())
		return
	if(defender == src)
		DamageSelf(val)
		return
	else if(defender == null)
		return
	if(!handleAI(defender)) // handles ai
		return
	if(unarmed || sword)
		triggerLimit("Physical")
		triggerLimit("Sword")
		triggerLimit("Unarmed")
	if(spiritAtk)
		triggerLimit("Spirit")
	if(AttackQueue)
		if(AttackQueue.Quaking)
			Quake(AttackQueue.Quaking)
	#if DEBUG_DAMAGE
	log2text("Damage", "Before BalanceDamage", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	val *= glob.WorldDamageMult
	if(val <= 0)
		#if DEBUG_DAMAGE
		log2text("Damage", "was negative", "damageDebugs.txt", "[src.ckey]/[src.name]")
		log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif
		val = 0.015
		#if DEBUG_DAMAGE
		log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif
	#if DEBUG_DAMAGE
	log2text("Damage", "After BalanceDamage", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	val /= getInfactuation(defender)
	#if DEBUG_DAMAGE
	log2text("Damage", "After Infactuation", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	var/preCrit = val
	if((unarmed || sword) || (spiritAtk && !autohit && passive_handler["IceHerald"]) || (autohit && passive_handler["DemonicInfusion"]))
		val = getCritAndBlock(defender, val)
		if(val > preCrit)
			if(passive_handler["Wuju"] == 1)
				val += glob.BASE_WUJUDAMAGE
			var/obj/Effects/crit/p = new()
			p.Target = defender
			defender.vis_contents += p
			flick("crit", p)
		else
			if(val < preCrit)
				var/obj/Effects/critB/p = new()
				p.Target = defender
				defender.vis_contents += p
				flick("critblock", p)

			
	#if DEBUG_DAMAGE
	log2text("Damage", "After CritAndBlock", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	// VALUE THINGS ABOVE (THE PURE DAMAGE)
	trueMult += getIntimDMGReduction(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Intim", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	// gain red/dmg from intim
	trueMult += getSPPower()
	#if DEBUG_DAMAGE
	log2text("trueMult", "After SP", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	trueMult += GetDesperationBonus(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Desperation", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	if(passive_handler.Get("Powerhouse"))
		var/boon = round(src.Energy/100 * passive_handler.Get("Powerhouse"),0.1)
		trueMult += boon



	var/puredmg = HasPureDamage() ? HasPureDamage() : 0
	if(!glob.PURE_MOD_POST_CALC)
		puredmg *= glob.PURE_MODIFIER
	trueMult += puredmg

	var/lifeFiberRending = passive_handler.Get("Life Fiber Rending")
	lifeFiberRending *= glob.LIFE_FIBER_RENDING_MODIFIER
	if(lifeFiberRending)
		if(defender.KamuiType == "Senketsu" || defender.Secret == "Vampire" || defender.GetSlotless("Life Fiber Hybrid"))
			trueMult += lifeFiberRending
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Puredmg", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	var/purered = defender.HasPureReduction() ? defender.HasPureReduction() : 0
	if(!glob.PURE_MOD_POST_CALC)
		purered *= glob.PURE_MODIFIER
	trueMult -= purered
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Purered", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	trueMult += getTypeBonus(unarmed, spiritAtk)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After TypeBonus", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult += getDuelistBonus(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After DuelistBoon", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult -= defender.getDuelistBonus(src)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After DuelistRed", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

// LIGHT VS DARK CALCULATIONS

	trueMult += getLightDarkCalc("Offense")
	#if DEBUG_DAMAGE
	log2text("trueMult", "After LightDarkCalc", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult += defender.getLightDarkCalc("Defense")
	#if DEBUG_DAMAGE
	log2text("trueMult", "After LightDarkCalc", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	if(defender.CheckSlotless("Heartless") && src.CheckActive("Keyblade"))
		trueMult += src.SagaLevel
	if(src.CheckSlotless("Heartless") && defender.CheckActive("Keyblade"))
		trueMult -= src.SagaLevel
// END LIGHT VS DARK CALCULATIONS
//move timestop + world dmg mult to after true mult is applied

	var/oldEDefense = defender.getArmorEDefense()

	trueMult+=ElementalCheck(src,defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After ElementalCheck", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	if(sword&&HasSword())
		trueMult += doWeaponElements(secondhit, thirdhit, defender, list(EquippedSword(), EquippedSecondSword(), EquippedThirdSword()))
		#if DEBUG_DAMAGE
		log2text("trueMult", "After SwordElements", "damageDebugs.txt", "[src.ckey]/[src.name]")
		log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif
	if((spiritAtk || UsingBattleMage()) && HasStaff())
		trueMult += handleStaff(EquippedStaff(), defender, secondhit)
		#if DEBUG_DAMAGE
		log2text("trueMult", "After StaffElements", "damageDebugs.txt", "[src.ckey]/[src.name]")
		log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif

	trueMult += ElementalCheck(src, defender, damageOnly = TRUE) 
	#if DEBUG_DAMAGE
	log2text("trueMult", "After ElementPassives", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	applySoftCC(defender, val)
	applyAdditonalDebuffs(defender, val)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Debuffs", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	if(oldEDefense)
		defender.ElementalDefense = oldEDefense
	trueMult += styleModifiers(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After StyleModifiers", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult += attackModifiers(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After AttackModifiers", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	
	if(defender.DefianceRetaliate&&!defender.CheckSlotless("Great Ape"))
		if(Health>defender.Health)
			trueMult -= defender.DefianceRetaliate
			#if DEBUG_DAMAGE
			log2text("trueMult", "After Defiance", "damageDebugs.txt", "[src.ckey]/[src.name]")
			log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
			#endif
	if(glob.PURE_MOD_POST_CALC)
		trueMult *= glob.PURE_MODIFIER
	trueMult += godKiModifiers(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After GodKiModifiers", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult += finalModifiers(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After FinalModifiers", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	val = calculateTrueMult(trueMult, val)

	if(passive_handler.Get("Ruckus"))
		if(defender.race.name == passive_handler.Get("RuckusRace")) // this should technically work
			val *= 1 + (0.1 * passive_handler.Get("Ruckus"))
		else
			val *= 1 - (0.05 * passive_handler.Get("Ruckus"))
			

	#if DEBUG_DAMAGE
	log2text("Damage", "After TrueMult", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	if(!checkPurity(defender))
		#if DEBUG_DAMAGE
		log2text("Damage", "Purity moment", "damageDebugs.txt", "[src.ckey]/[src.name]")
		log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif
		return 0
	return val


/mob/proc/checkPurity(mob/defender)
	if(HasPurity())
		if(HasHolyMod())
			if(HasBeyondPurity())
				return TRUE
			if(!defender.IsEvil())
				return FALSE
	return TRUE

/mob/proc/fieldAndDefense(mob/defender, unarmed, sword, spiritAtk, val)
	if(!val) return
	if(defender.UsingVoidDefense())
		if(defender.TotalFatigue>0)
			defender.HealFatigue(val/3)
		else
			defender.HealWounds(val/3)
		defender.HealEnergy(val/2)
		defender.HealMana(val/2)

	if(defender.passive_handler.Get("Gluttony"))
		var/value = defender.passive_handler.Get("Gluttony") * (glob.FIELD_MODIFIERS + glob.GLUTTONY_MODIFIER)
		WoundSelf(value * val )
		GainFatigue(value * val)
		Tension += value * val * glob.TENSION_MULTIPLIER


	if(defender.HasDeathField() && (unarmed || sword))
		var/deathFieldValue = defender.GetDeathField() * glob.FIELD_MODIFIERS // should be 0.01(?), 15 = 15% dmg takebnn reflective if they do 100
		WoundSelf(deathFieldValue * min(1/val,1))
		Tension += deathFieldValue * min(1/val,1) * glob.TENSION_MULTIPLIER
	if(defender.HasVoidField()&&spiritAtk)
		var/voidFieldValue = defender.GetVoidField() * glob.FIELD_MODIFIERS
		GainFatigue(voidFieldValue * min(1/val,1))




/mob/proc/finalizeDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive)


/mob/proc/calculateTrueMult(trueMult, val)
	var/extra = 0.1*trueMult
	#if DEBUG_DAMAGE
	log2text("Damage", "Final Damage Before TrueMult", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	if(trueMult>0) // altered
		val *= 1+extra
	else if(trueMult<0) // altered
		val/= 1+(-extra)
	return val

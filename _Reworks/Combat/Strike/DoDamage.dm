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

/mob/proc/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, list/dmgTypes, strike/S = null)
	if(inStasis() || defender.inStasis())
		return 0;
	if(defender.Airborne)
		return 0
	if(defender.AdminOverwatchActive)
		return 0;
	if(defender.HiddenInShadow)
		return 0
	if(defender == src)
		DEBUGMSG("Defender was src, and so newDoDamage stopped early")
		DamageSelf(HPToPct(val))
		return val
	else if(defender == null)
		return 0;
	if(!handleAI(defender)) // handles ai
		return 0;
/*	if(!checkPurity(defender))
		DEBUGMSG("[defender] is too pure to hit");
		return 0
	MarkCombat(defender)
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
	if(defender.held_skill?.HeldVulnerability)
		val *= 1 + defender.held_skill.HeldVulnerability
	if(defender.rush_vuln_until > world.time)
		val *= 1.25
	if(src.nerve_weaken && world.time < src.nerve_weaken_until)
		val *= max(1 - src.nerve_weaken, 0.5)
		src.nerve_weaken = 0
	if(defender.perfect_guard_until > world.time && defender.AttackQueue && defender.AttackQueue.PerfectGuard)
		defender.perfect_guard_until = 0
		FlashPerfectGuard(src, defender)
		var/obj/Skills/pgq = defender.AttackQueue
		defender.ClearQueue()
		var/pg_ng = pgq.NoGCD
		var/pg_fs = defender.last_skill_fire_time
		pgq.NoGCD = 1
		pgq.Cooldown(1, null, defender)
		pgq.NoGCD = pg_ng
		defender.last_skill_fire_time = pg_fs
		pgq.RefundCooldown(0.5)
		return 0
	if(val <= 0)
		#if DEBUG_DAMAGE
		log2text("Damage", "was negative", "damageDebugs.txt", "[src.ckey]/[src.name]")
		log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif
		val = 0
		#if DEBUG_DAMAGE
		log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
		#endif
	#if DEBUG_DAMAGE
	log2text("Damage", "After BalanceDamage", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	val /= getInfatuation(defender)
	#if DEBUG_DAMAGE
	log2text("Damage", "After Infatuation", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	#if DEBUG_DAMAGE
	log2text("Damage", "After CritAndBlock", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	// VALUE THINGS ABOVE (THE PURE DAMAGE)
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
		var/boon = src.Energy/100 * passive_handler.Get("Powerhouse")
		trueMult += boon

	if(WSMuramasa())
		if(defender.Dead || src.Dead)
			trueMult += 1
		if(defender.Secret == "Vampire")
			trueMult += 1

	var/puredmg = HasPureDamage() ? HasPureDamage() : 0
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
	if(passive_handler.Get("Aspect of Death"))
		purered*=0.75
	trueMult -= purered
	// Unbroken for Makyos
	var/unbrokenVal = defender.passive_handler.Get("Unbroken")
	if(unbrokenVal)
		trueMult -= unbrokenVal
		if(defender.unbreakable_tracking)
			// Cap at 40 so half never exceeds +20 DamageMult, subject to change
			defender.unbroken_absorbed = min(defender.unbroken_absorbed + (val * 0.1 * unbrokenVal), 40)
	// Inevitable
	if(unarmed || sword)
		var/inevVal = passive_handler.Get("Inevitable")
		if(inevVal)
			trueMult += 5 * inevVal
	if(passive_handler.Get("Speed Force"))
		var/EffectiveSF=1
		if(Secret=="Heavenly Restriction" && secretDatum?:hasImprovement("Speed"))
			EffectiveSF=2
		var/SF=passive_handler.Get("Speed Force")
		trueMult -= glob.SPEED_FORCE_TRUEMULT * (SF/EffectiveSF)
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

	trueMult += getLightDarkCalc("Offense", defender)
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

	if(!(S && S.trueDamage))
		trueMult+=ElementalCheck(src,defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After ElementalCheck", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	applySoftCC(defender, val)
	applyAdditonalDebuffs(defender, val)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Debuffs", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult += styleModifiers(defender)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After StyleModifiers", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	trueMult += attackModifiers(defender, dmgTypes)
	#if DEBUG_DAMAGE
	log2text("trueMult", "After AttackModifiers", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif

	if(defender.DefianceRetaliate&&!defender.CheckSlotless("Great Ape"))
		if(HealthPct()>defender.HealthPct())
			trueMult -= defender.DefianceRetaliate
			#if DEBUG_DAMAGE
			log2text("trueMult", "After Defiance", "damageDebugs.txt", "[src.ckey]/[src.name]")
			log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
			#endif
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

	//block first - Def's answer to Off's crit. after the stack so both act on the whole hit
	var/critDMG = getCritDmg()
	var/critChance = getCritChance(S ? S.critEff : 1, S ? S.critBonus : 0)
	if(S)
		S.critChance = critChance
	if(prob(defender.getBlockChance(S ? S.blockEff : 1)))
		val /= defender.getBlockDR()
		if(S)
			S.didBlock = 1
		var/obj/Effects/critB/pb = new()
		pb.Target = defender
		defender.vis_contents += pb
		flick("critblock", pb)
	else if(SureCrit || passive_handler["SureCrit"] || prob(critChance))
		SureCrit = 0
		val *= critDMG
		if(S)
			S.didCrit = 1
		if(passive_handler["Wuju"] == 1)
			val += glob.BASE_WUJUDAMAGE
		var/obj/Effects/crit/pc = new()
		pc.Target = defender
		defender.vis_contents += pc
		flick("crit", pc)


	if(passive_handler.Get("Undying Rage"))
		val*=0.1
	var/miraclechance = (100-defender.HealthPct())*0.6
	if(defender.passive_handler.Get("Miracle"))
		if(defender.HealthPct()<30)
			if( prob(miraclechance))
				val=0
	if(HasEmptySeat())
		passive_handler.Increase("AlphainForce", val)
	#if DEBUG_DAMAGE
	log2text("Damage", "After TrueMult", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	// Alignment-conditional damage resistance (EvilResist vs Evil attackers, GoodResist vs Good)
	if(defender.passive_handler.Get("EvilResist"))
		val *= src.IsEvil() ? defender.getEvilResistValue() : defender.getEvilResistVulnValue()
	if(defender.passive_handler.Get("GoodResist"))
		val *= src.IsGood() ? defender.getGoodResistValue() : defender.getGoodResistVulnValue()
	if(defender.passive_handler.Get("ChaosResist"))
		val *= (src.IsGood() || src.IsEvil()) ? defender.getChaosResistValue() : defender.getChaosResistVulnValue()
	// For Irooni, debuff's current color rewards the matching attack type and punishes a wrong
	// one. Red=Autohit, Blue=Queue, Green=Projectile. Match x1.5 damage, mismatch x0.5.
	// Normal attacks and grapples and other forms of damage are exempt from this
	if(val > 0 && defender.IroniActive && defender.IroniCaster == src)
		var/IroniType = null
		if(src.AutoHitting)
			IroniType = "red"
		else if(AttackQueue)
			IroniType = "blue"
		else if(ProjectileAttacking)
			IroniType = "green"
		if(IroniType)
			var/IroniNewBurst = (world.time - src.IroniLastResonateTime > 10)
			if(IroniType == defender.IroniColor)
				val *= 1.5
				if(src.client && IroniNewBurst)
					src << "<font color='#ffd24d'><b>Irooni resonates, your strike hits harder!</b></font>"
			else
				val *= 0.5
			src.IroniLastResonateTime = world.time
	// Ichidanme: Tameraikizu no Wakachiai makes it so whoever deals damage to the other also takes that damage 
	// to themselves as Injury. Excludes Itokiribasami
	if(val > 0 && src.TameraikizuActive && src.TameraikizuPartner == defender && !src.ItokiribasamiAttacking)
		src.WoundSelf(val)
	if(val > 0 && ismob(defender))
		defender.last_damaged_time = world.time
		if(defender != src)
			defender.last_attacker = src
		if(world.time - defender.pain_stamp > 50)
			defender.pain_amount = 0
		defender.pain_amount += val
		defender.pain_stamp = world.time
	return val


/mob/proc/checkPurity(mob/defender)
	if(HasPurity())
		if(HasHolyMod())
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


	if(defender.HasDeathField() && (unarmed || sword))
		var/deathFieldValue = defender.GetDeathField() * glob.FIELD_MODIFIERS // should be 0.01(?), 15 = 15% dmg takebnn reflective if they do 100
		WoundSelf(deathFieldValue * val)
	if(defender.HasVoidField()&&spiritAtk)
		var/voidFieldValue = defender.GetVoidField() * glob.FIELD_MODIFIERS
		GainFatigue(voidFieldValue * val)




/mob/proc/finalizeDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive)


/mob/proc/calculateTrueMult(trueMult, val)
	var/extra = glob.TRUEMULT_POINT_VALUE*trueMult
	#if DEBUG_DAMAGE
	log2text("Damage", "Final Damage Before TrueMult", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	if(trueMult>0) // altered
		val *= 1+extra
	else if(trueMult<0) // altered
		val/= 1+(-extra)
	return val

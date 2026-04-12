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
		return 0;
	if(defender.AdminOverwatchActive)
		return 0;
	if(defender == src)
		DEBUGMSG("Defender was src, and so newDoDamage stopped early")
		// Dark Survivor mage passive: self-damage refunds 20% of the incoming value
		// as mana and energy. Raw incoming val is used (pre-mitigation) so the refund
		// matches the doc literal "refunds 20% value". Direct assignment + cap clamp
		// is intentional over HealMana/HealEnergy to skip the potion-heal divider chain.
		if(src.hasMagePassive(/mage_passive/dark/Survivor))
			var/refund = val * 0.20
			if(refund > 0)
				src.ManaAmount += refund
				src.MaxMana()
				src.Energy += refund
				src.MaxEnergy()
		// Dark Shadowbringer mage passive: self-damage grants LifeSteal 10 for 10
		// seconds. Stacks if further self-damage lands within the window — each
		// event schedules its own decrease, so two hits 5s apart give 20 LifeSteal
		// for the first 5s, 10 for the next 5s, then back to baseline.
		if(src.hasMagePassive(/mage_passive/dark/Shadowbringer))
			src.passive_handler.Increase("LifeSteal", 10)
			spawn(100)
				if(src && src.passive_handler)
					src.passive_handler.Decrease("LifeSteal", 10)
		DamageSelf(val)
		return 0;
	else if(defender == null)
		return 0;
	if(!handleAI(defender)) // handles ai
		return 0;
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
	val /= getInfatuation(defender)
	#if DEBUG_DAMAGE
	log2text("Damage", "After Infatuation", "damageDebugs.txt", "[src.ckey]/[src.name]")
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
	// Space Relativity mage passive (attacker side): the mage gains 0.5
	// effective PureDamage for every point of PureReduction the defender carries.
	// Reads HasPureReduction() so the bonus tracks the canonical defender value
	// (passive_handler PureReduction plus Mythical, Determination, Honor, Majin,
	// Tarot, etc). Pairs with the defender-side Relativity hook in the purered
	// section below. PURE_MODIFIER pre-calc scaling matches the base puredmg path.
	if(src.hasMagePassive(/mage_passive/space/Relativity))
		var/relativity_pd = defender.HasPureReduction() * 0.5
		if(relativity_pd > 0)
			if(!glob.PURE_MOD_POST_CALC)
				relativity_pd *= glob.PURE_MODIFIER
			trueMult += relativity_pd
	// Dark Iconoclast mage passive (attacker side): the mage gains 1 effective
	// PureDamage for every 5% Health gap between attacker and defender. Health is
	// already a 0-100 scale value (see _BinaryChecks.dm:1119 missingHealth =
	// 100-Health), so abs(src.Health - defender.Health) IS the HP% gap directly.
	// Absolute value is intentional — the doc literal "per 5% HP diff" doesn't
	// specify direction, so the mage benefits regardless of who is ahead, which
	// fits Iconoclast's "break the work of others" theme either as press-advantage
	// or comeback. Floor via round() matches the per-N-stacks idiom used at
	// _Move.dm:116 and the Past per-10-Cripple block above. PURE_MODIFIER pre-calc
	// scaling matches the base puredmg path.
	if(src.hasMagePassive(/mage_passive/dark/Iconoclast))
		var/icon_pd = round(abs(src.Health - defender.Health) / 5)
		if(icon_pd > 0)
			if(!glob.PURE_MOD_POST_CALC)
				icon_pd *= glob.PURE_MODIFIER
			trueMult += icon_pd
	#if DEBUG_DAMAGE
	log2text("trueMult", "After Puredmg", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("trueMult", trueMult,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	var/purered = defender.HasPureReduction() ? defender.HasPureReduction() : 0
	if(!glob.PURE_MOD_POST_CALC)
		purered *= glob.PURE_MODIFIER
	if(passive_handler.Get("Aspect of Death"))
		purered*=0.75
	trueMult -= purered
	// Time Past mage passive (defender-side follow-up to Cripple-on-hit): per 10
	// Cripple stacks on the attacker, the Past mage gains 1 effective PureReduction
	// against this hit. Pairs with the Cripple-on-hit accumulation at the end of
	// newDoDamage — the mage builds Cripple on attackers via hits taken, then those
	// stacks translate to damage reduction on subsequent incoming hits from the same
	// attacker. Scaled by PURE_MODIFIER when pre-calc, matching the base purered path.
	if(defender.hasMagePassive(/mage_passive/time/Past))
		var/past_pr = round(src.Crippled / 10)
		if(past_pr > 0)
			if(!glob.PURE_MOD_POST_CALC)
				past_pr *= glob.PURE_MODIFIER
			trueMult -= past_pr
	// Space Relativity mage passive (defender side): the mage gains 0.5
	// effective PureReduction for every point of PureDamage the attacker brings.
	// Reads HasPureDamage() so the bonus tracks the same value the puredmg block
	// above used (passive_handler PureDamage plus Rage, CursedSheath, MangLevel,
	// Tarot, etc). Pairs with the attacker-side Relativity hook in the puredmg
	// section above. PURE_MODIFIER pre-calc scaling matches the base purered path.
	if(defender.hasMagePassive(/mage_passive/space/Relativity))
		var/relativity_pr = src.HasPureDamage() * 0.5
		if(relativity_pr > 0)
			if(!glob.PURE_MOD_POST_CALC)
				relativity_pr *= glob.PURE_MODIFIER
			trueMult -= relativity_pr
	// Unbroken for Makyos
	var/unbrokenVal = defender.passive_handler.Get("Unbroken")
	if(unbrokenVal)
		if(!glob.PURE_MOD_POST_CALC)
			unbrokenVal *= glob.PURE_MODIFIER
		trueMult -= unbrokenVal
		if(defender.unbreakable_tracking)
			// Cap at 40 so half never exceeds +20 DamageMult, subject to change
			defender.unbroken_absorbed = min(defender.unbroken_absorbed + (val * 0.1 * unbrokenVal), 40)
	// Inevitable
	if(unarmed || sword)
		var/inevVal = passive_handler.Get("Inevitable")
		if(inevVal)
			trueMult += 5 * inevVal
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
	if(glob.GOD_KI_AFFECTS_DAMAGE)
		trueMult += godKiModifiers(defender)
//		trueMult += maouKiModifiers(defender)
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

	if(passive_handler.Get("Undying Rage"))
		val*=0.1
	var/miraclechance = (100-defender.Health)*0.6
	if(defender.passive_handler.Get("Miracle"))
		if(defender.Health<30)
			if( prob(miraclechance))
				val=0
	if(HasEmptySeat())
		passive_handler.Increase("AlphainForce", val)
	#if DEBUG_DAMAGE
	log2text("Damage", "After TrueMult", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", val,"damageDebugs.txt", "[src.ckey]/[src.name]")
	#endif
	// Alignment-conditional damage resistance (EvilResist vs Evil attackers, GoodResist vs Good)
	if(src.IsEvil() && defender.passive_handler.Get("EvilResist"))
		val *= defender.getEvilResistValue()
	if(src.IsGood() && defender.passive_handler.Get("GoodResist"))
		val *= defender.getGoodResistValue()
	// Time Past mage passive: 25% chance to inflict 1 Cripple on the attacker when
	// the mage takes a hit. Fires only on non-zero post-mitigation damage so fully
	// blocked hits do not trigger. The doc line "per 10 Cripple on target →
	// PureReduction 1" feeds off this — the Past mage accumulates Cripples on their
	// attackers, which then translates to their own reduction against those targets.
	if(val > 0 && defender.hasMagePassive(/mage_passive/time/Past) && prob(25))
		src.AddCrippling(1, defender)
	// Dark Iconoclast mage passive: on a successful hit, the attacker gains 10%
	// of the defender's current Power as a temporary 30s buff. Doc literal "gain
	// 10% of target's current Power" reads as pure gain (defender unaffected),
	// not transfer — Iconoclast's theme is "break the work of others", not
	// drain. Per-attacker cooldown of 5s (50 deciseconds) prevents multi-hit
	// projectile spam from siphoning a target instantly: a fast caster can
	// realistically land 6 steals over the 30s buff window for ~60% of target
	// Power at peak, which scales with target strength as intended (weak
	// against weak targets, strong against strong ones). The stolen amount is
	// captured at hit time in a local var so the paired spawn-decrement removes
	// the EXACT same value regardless of any concurrent Power changes — pattern
	// matches the Session 26 Shadowbringer LifeSteal increase/decrease pair.
	// Self-damage never reaches this hook because the defender == src branch
	// returns at line 44 before any of this code runs. Power is the BP/PowerLevel
	// mob var declared at _1CodeFolder/_Variables.dm:4.
	if(val > 0 && src.hasMagePassive(/mage_passive/dark/Iconoclast) && world.time >= src.IconoclastNextSteal)
		var/stolen = round(defender.Power * 0.10)
		if(stolen > 0)
			src.Power += stolen
			src.IconoclastNextSteal = world.time + 50
			spawn(300)
				if(src)
					src.Power -= stolen
	// Vortex: percentage chance to teleport defender away on hit
	// Range scales 1:1 with chance (5 Vortex = 5% chance, 5 tiles)
	if(val > 0)
		var/vortex_val = defender.passive_handler.Get("Vortex")
		if(vortex_val && prob(vortex_val))
			var/dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			for(var/i = 1 to vortex_val)
				var/turf/nextT = get_step(defender, dir)
				if(nextT && !nextT.density)
					defender.loc = nextT
				else
					break
	if(!checkPurity(defender))
		DEBUGMSG("[defender] is too pure to hit at the end of newdodamage");
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


	if(defender.HasDeathField() && (unarmed || sword))
		var/deathFieldValue = defender.GetDeathField() * glob.FIELD_MODIFIERS // should be 0.01(?), 15 = 15% dmg takebnn reflective if they do 100
		WoundSelf(deathFieldValue * min(1/val,1))
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

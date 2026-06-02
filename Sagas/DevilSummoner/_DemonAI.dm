/mob/var/tmp/demon_makarakarn_until = 0
/mob/var/tmp/demon_tetrakarn_until = 0

/mob/Player/AI/Demon
	var/datum/demon_data/demon_data = null
	var/demon_owner_key = ""

	var/next_melee_tick   = 0
	var/next_skill_tick   = 0
	var/demon_melee_rate  = 25
	var/demon_skill_rate  = 150

	var/demon_hp = 100
	var/next_attack_multiplier = 1
	var/tmp/_outgoing_damage = FALSE  // flag: when TRUE, DoDamage uses parent convention (src=attacker)
	var/image/reflect_overlay_self = null
	var/image/reflect_overlay_owner = null

	// Summoner passive inheritance
	var/demon_summoner_pure_grant      = 0
	var/demon_summoner_brutalize_grant = 0   
	var/demon_summoner_blurring_grant  = 0   
	var/demon_summoner_hybrid_grant    = 0   
	var/demon_summoner_spirit_sword    = 0   
	var/demon_summoner_spirit_hand     = 0   
	var/demon_summoner_calloused_grant = 0   

	New()
		..()

	proc/ApplySummonerPassiveGrants()
		if(!ai_owner) return
		var/f = glob.DEMON_SUMMONER_GRANT_FACTOR
		demon_summoner_pure_grant      = ai_owner.HasPureDamage()      * f
		demon_summoner_brutalize_grant = ai_owner.GetBrutalize()       * f
		demon_summoner_blurring_grant  = ai_owner.GetBlurringStrikes() * f
		demon_summoner_hybrid_grant    = ai_owner.GetHybridStrike()    * f
		demon_summoner_spirit_sword    = ai_owner.GetSpiritSword()     * f
		demon_summoner_spirit_hand     = ai_owner.GetSpiritHand()      * f
		demon_summoner_calloused_grant = ai_owner.GetCallousedHands()  * f

	proc/RemoveSummonerPassiveGrants()
		demon_summoner_pure_grant      = 0
		demon_summoner_brutalize_grant = 0.0
		demon_summoner_blurring_grant  = 0.0
		demon_summoner_hybrid_grant    = 0.0
		demon_summoner_spirit_sword    = 0.0
		demon_summoner_spirit_hand     = 0.0
		demon_summoner_calloused_grant = 0.0

	proc/DemonInit(datum/demon_data/dd, mob/owner, datum/party_demon/pd)
		demon_data = dd
		ai_owner   = owner
		demon_owner_key = owner.ckey
		name       = dd.demon_name
		icon       = dd.demon_icon
		icon_state = dd.demon_icon_state
		ai_follow  = TRUE
		ai_focus_owner_target = TRUE
		density    = TRUE
		ai_hostility = 0  // demons never auto-aggro
		ai_alliances = list("[owner.ckey]")
		owner.ai_followers += src

		// Ensure passive_handler exists so demon passives that increment it work
		if(!passive_handler) passive_handler = new()

		// Demon's own Potential = its level (starts at base, grows via kills)
		Potential = pd.demon_potential
		var/bonus = max(0, Potential - dd.demon_lvl) * 0.2
		StrMod = max(1, round(dd.demon_str + bonus, 0.01))
		ForMod = max(1, round(dd.demon_for + bonus, 0.01))
		EndMod = max(1, round(dd.demon_end + bonus, 0.01))
		SpdMod = max(1, round(dd.demon_spd + bonus, 0.01))
		OffMod = max(1, round(dd.demon_off + bonus, 0.01))
		DefMod = max(1, round(dd.demon_def + bonus, 0.01))
		potential_power_mult = owner.potential_power_mult

		demon_melee_rate = max(8, 30 - round(dd.demon_spd * 0.7))

		// Populate active skills from party demon
		if(pd && pd.demon_skills && pd.demon_skills.len)
			active_skills = pd.demon_skills.Copy()
		else if(dd.demon_skills && dd.demon_skills.len)
			active_skills = dd.demon_skills.Copy()

		demon_base_str = StrMod
		demon_base_for = ForMod
		demon_base_end = EndMod
		demon_base_spd = SpdMod
		demon_base_def = DefMod

		// Apply DS2 passives
		ApplyDemonPassives()
		ApplySummonerPassiveGrants()

		aiGain()
		spawn() DemonLoop()

	proc/DemonLoop()
		set waitfor = FALSE
		while(src && ai_owner)
			if(!ai_owner || !ai_owner.client)
				DemonDespawn()
				return
			if(ai_owner.KO || ai_owner.Dead)
				DemonDespawn()
				return
			DemonUpdate()
			sleep(2)

	proc/DemonUpdate()
		if(!ai_owner) return

		if(ai_owner.PureRPMode)
			FollowOwner()
			return

		var/mob/target = ai_owner.Target

		if(!target || target == ai_owner || target == src)
			FollowOwner()
			return

		if(src.loc == target.loc)
			step_away(src, target, 2)
			return

		if(!(next_melee_tick - world.time > 0))
			var/d = get_dist(src, target)
			if(d > 1)
				var/old_loc = src.loc
				step_to(src, target, 1)
				// If step_to put us on target tile, undo
				if(src.loc == target.loc)
					src.loc = old_loc
			else if(d == 1)
				DemonMeleeAttack(target)
				next_melee_tick = world.time + demon_melee_rate
				if(src.loc == target.loc)
					step_away(src, target, 2)

	proc/FollowOwner()
		if(!ai_owner) return
		if(ai_owner.icon_state == "Meditate")
			icon_state = "Meditate"
			return
		if(demon_data)
			icon_state = demon_data.demon_icon_state
		if(get_dist(src, ai_owner) >= 3)
			if(ai_owner.z != src.z)
				loc = locate(ai_owner.x, ai_owner.y, ai_owner.z)
			step_to(src, ai_owner, 1)
			if(loc == ai_owner.loc) step_away(src, ai_owner)

	proc/DemonMeleeAttack(mob/target)
		if(!target) return
		if(!ai_owner || ai_owner.Target != target) return  // only attack owner's current target
		if(target == ai_owner) return
		if(target == src) return
		if(istype(target, /mob/Player) && "[ai_owner.ckey]" in target.ai_alliances) return
		if(ai_owner.party && ai_owner.party.members && (target in ai_owner.party.members)) return
		var/dmg = DemonComputeKernelDamage(target, StrMod * StrMultTotal) * next_attack_multiplier * glob.DevilSummonerDemonDamageMod
		if(next_attack_multiplier > 1)
			if(ai_owner) ai_owner << "<font color='#ffaa00'>[name]'s charged attack connects!</font>"
			next_attack_multiplier = 1
		if(dmg <= 0) return
		// Crit chance / damage from passive_handler (CriticalChance / CriticalDamage)
		var/crit_chance = 5 + DemonPassiveCritBonus()
		if(prob(crit_chance))
			dmg = dmg * DemonPassiveCritDmgMult()
		DemonDealDamage(target, TrueDamage(dmg))
		DemonHitVisual(target)
		DemonPassiveAddAilments(target)
		Bump(target)
		// Double Strike: hit twice
		if(passive_double_strike)
			spawn(2)
				if(src && target)
					DemonDealDamage(target, TrueDamage(dmg))
					DemonHitVisual(target)
					Bump(target)
		// Attack All: also hit nearby enemies
		if(passive_attack_all)
			var/aoe_dmg = dmg * 0.6
			if(aoe_dmg > 0)
				for(var/mob/m in oview(1, src))
					if(m == src || m == target) continue
					if(ai_owner && m == ai_owner) continue
					if(ai_owner && istype(m, /mob/Player) && "[ai_owner.ckey]" in m.ai_alliances) continue
					if(ai_owner && ai_owner.party && ai_owner.party.members && (m in ai_owner.party.members)) continue
					DemonDealDamage(m, TrueDamage(aoe_dmg))
					DemonHitVisual(m)
					DemonPassiveAddAilments(m)

	proc/DemonDespawn()
		DemonClearReflect()
		RemoveDemonPassives()
		RemoveSummonerPassiveGrants()
		if(ai_owner)
			if(ai_owner.SagaLevel >= 4)
				ai_owner.RemoveDemonRacialPassive()
			ai_owner.ClearDemonSkillHUD()
			ai_owner.ai_followers -= src
			ai_owner.demon_active = null
			ai_owner.demon_active_name = ""
			ai_owner << "<b>[name] has been defeated and returned.</b> Meditate to restore them."
		del(src)

	proc/DemonComputeKernelDamage(mob/target, atk_val)
		if(!target || !isnum(atk_val) || atk_val <= 0) return 0
		var/my_power = max(1, Potential)
		var/target_power = 1
		if(isnum(target.Power) && target.Power > 0)
			target_power = target.Power
		else if(isnum(target.Potential) && target.Potential > 0)
			target_power = target.Potential
		var/powerDif = my_power / target_power
		if(glob.CLAMP_POWER)
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
		var/atk = max(0.01, atk_val)
		var/def = max(0.01, target.getEndStat(1))
		if(demon_summoner_spirit_sword > 0)    atk += ForMod * ForMultTotal * demon_summoner_spirit_sword
		if(demon_summoner_spirit_hand > 0)     atk += ForMod * ForMultTotal * demon_summoner_spirit_hand / 4
		if(demon_summoner_calloused_grant > 0) atk += EndMod * EndMultTotal * demon_summoner_calloused_grant
		if(demon_summoner_brutalize_grant > 0) def = max(0.01, def * (1 - demon_summoner_brutalize_grant))
		return (powerDif ** glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT + glob.MELEE_EFFECTIVENESS) ** -(def ** glob.DMG_END_EXPONENT / atk ** glob.DMG_STR_EXPONENT)

	// Visual feedback for demon attacks
	proc/DemonHitVisual(mob/target)
		if(!target) return
		Hit_Effect(target, 1, rand(-8,8), rand(-8,8))
		flick("KB", target)

	// Outgoing damage wrapper
	proc/DemonDealDamage(mob/target, val)
		if(!isnum(val) || val <= 0) return
		if(demon_summoner_blurring_grant > 0)
			val *= clamp(sqrt(1 + SpdMod * demon_summoner_blurring_grant / 15), 1, 3)
		if(demon_summoner_hybrid_grant > 0)
			val *= clamp(sqrt(1 + ForMod * demon_summoner_hybrid_grant / 15), 1, 3)
		val += demon_summoner_pure_grant
		// Killing blow: finish off a KO'd NPC
		if(target && target.KO && istype(target, /mob/Player/AI) && !istype(target, /mob/Player/AI/Demon) && !target.client)
			var/mob/Player/AI/ai_target = target
			if(ai_target.ai_owner) return
			target.Death(ai_owner, null)
			if(ai_owner && Potential < ai_owner.Potential)
				Potential += 1
				var/datum/party_demon/kpd = DemonGetPartyDemon()
				if(kpd) kpd.demon_potential = Potential
				if(ai_owner.client)
					ai_owner << "<font color='#c8a8ff'>[name]'s potential grows from the kill! ([Potential]/[ai_owner.Potential])</font>"
			return
		if(istype(target, /mob/Player/AI/Demon))
			// Demon-vs-demon
			target.DoDamage(src, val)
		else
			// Non-demon target: bypass override
			_outgoing_damage = TRUE
			src.DoDamage(target, val)
			_outgoing_damage = FALSE  // safety reset
		// Demon LifeSteal
		if(passive_handler && val > 0)
			var/ls = passive_handler.Get("LifeSteal")
			if(ls > 0)
				var/heal = max(1, round(val * ls / 100))
				demon_hp = min(100, demon_hp + heal)
				var/datum/party_demon/pd = DemonGetPartyDemon()
				if(pd) pd.current_hp = demon_hp

	// Core incoming-damage handler
	proc/DemonTakeDamage(var/raw_val, mob/attacker)
		if(ai_owner && ai_owner.PureRPMode) return
		if(ai_owner && istype(attacker, /mob))
			if(attacker == ai_owner) return
			if(ai_owner.party && ai_owner.party.members && (attacker in ai_owner.party.members)) return
		var/raw_dmg = raw_val * glob.DevilSummonerDemonDamageTakenMod
		if(raw_dmg <= 0) return
		var/resist = DemonGetResistMult("Phys")
		if(resist == 0)
			if(ai_owner) ai_owner << "<font color='#88ddff'>[name] nullified the attack!</font>"
			return
		// Repel: take 25% damage, reflect 25% back to attacker
		if(DemonHasRepel("Phys"))
			var/repel_back = raw_dmg * 0.25
			raw_dmg = raw_dmg * 0.25
			if(istype(attacker, /mob))
				DemonDealDamage(attacker, TrueDamage(repel_back))
			if(ai_owner) ai_owner << "<font color='#aaccff'>[name] repels part of the attack!</font>"
		// Drain: heal 25% of incoming damage, take 25%
		else if(DemonHasDrain("Phys"))
			var/heal_amt = raw_dmg * 0.25
			raw_dmg = raw_dmg * 0.25
			demon_hp = min(100, demon_hp + heal_amt)
			if(ai_owner) ai_owner << "<font color='#88ffaa'>[name] drains [heal_amt] HP from the attack!</font>"
		// Apply standard resist multiplier
		raw_dmg = raw_dmg * resist
		// LifeGeneration for demons
		if(passive_handler)
			var/lg = passive_handler.Get("LifeGeneration")
			if(lg > 0)
				var/lg_heal = lg / glob.LIFE_GEN_DIVISOR * raw_dmg
				demon_hp = min(100, demon_hp + lg_heal)
		demon_hp = max(0, demon_hp - raw_dmg)
		if(!ai_owner) return
		for(var/datum/party_demon/pd in ai_owner.demon_party)
			if(pd.demon_name == name)
				pd.current_hp = demon_hp
				if(demon_hp <= 0)
					DemonDespawn()
				return

	LoseHealth(var/val)
		if(!isnum(val) || val <= 0) return
		DemonTakeDamage(val, null)

	DoDamage(mob/other, damage)
		if(_outgoing_damage)
			_outgoing_damage = FALSE
			..(other, damage)
			return
		if(isnum(damage) && damage > 0)
			DemonTakeDamage(damage, other)

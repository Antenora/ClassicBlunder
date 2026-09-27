/datum/maim
	var/part
	var/tier = 0
	var/magnitude = 1
	var/treating = 0
	var/treat_quality = 0
	var/last_settle = 0
	var/creep = 0

/datum/maim/New(p, t)
	..()
	if(p)
		part = p
	if(t)
		tier = t

mob/var/list/maims
mob/var/list/prosthetic_parts
mob/var/tmp/list/maim_fx
mob/var/tmp/maim_fx_at = 0
mob/var/tmp/maim_suppressed_until = 0
mob/var/tmp/maim_creep_mult = 1

var/maim_settle_boot = MaimSettleBoot()

proc/MaimSettleBoot()
	spawn(MAIM_SETTLE_TICKS)
		MaimSettleLoop()
	return 1

proc/MaimSettleLoop()
	set waitfor = 0
	set background = 1
	while(1)
		for(var/mob/Players/P in players)
			if(P.maims)
				P.MaimSettle()
		sleep(MAIM_SETTLE_TICKS)

proc/MaimHealSeconds(quality)
	return MAIM_HEAL_SECONDS_PER_TIER / MAIM_QUALITY_HEAL_MULT[QualityClamp(quality)]

mob/proc/MaimGet(part)
	if(!maims)
		return null
	for(var/datum/maim/M in maims)
		if(M.part == part)
			return M
	return null

mob/proc/MaimTierOf(part)
	var/datum/maim/M = MaimGet(part)
	return M ? M.tier : 0

mob/proc/MaimHighestTier()
	. = 0
	if(!maims)
		return
	for(var/datum/maim/M in maims)
		if(M.tier > .)
			. = M.tier

mob/proc/MaimWorst()
	var/datum/maim/best
	for(var/p in MAIM_PARTS)
		var/datum/maim/M = MaimGet(p)
		if(M && (!best || M.tier > best.tier))
			best = M
	return best

mob/proc/MaimSecondsToPeel(part)
	var/datum/maim/M = MaimGet(part)
	if(!M || !M.treating)
		return -1
	return max(0, M.magnitude * MaimHealSeconds(M.treat_quality) - (world.realtime - M.last_settle) / 10)

mob/proc/MaimRebuild()
	if(maims && !maims.len)
		maims = null
	Maimed = MaimHighestTier()
	maim_fx_at = world.time
	if(!maims)
		maim_fx = null
		return
	var/list/sum = list()
	for(var/datum/maim/M in maims)
		var/list/rows = MAIM_EFFECTS[M.part]
		if(!rows)
			continue
		for(var/t in 1 to min(M.tier, rows.len))
			var/w = (t == M.tier) ? M.magnitude : 1
			var/list/fx = rows[t]
			for(var/k in fx)
				sum[k] += fx[k] * w
	var/list/out = list()
	for(var/k in sum)
		if(k in MAIM_FLAT_KINDS)
			out[k] = sum[k]
		else
			out[k] = max(1 + sum[k], MAIM_MULT_FLOOR)
	maim_fx = out

mob/MaimMult(kind)
	if(!maims)
		return 1
	if(maim_suppressed_until > world.time)
		return 1
	if(!maim_fx || world.time >= maim_fx_at + MAIM_SETTLE_TICKS)
		MaimSettle()
	if(!maim_fx)
		return 1
	var/v = maim_fx[kind]
	return isnull(v) ? 1 : v

mob/MaimFlat(kind)
	if(!maims)
		return 0
	if(maim_suppressed_until > world.time)
		return 0
	if(!maim_fx || world.time >= maim_fx_at + MAIM_SETTLE_TICKS)
		MaimSettle()
	if(!maim_fx)
		return 0
	var/v = maim_fx[kind]
	return isnull(v) ? 0 : v

mob/proc/MaimSanitize()
	if(!islist(maims))
		maims = null
		return
	var/list/seen = list()
	for(var/x in maims.Copy())
		var/datum/maim/M = x
		if(!istype(M) || !(M.part in MAIM_PARTS) || (M.part in seen) || !isnum(M.tier) || M.tier < 1)
			maims -= x
			continue
		seen += M.part
		M.tier = min(round(M.tier), MAIM_TIER_MAX)
		if(!isnum(M.magnitude) || M.magnitude <= 0 || M.magnitude > 1)
			M.magnitude = 1
		if(!isnum(M.creep) || M.creep < 0)
			M.creep = 0
		if(!isnum(M.last_settle))
			M.last_settle = world.realtime
	if(!maims.len)
		maims = null

mob/MaimSettle()
	MaimSanitize()
	if(maims)
		var/now = world.realtime
		for(var/datum/maim/M in maims.Copy())
			if(M.treating)
				var/elapsed = (now - M.last_settle) / 10
				if(elapsed > 0)
					M.magnitude -= elapsed / MaimHealSeconds(M.treat_quality)
					while(M.magnitude <= 0 && M.tier > 0)
						M.tier--
						M.magnitude += 1
						if(M.tier > 0)
							src << "Your [lowertext(M.part)] maim has eased to tier [M.tier]."
					if(M.tier <= 0)
						maims -= M
						src << "Your [lowertext(M.part)] maim has fully healed."
						continue
			M.last_settle = now
	MaimRebuild()

mob/MaimApply(part, tiers = 1)
	if(!(part in MAIM_PARTS))
		return 0
	tiers = round(tiers)
	if(tiers < 1)
		return MaimTierOf(part)
	MaimSettle()
	var/datum/maim/M = MaimGet(part)
	if(!M)
		M = new(part, 0)
		if(!maims)
			maims = list()
		maims += M
	M.tier = min(M.tier + tiers, MAIM_TIER_MAX)
	M.magnitude = 1
	M.treating = 0
	M.creep = 0
	M.last_settle = world.realtime
	MaimRebuild()
	return M.tier

mob/MaimPeel(part, tiers = 1)
	if(!maims)
		return 0
	MaimSettle()
	var/n = 0
	for(var/i in 1 to round(tiers))
		var/datum/maim/M = part ? MaimGet(part) : MaimWorst()
		if(!M)
			break
		M.tier--
		M.magnitude = 1
		M.creep = 0
		n++
		if(M.tier <= 0)
			maims -= M
	MaimRebuild()
	return n

mob/MaimClearAll()
	maims = null
	MaimRebuild()

mob/proc/MaimSetTier(part, tier)
	if(!(part in MAIM_PARTS))
		return 0
	tier = clamp(round(tier), 0, MAIM_TIER_MAX)
	MaimPeel(part, MAIM_TIER_MAX)
	if(tier > 0)
		MaimApply(part, tier)
	return MaimTierOf(part)

mob/proc/MaimSetFromLegacy(n, part)
	n = round(n)
	if(n <= 0)
		MaimClearAll()
		return 0
	n = min(n, MAIM_TIER_MAX)
	MaimSettle()
	while(MaimHighestTier() > n)
		if(!MaimPeel(null, 1))
			break
	if(MaimHighestTier() < n)
		var/target = part
		if(!(target in MAIM_PARTS))
			var/datum/maim/W = MaimWorst()
			target = W ? W.part : "Torso"
		MaimApply(target, n - MaimTierOf(target))
	return MaimHighestTier()

mob/proc/MaimTreat(part, quality)
	MaimSettle()
	var/datum/maim/M = MaimGet(part)
	if(!M)
		return 0
	M.treating = 1
	M.treat_quality = QualityClamp(quality)
	M.last_settle = world.realtime
	MaimRebuild()
	return 1

mob/MaimPickPart(mob/asker, title)
	if(!asker)
		return null
	return Ask(asker, "Which part of [src]?", title, null, "pick", MAIM_PARTS.Copy(), 1)

mob/MaimCreepHit(mob/attacker, dmg)
	if(!maims || !ismob(attacker) || attacker == src || dmg <= 0)
		return
	if(!FightingSeriously(attacker, src))
		return
	var/add = MAIM_CREEP_PER_HIT
	if(maim_suppressed_until > world.time)
		add *= max(1, maim_creep_mult)
	var/changed = 0
	for(var/datum/maim/M in maims)
		M.creep += add
		if(M.creep < MAIM_CREEP_ESCALATE - MAIM_CREEP_EPSILON)
			continue
		M.creep = 0
		if(M.treating)
			M.treating = 0
			src << "Fighting on has undone the treatment on your [lowertext(M.part)] maim."
		else if(M.tier < MAIM_TIER_MAX)
			M.tier++
			if(MAIM_ESCALATE_RESETS_MAGNITUDE)
				M.magnitude = 1
			changed = 1
			src << "Your [lowertext(M.part)] maim worsens to tier [M.tier]."
	if(changed)
		MaimRebuild()

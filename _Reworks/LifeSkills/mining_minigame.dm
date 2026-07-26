// Three timed strikes per dig. Under-ranked veins swing brutally fast and can yield nothing

mob/proc/StartMining(obj/LifeSkills/OreNode/N)
	if(!N || N.depleted || !client) return
	if(KO || Dead) return
	if(Using)
		src << "You're in the middle of something."
		return
	if(client.life_minigame_sink) return
	if(N.mining_by && N.mining_by != src)
		src << "Someone's already working that vein."
		return
	var/datum/ore_def/d = LifeOreDef(N.ore_id)
	if(!d) return
	if(!LIFE_MINE_GATE_OK(LifeRank("Mining"), d.difficulty))
		src << "<font color=#ff6464>This vein is beyond you. (Mining rank [d.difficulty - 1] required)</font>"
		return
	if(!UseLifeStamina(LIFE_COST_GATHER)) return
	N.mining_by = src
	Using = 1
	var/rank = LifeRank("Mining")
	var/obj/Items/LifeTool/tool = GetBestLifeTool(src, "Pick")
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * d.difficulty + LIFE_SPEED_PER_UNDER * max(0, d.difficulty - rank) - LIFE_SPEED_PER_OVER * max(0, rank - d.difficulty), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	if(tool) speed *= max(0.7, 1 - tool.SweetSpotBonus)   // a good pick steadies the swing
	var/list/opts = list("speed_mult" = speed, "target" = N)
	var/total = 0
	var/finished = 0
	var/aborted = 0
	for(var/i = 1 to LIFE_MINING_STRIKES)
		var/p = RunLifeMinigame(src, "timing_bar", d.difficulty, opts)
		if(p < 0)
			aborted = 1
			break
		total += p
		finished++
	Using = 0
	if(N) N.mining_by = null
	if(aborted || !finished)
		src << "You couldn't finish working the vein."
		return
	MiningPayout(N, d, total / LIFE_MINING_STRIKES, tool, rank)

mob/proc/MiningPayout(obj/LifeSkills/OreNode/N, datum/ore_def/d, perf, obj/Items/LifeTool/tool, rank)
	if(!N || !d) return
	if(d.difficulty > rank)
		if(perf < LIFE_PERF_MIN)
			src << "<font color=#ff6464>The [N.name] resists your unskilled strikes. Nothing comes loose.</font>"
			AddLifeXP("Mining", LifeGatherXP("Mining", d.tier) * 0.5, LIFE_PERF_MIN)
			if(tool) tool.LifeToolWear(src)
			return
	else
		perf = max(perf, LIFE_PERF_MIN)
	perf = min(perf, LIFE_PERF_MAX)

	var/q = QUAL_NORMAL
	if(perf >= 1.4) q++
	if(perf < 0.7) q--
	if(prob(2 * rank)) q++
	if(tool && prob(tool.QualityBonus)) q++
	q = min(q, LifeQualityCap(rank))
	if(q >= QUAL_LEGENDARY)
		// legendary never comes easy, even at rank 10
		var/legchance = LIFE_GATHER_LEG_BASE + max(0, rank - 8)
		if(perf >= 1.4) legchance += 1
		if(!prob(legchance)) q = QUAL_EPIC
	q = QualityClamp(q)

	var/amt = max(1, round(LIFE_MINING_BASE_YIELD * perf + (tool ? tool.YieldBonus : 0)))
	if(d.kind == "gem")
		var/shatter_chance = LifeGemShatterChance(rank)
		var/intact = 0
		var/shards = 0
		for(var/i = 1 to amt)
			if(prob(shatter_chance)) shards++
			else intact++
		if(intact)
			GiveMaterial(src, d.yield_type, intact, q)
			src << "<font color=#78eb78>You pry loose [intact]x [QualityName(q)] [d.name] intact.</font>"
			LifeLogFind("Mining", d.name)
		if(shards)
			GiveMaterial(src, /obj/Items/Material/Gem/shards, shards, QUAL_NORMAL)
			src << "<font color=#ff9a9a>[shards]x [d.name] shatter[shards == 1 ? "s" : ""] under your pick - the shards are still worth something.</font>"
			LifeLogFind("Mining", "Gem Shards")
	else
		GiveMaterial(src, d.yield_type, amt, q)
		src << "<font color=#78eb78>You break loose [amt]x [QualityName(q)] [d.name].</font>"
		LifeLogFind("Mining", d.name)

	// gems are precious. capstone guarantees one, otherwise it's a long shot
	var/gem_id
	var/gem_sure = 0
	if(LifeGemArmed && rank >= LIFE_MAX_RANK && LifeCapstoneGemDay != DaysOfWipe())
		gem_id = LifeRandomGemFor(max(d.tier, 3))
		gem_sure = 1   // the capstone
		LifeGemArmed = 0
		LifeCapstoneGemDay = DaysOfWipe()
		src << "<b>Prospector's Instinct - you feel exactly where to strike.</b>"
	else if(d.kind != "gem" && prob(LIFE_GEM_CHANCE_PER_TIER * d.tier))
		gem_id = LifeRandomGemFor(d.tier)
	if(gem_id)
		var/datum/ore_def/g = LifeOreDef(gem_id)
		if(g)
			if(!gem_sure && prob(LifeGemShatterChance(rank)))
				GiveMaterial(src, /obj/Items/Material/Gem/shards, 1, QUAL_NORMAL)
				src << "<font color=#ff9a9a>A [g.name] tumbles out - and shatters in your grip. The shards are still worth something.</font>"
				LifeLogFind("Mining", "Gem Shards")
			else
				GiveMaterial(src, g.yield_type, 1, min(q, LifeQualityCap(rank)))
				src << "<font color=#b46bff>A [g.name] tumbles out of the rock!</font>"
				LifeLogFind("Mining", g.name)

	if(tool) tool.LifeToolWear(src)
	AddLifeXP("Mining", LifeGatherXP("Mining", d.tier), perf)
	LifeOppRoll("Mining", d.tier, d.yield_type, q)
	if(prob(3 + round(rank / 3)))
		var/obj/Items/Geode/geo = new
		geo.tier = d.tier
		GiveOrDrop(geo)
		src << "<font color=#b46bff><b>A geode rolls free of the rubble!</b> Click it in your pack to crack it open.</font>"
	N.charges--
	if(N.charges <= 0)
		src << "The [N.name] is spent."
		N.Deplete()
	else
		N.UpdateStage()

// rank steadies the extraction: 59% shatter at rank 1 down to 5% at rank 10
proc/LifeGemShatterChance(rank)
	return max(5, 65 - rank * 6)

proc/LifeRandomOreFor(tier)
	InitLifeOreDefs()
	var/list/pool = list()
	for(var/id in LifeOreDefs)
		var/datum/ore_def/d = LifeOreDefs[id]
		if(d.kind == "ore" && d.tier <= tier)
			pool += id
	return pool.len ? pick(pool) : null

proc/LifeRandomGemFor(tier)
	InitLifeOreDefs()
	var/list/pool = list()
	for(var/id in LifeOreDefs)
		var/datum/ore_def/d = LifeOreDefs[id]
		if(d.kind == "gem" && d.tier <= tier + 1)
			pool += id
	return pool.len ? pick(pool) : null

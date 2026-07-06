/datum/lifeskill
	var/id = ""
	var/rank = 0
	var/xp = 0
	var/list/collection_log = list()

	proc/Title()
		if(rank < 1) return "Unranked"
		return LIFE_RANK_TITLES[rank]

	proc/NextXP()
		if(rank >= LIFE_MAX_RANK) return -1
		return LIFE_RANK_XP[rank + 1]

	proc/NextRPP()
		if(rank >= LIFE_MAX_RANK) return -1
		return LIFE_RANK_RPP[rank + 1]

	proc/CanRankUp(mob/M)
		if(rank >= LIFE_MAX_RANK) return 0
		if(xp < NextXP()) return 0
		if(M.GetRPPSpendable() < NextRPP()) return 0
		return 1

	proc/TryRankUp(mob/M)
		if(rank >= LIFE_MAX_RANK)
			M << "You have mastered [id]."
			return 0
		if(xp < NextXP())
			M << "You need [Commas(NextXP() - xp)] more [id] XP to rank up."
			return 0
		if(!M.SpendRPP(NextRPP(), "[id] Rank [rank + 1]", Training = 0))
			return 0
		rank++
		M << "<b>[id] is now Rank [rank] - [Title()]!</b>"
		M.GrantLifeRankPerks(id, rank)
		return 1

/lifeskillTracking
	var/list/skills = list()

mob/var/lifeskillTracking/lifeskills = new()

mob/proc/GetLifeSkill(id)
	if(!lifeskills) lifeskills = new()
	if(!lifeskills.skills) lifeskills.skills = list()
	var/datum/lifeskill/S = lifeskills.skills[id]
	if(!S)
		S = new
		S.id = id
		lifeskills.skills[id] = S
	return S

mob/proc/LifeRank(id)
	var/datum/lifeskill/S = GetLifeSkill(id)
	return S.rank

// content tiers 1..5 unlock every 2 ranks
proc/LifeTierCap(rank)
	return clamp(-round(-max(rank, 1) / 2), 1, 5)

proc/LifeQualityCap(rank)
	if(rank < 1) return QUAL_NORMAL
	return LIFE_QCAP_BY_RANK[rank]

mob/proc/AddLifeXP(skillid, base, perf = 1)
	var/datum/lifeskill/S = GetLifeSkill(skillid)
	perf = clamp(perf, LIFE_PERF_MIN, LIFE_PERF_MAX)
	var/gain = round(base * perf)
	if(gain <= 0) return 0
	var/old = S.xp
	S.xp = min(S.xp + gain, LIFE_RANK_XP[LIFE_MAX_RANK])
	if(S.xp == old) return 0
	src << "<font color=#8be9ff>+[S.xp - old] [skillid] XP ([Commas(S.xp)]/[S.rank < LIFE_MAX_RANK ? Commas(S.NextXP()) : "MAX"])</font>"
	if(S.rank < LIFE_MAX_RANK && old < S.NextXP() && S.xp >= S.NextXP())
		src << "<b>[skillid] rank up available! ([S.NextRPP()] RPP)</b>"
	if(client) client.RefreshLifeSkillsPage()
	return S.xp - old

// tier-capped XP bases: over-tier content pays as your cap, not its own tier
mob/proc/LifeGatherXP(skillid, tier)
	return LIFE_XP_GATHER_BASE * min(tier, LifeTierCap(LifeRank(skillid)))

mob/proc/LifeCraftXP(skillid, tier)
	return LIFE_XP_CRAFT_BASE * min(tier, LifeTierCap(LifeRank(skillid)))

// old ForgingUnlocked 1..5 scale, now driven by Smithing rank
mob/proc/SmithingLevel()
	return min(5, -round(-LifeRank("Smithing") / 2))

mob/proc/LifeLogFind(skillid, material_name)
	var/datum/lifeskill/S = GetLifeSkill(skillid)
	if(!S.collection_log) S.collection_log = list()
	if(S.collection_log[material_name])
		S.collection_log[material_name]++
		return 0
	S.collection_log[material_name] = 1
	src << "<font color=#ffd86b>First find: [material_name] added to your [skillid] log.</font>"
	return 1

mob/proc/GrantLifeRankPerks(skillid, rank)
	switch(skillid)
		if("Smithing")
			if(rank >= 2 && !locate(/obj/Skills/Utility/Smelt, src))
				AddSkill(new/obj/Skills/Utility/Smelt)
				src << "You learn how to smelt items down for money."
			if(rank >= 2 && !locate(/obj/Skills/Utility/Copy_Key, src))
				AddSkill(new/obj/Skills/Utility/Copy_Key)
				src << "You learn how to make identical copies of keys!"
			if(rank >= 3 && !locate(/obj/Skills/Utility/Reforge, src))
				AddSkill(new/obj/Skills/Utility/Reforge)
				src << "You learn how to reforge weapons, armor, and staves!"
			if(rank == 5)
				src << "You can now ascend weapons, staves, and armor at an anvil."
			if(rank >= 10)
				src << "<b>Master Smith: everything you forge comes out [round((LIFE_CAPSTONE_SMITH_MULT - 1) * 100)]% stronger.</b>"
		if("Mining")
			if(rank >= 10)
				src << "<b>Prospector's Instinct: once a day, your next mining strike guarantees a gem. Arm it from the Life Skills menu.</b>"

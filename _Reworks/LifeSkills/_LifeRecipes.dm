#define LIFE_QBAND_NORMAL 55
#define LIFE_QBAND_GOOD 105
#define LIFE_QBAND_EPIC 145
#define LIFE_QBAND_LEGENDARY 195
#define LIFE_QROLL_SPREAD 15
#define LIFE_CRAFT_FAIL_XP 0.25
#define LIFE_CRAFT_TIER_P 4
#define LIFE_CRAFT_TIER_P_CAP 8

/datum/life_matfamily
	var/root
	var/category
	var/sell_skill

var/LifeMatFamiliesDone = 0

proc/RegisterLifeMatFamilies()
	if(LifeMatFamiliesDone) return
	if(!LifeMatRegistry.len)
		RegisterLifeMaterials()
		if(LifeMatFamiliesDone) return
	LifeMatFamiliesDone = 1
	for(var/T in typesof(/datum/life_matfamily) - /datum/life_matfamily)
		var/datum/life_matfamily/F = new T
		if(!F.root || !F.category)
			del F
			continue
		for(var/M in typesof(F.root))
			LifeMatReg(M, F.category)
			if(!F.sell_skill) continue
			var/mc = LifeMatClassByType[M]
			if(!mc) continue
			var/datum/matdef/d = LifeMatRegistry[mc]
			if(d) d.sell_skill = F.sell_skill
		if(!(F.category in LifeMatCategories)) LifeMatCategories += F.category
		if(F.sell_skill && !LIFE_SELL_SKILL[F.category]) LIFE_SELL_SKILL[F.category] = F.sell_skill
		del F

/datum/life_tagset
	var/list/tags

var/list/LifeMatTagTable = list()
var/LifeMatTagsDone = 0

proc/RegisterLifeMatTags()
	if(LifeMatTagsDone) return
	LifeMatTagsDone = 1
	for(var/T in typesof(/datum/life_tagset) - /datum/life_tagset)
		var/datum/life_tagset/S = new T
		if(S.tags)
			for(var/mc in S.tags)
				var/list/add = S.tags[mc]
				if(!islist(add)) add = list("[add]")
				var/list/cur = LifeMatTagTable[mc]
				if(!cur)
					cur = list()
					LifeMatTagTable[mc] = cur
				for(var/t in add)
					if(!(t in cur)) cur += t
		del S

proc/LifeMatHasTag(matclass, tag)
	if(!matclass || !tag) return 0
	RegisterLifeMatTags()
	var/list/cur = LifeMatTagTable[matclass]
	return (cur && (tag in cur)) ? 1 : 0

var/list/LifeMatTierCache = list()

proc/LifeMatTier(matclass)
	if(!matclass) return 1
	if(LifeMatTierCache[matclass]) return LifeMatTierCache[matclass]
	var/datum/matdef/d = LifeMatDef(matclass)
	var/t = 1
	if(d && d.mtype)
		var/obj/Items/Material/m = new d.mtype
		if("tier" in m.vars) t = m.vars["tier"]
		del m
	else
		return 1
	t = clamp(round(t), 1, 5)
	LifeMatTierCache[matclass] = t
	return t

/datum/craft_slotreq
	var/name = "Material"
	var/amount = 1
	var/matclass
	var/category
	var/mat_tag
	var/min_tier = 1

	proc/Accepts(matclass)
		if(!matclass) return 0
		if(min_tier > 1 && LifeMatTier(matclass) < min_tier) return 0
		if(src.matclass) return (matclass == src.matclass) ? 1 : 0
		if(category)
			var/datum/matdef/d = LifeMatDef(matclass)
			return (d && d.category == category) ? 1 : 0
		if(mat_tag) return LifeMatHasTag(matclass, mat_tag)
		return 0

	proc/Describe()
		var/what
		if(matclass) what = LifeMatName(matclass)
		else if(category) what = "any [category]"
		else if(mat_tag) what = "any [mat_tag]"
		else what = "material"
		return "[amount]x [what][min_tier > 1 ? " (tier [min_tier]+)" : ""]"

/datum/craft_recipe/lifecraft
	var/id = ""
	var/skill = "Cooking"
	var/label = ""
	var/tier = 1
	var/rank_req = 1
	var/station
	var/ls_cost = LIFE_COST_CRAFT
	var/money_cost = 0
	var/result_count = 1
	var/diff_bump = 0
	var/tool_kind
	var/knowledge_req
	var/list/slotspec
	var/list/stages
	var/list/slots
	var/field_craft = 0

	proc/FieldCraft(mob/M)
		return 0

	proc/BuildSlots()
		slots = list()
		if(!slotspec) return
		for(var/i = 1 to slotspec.len)
			var/list/row = slotspec[i]
			if(!islist(row) || row.len < 3) continue
			var/datum/craft_slotreq/S = new
			S.name = "[row[1]]"
			S.amount = max(1, row[2])
			S.min_tier = (row.len >= 4) ? max(1, row[4]) : 1
			var/sel = "[row[3]]"
			if(findtext(sel, "mat:") == 1) S.matclass = copytext(sel, 5)
			else if(findtext(sel, "cat:") == 1) S.category = copytext(sel, 5)
			else if(findtext(sel, "tag:") == 1) S.mat_tag = copytext(sel, 5)
			else S.matclass = sel
			slots += S

	proc/Difficulty()
		return clamp(tier * 2 - 1 + diff_bump, 1, 10)

	proc/CraftCost()
		return money_cost ? round(money_cost * glob.progress.EconomyCost) : 0

	proc/Locked(mob/M)
		if(!M) return "no one to make it"
		if(M.LifeRank(skill) < rank_req) return "[skill] rank [rank_req]"
		if(knowledge_req)
			if(!M.knowledgeTracker || !(knowledge_req in M.knowledgeTracker.learnedKnowledge))
				return "needs [knowledge_req]"
		return null

	proc/SlotOptions(mob/M, i)
		. = list()
		if(!M || !slots || i < 1 || i > slots.len) return
		var/datum/craft_slotreq/S = slots[i]
		RegisterLifeMatFamilies()
		for(var/mc in LifeMatRegistry)
			if(!S.Accepts(mc)) continue
			for(var/q = QUAL_POOR to QUAL_LEGENDARY)
				var/n = M.MatLogCountQ(mc, q)
				if(n <= 0) continue
				. += list(list(mc, q, n))
		. = LifeSortMatOptions(.)

		if(istype(src, /datum/craft_recipe/lifecraft/tech/wearable/mech) && S.name == "Core")
			RegisterMechIntrinsicParts()

			for(var/part_id in M.MechIntrinsicUnlocks)
				var/value = "intrinsic_core:[part_id]"
				if(MechCraftIntrinsicError(M, src, i, value)) continue

				. += list(list(value, QUAL_NORMAL, S.amount))

	proc/AutoPicks(mob/M)
		. = list()
		if(!slots) return
		var/list/used = list()
		for(var/i = 1 to slots.len)
			var/datum/craft_slotreq/S = slots[i]
			var/list/opts = SlotOptions(M, i)
			var/list/got = null
			for(var/j = 1 to opts.len)
				var/list/o = opts[j]
				var/key = "[o[1]]|[o[2]]"
				var/claimed = used[key] ? used[key] : 0
				if(o[3] - claimed < S.amount) continue
				got = list(o[1], o[2])
				used[key] = claimed + S.amount
				break
			. += list(got)

	proc/Missing(mob/M, list/picks)
		. = list()
		if(!M) return
		var/reason = Locked(M)
		if(reason) . += reason
		var/list/used = list()
		if(slots)
			for(var/i = 1 to slots.len)
				var/datum/craft_slotreq/S = slots[i]
				var/mc = null
				var/q = QUAL_POOR
				if(picks && i <= picks.len && islist(picks[i]))
					var/list/p = picks[i]
					if(p.len >= 2)
						mc = p[1]
						q = QualityClamp(p[2])
				if(!mc)
					. += "pick [S.name]"
					continue
				if(MechCraftIntrinsicID(mc))
					var/error = MechCraftIntrinsicError(M, src, i, mc)
					if(error) . += error
					continue
				if(!S.Accepts(mc))
					. += "[LifeMatName(mc)] does not fit [S.name]"
					continue
				var/key = "[mc]|[q]"
				var/claimed = used[key] ? used[key] : 0
				if(M.MatLogCountQ(mc, q) - claimed < S.amount)
					. += "[S.amount]x [QualityName(q)] [LifeMatName(mc)]"
					continue
				used[key] = claimed + S.amount
		var/cost = CraftCost()
		if(cost && !M.HasMoney(cost)) . += "[Commas(cost)] money"
		if(ls_cost)
			M.CheckLifeStaminaRefill()
			if(M.LifeStamina < ls_cost) . += "[ls_cost] Life Stamina"

	proc/Summary(mob/M)
		return ""

	proc/Project(mob/M, list/picks)
		. = list()
		if(!M) return
		var/rank = M.LifeRank(skill)
		var/lo = LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)]
		var/hi = max(lo, LifeQualityCap(rank))
		. += "Quality: [lo == hi ? QualityName(lo) : "[QualityName(lo)] to [QualityName(hi)]"]"
		. += "Makes: [result_count]x [label]"
		. += "Difficulty: [Difficulty()]/10"
		var/cost = CraftCost()
		if(cost) . += "Cost: [Commas(cost)]"
		if(ls_cost) . += "Life Stamina: [ls_cost]"
		var/x = M.LifeCraftSubExtra()
		if(x) . += x

	proc/StageList(mob/M)
		return stages

	proc/MakeResult(mob/M, q, perf, list/picks)
		if(!M || !result_type) return null
		. = null
		var/qq = QualityClamp(q)
		for(var/k = 1 to max(1, result_count))
			var/obj/Items/made = new result_type
			made.CraftQuality = qq
			made.CreatorKey = M.ckey
			made.CreatorSignature = M.EnergySignature
			made.CreatorName = "[M.name]"
			var/mid = made.metal_id
			M.GiveOrDrop(made)
			if(made)
				. = made
				continue
			for(var/obj/Items/e in M)
				if(e.type == result_type && e.CraftQuality == qq && e.metal_id == mid)
					. = e
					break

proc/LifeSortMatOptions(list/L)
	var/list/out = list()
	if(!L) return out
	for(var/i = 1 to L.len)
		var/list/row = L[i]
		var/rt = LifeMatTier(row[1])
		var/placed = 0
		for(var/j = 1 to out.len)
			var/list/o = out[j]
			var/ot = LifeMatTier(o[1])
			if(rt < ot || (rt == ot && row[2] < o[2]))
				out.Insert(j, list(row))
				placed = 1
				break
		if(!placed) out += list(row)
	return out

var/list/LifeCraftById = list()
var/list/LifeCraftBySkill = list()
var/LifeCraftsDone = 0

proc/LifeSortCrafts(list/L)
	var/list/out = list()
	for(var/datum/craft_recipe/lifecraft/R in L)
		var/placed = 0
		for(var/j = 1 to out.len)
			var/datum/craft_recipe/lifecraft/O = out[j]
			if(R.rank_req < O.rank_req || (R.rank_req == O.rank_req && (R.tier < O.tier || (R.tier == O.tier && lowertext(R.label) < lowertext(O.label)))))
				out.Insert(j, R)
				placed = 1
				break
		if(!placed) out += R
	return out

proc/RegisterLifeCrafts()
	if(LifeCraftsDone) return
	LifeCraftsDone = 1
	for(var/T in typesof(/datum/craft_recipe/lifecraft) - /datum/craft_recipe/lifecraft)
		var/datum/craft_recipe/lifecraft/R = new T
		if(!R.id)
			del R
			continue
		if(LifeCraftById[R.id])
			world.log << "//\[warn]: duplicate lifecraft id [R.id] on [T], keeping the first."
			del R
			continue
		R.BuildSlots()
		LifeCraftById[R.id] = R
		var/list/bucket = LifeCraftBySkill[R.skill]
		if(!bucket)
			bucket = list()
			LifeCraftBySkill[R.skill] = bucket
		bucket += R
	for(var/s in LifeCraftBySkill)
		LifeCraftBySkill[s] = LifeSortCrafts(LifeCraftBySkill[s])

proc/LifeCraftRecipe(id)
	RegisterLifeCrafts()
	return LifeCraftById[id]

proc/LifeCraftRecipes(skill)
	RegisterLifeCrafts()
	var/list/L = LifeCraftBySkill[skill]
	return L ? L : list()

proc/LifeRollCraftQuality(mob/M, skill, avgq, perf, toolbonus = 0, extra = 0, raw = 0)
	if(!M) return QUAL_NORMAL
	var/rank = M.LifeRank(skill)
	var/P = 25 * (avgq - 1) + 30 * max(0, perf - 0.5) + toolbonus + 3 * rank + extra + M.LifeQualityPoints(skill)
	var/roll = P + rand(-LIFE_QROLL_SPREAD, LIFE_QROLL_SPREAD)
	var/q = QUAL_POOR
	if(roll >= LIFE_QBAND_LEGENDARY) q = QUAL_LEGENDARY
	else if(roll >= LIFE_QBAND_EPIC) q = QUAL_EPIC
	else if(roll >= LIFE_QBAND_GOOD) q = QUAL_GOOD
	else if(roll >= LIFE_QBAND_NORMAL) q = QUAL_NORMAL
	if(raw) return q
	return QualityClamp(clamp(q, LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)], LifeQualityCap(rank)))

proc/LifeBonusRound(n)
	if(n <= 0) return 0
	. = round(n)
	if(prob((n - .) * 100)) .++

mob/var/tmp/datum/craft_recipe/lifecraft/life_craft_current

mob/proc/LifeYieldMult(skill)
	return 1

mob/proc/LifeQualityPoints(skill)
	return 0

mob/proc/LifeGatherQualityChance(skill)
	return 0

mob/proc/LifeCraftSubExtra()
	return ""

client/proc/LifeCraftOpen(obj/LifeSkills/Station/S)
	if(mob) mob << "That station is not ready for work yet."

client/proc/LifeCraftDone(obj/LifeSkills/Station/S, datum/craft_recipe/lifecraft/R)
	return

proc/LifeCraftBanner(mob/M, i, n, label, list/perfs)
	if(!M || !M.client) return
	var/atom/movable/lifebar/b = new
	b.icon = null
	var/atom/movable/lifebar/part/text/t = new
	t.maptext_width = 198
	t.maptext_height = 32
	t.pixel_y = 30
	t.layer = b.layer + 0.3
	var/pips = ""
	for(var/k = 1 to max(1, n))
		if(perfs && k <= perfs.len)
			var/p = perfs[k]
			pips += "<font color=[p >= 1.2 ? "#78eb78" : (p >= 0.8 ? "#ffd86b" : "#ff6464")]>&#9679;</font>"
		else
			pips += "<font color=#6b7a8d>&#9679;</font>"
	t.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">STAGE [i]/[n] - [label]<br>[pips]</span></center>"
	b.vis_contents += t
	M.client.screen += b
	spawn(8)
		if(M && M.client) M.client.screen -= b
		del t
		del b

proc/LifeTakePick(mob/M, list/picks, i, n)
	if(!M || !picks || i < 1 || i > picks.len || n <= 0) return 0
	var/list/p = picks[i]
	if(!islist(p) || p.len < 2) return 0
	if(MechCraftIntrinsicID(p[1])) return 0
	return LifeConsumeExact(M, p[1], QualityClamp(p[2]), n)

mob/proc/DoLifeCraft(datum/craft_recipe/lifecraft/R, obj/LifeSkills/Station/S, list/picks)
	if(!client || KO || Dead || !R)
		if(client) client.LifeCraftDone(S, R)
		return 0
	if(mech_core_build)
		src << "Your previous intrinsic-core assembly is still being finalized."
		if(client) client.LifeCraftDone(S, R)
		return 0
	if(Using)
		src << "You're in the middle of something."
		client.LifeCraftDone(S, R)
		return 0
	if(client.life_minigame_sink)
		src << "Finish what you're doing first."
		return 0
	RegisterLifeCrafts()
	if(R.field_craft) return R.FieldCraft(src)
	if(R.station)
		if(!S || S.station_kind != R.station || get_dist(src, S) > 1)
			src << "You need to be next to a [R.station] for that."
			client.LifeCraftDone(S, R)
			return 0
	if(!picks || !picks.len) picks = R.AutoPicks(src)
	var/list/miss = R.Missing(src, picks)
	if(miss.len)
		src << "You cannot make that yet. ([jointext(miss, ", ")])"
		client.LifeCraftDone(S, R)
		return 0
	if(!UseLifeStamina(R.ls_cost))
		client.LifeCraftDone(S, R)
		return 0
	Using = 1
	var/rank = LifeRank(R.skill)
	var/obj/Items/LifeTool/tool = R.tool_kind ? GetBestLifeTool(src, R.tool_kind) : null
	var/D = R.Difficulty()
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * D + LIFE_SPEED_PER_UNDER * max(0, D - rank) - LIFE_SPEED_PER_OVER * max(0, rank - D), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	if(tool) speed *= max(0.7, 1 - tool.SweetSpotBonus)
	var/list/st = R.StageList(src)
	if(!st || !st.len) st = list(list("id" = "timing_bar", "label" = "WORK", "w" = 1, "reps" = 1, "gate" = 1))
	var/list/perfs = list()
	var/aborted = 0
	var/perf = 0
	var/wsum = 0
	var/gateperf = -1
	for(var/i = 1 to st.len)
		var/list/sd = st[i]
		if(!islist(sd)) continue
		var/sid = sd["id"] ? sd["id"] : "timing_bar"
		var/slabel = sd["label"] ? sd["label"] : "WORK"
		var/reps = sd["reps"] ? max(1, sd["reps"]) : 1
		var/w = ("w" in sd) ? sd["w"] : (1 / st.len)
		LifeCraftBanner(src, i, st.len, slabel, perfs)
		sleep(8)
		var/p = 0
		switch(sid)
			if("timing_bar")
				for(var/k = 1 to reps)
					var/r = RunLifeMinigame(src, "timing_bar", D, list("speed_mult" = speed, "target" = S))
					if(r < 0)
						aborted = 1
						break
					p += r / reps
			if("rapid_tap")
				p = RunLifeMinigame(src, "rapid_tap", -round(-D / 2), list("level" = -round(-rank / 2), "target" = S))
				if(p < 0) aborted = 1
			if("hold_fill")
				var/need = LIFE_HOLD_NEED(D)
				var/limit = round(need * LIFE_HOLD_GRACE(D, rank))
				p = RunLifeMinigame(src, "hold_fill", D, list("need" = need, "limit" = limit, "target" = S))
				if(p < 0) aborted = 1
			else
				p = RunLifeMinigame(src, sid, D, list("target" = S))
				if(p < 0) aborted = 1
		if(aborted) break
		perfs += p
		perf += p * w
		wsum += w
		if(sd["gate"]) gateperf = p
	Using = 0
	if(aborted)
		src << "You set the work aside before it is finished."
		if(client) client.LifeCraftDone(S, R)
		return 0
	if(wsum > 0) perf /= wsum
	var/tqb = tool ? tool.QualityBonus : 0
	if(tool) tool.LifeToolWear(src)
	if(gateperf >= 0 && gateperf < 1.0)
		var/lostany = 0
		if(R.slots)
			for(var/i = 1 to R.slots.len)
				var/datum/craft_slotreq/sr = R.slots[i]
				var/lose = round(sr.amount / 2)
				if(lose <= 0) continue
				if(LifeTakePick(src, picks, i, lose)) lostany = 1
			if(!lostany && R.slots.len) LifeTakePick(src, picks, 1, 1)
		src << "<font color=#ff6464>The work spoils at the last step. Some of the materials are lost.</font>"
		AddLifeXP(R.skill, LifeCraftXP(R.skill, R.tier) * LIFE_CRAFT_FAIL_XP, LIFE_PERF_MIN)
		if(client) client.LifeCraftDone(S, R)
		return 0
	var/cost = R.CraftCost()
	var/short = 0
	var/list/claim = list()
	if(R.slots)
		for(var/i = 1 to R.slots.len)
			var/datum/craft_slotreq/sr = R.slots[i]
			var/list/p = (i <= picks.len && islist(picks[i])) ? picks[i] : null
			if(!p || p.len < 2)
				short = 1
				break
			if(MechCraftIntrinsicID(p[1]))
				var/error = MechCraftIntrinsicError(src, R, i, p[1])
				if(error)
					src << error
					short = 1
					break
				continue
			var/key = "[p[1]]|[QualityClamp(p[2])]"
			var/had = claim[key] ? claim[key] : 0
			if(MatLogCountQ(p[1], QualityClamp(p[2])) - had < sr.amount)
				short = 1
				break
			claim[key] = had + sr.amount
	if(short)
		src << "The materials are gone."
		if(client) client.LifeCraftDone(S, R)
		return 0
	if(cost && !HasMoney(cost))
		src << "You no longer have the [Commas(cost)] for supplies."
		if(client) client.LifeCraftDone(S, R)
		return 0

	// Reserve before consuming materials. Normal recipes need no reservation.
	if(!MechCraftReserveCore(R, picks))
		if(client) client.LifeCraftDone(S, R)
		return 0
	var/obj/Items/made
	try
		var/qsum = 0
		var/tsum = 0
		var/amt = 0
		if(R.slots)
			for(var/i = 1 to R.slots.len)
				var/datum/craft_slotreq/sr = R.slots[i]
				var/list/p = picks[i]
				if(!islist(p) || p.len < 2) continue
				var/part_id = MechCraftIntrinsicID(p[1])
				if(part_id)
					var/datum/mech_intrinsic_part/P = MechIntrinsicParts[part_id]
					// Intrinsics contribute Normal quality and their core tier.
					// No material is consumed for this slot.
					qsum += QUAL_NORMAL * sr.amount
					tsum += P.CraftCoreTier() * sr.amount
					amt += sr.amount
					continue
				var/pq = QualityClamp(p[2])
				LifeConsumeExact(src, p[1], pq, sr.amount)
				qsum += pq * sr.amount
				tsum += LifeMatTier(p[1]) * sr.amount
				amt += sr.amount
		if(cost) TakeMoney(cost)
		var/avgq = amt ? (qsum / amt) : QUAL_NORMAL
		var/avgtier = amt ? (tsum / amt) : R.tier
		var/extra = clamp(round((avgtier - R.tier) * LIFE_CRAFT_TIER_P), 0, LIFE_CRAFT_TIER_P_CAP)
		life_craft_current = R
		var/q = LifeRollCraftQuality(src, R.skill, avgq, perf, tqb, extra)
		life_craft_current = null
		made = R.MakeResult(src, q, perf, picks)

	catch(var/exception/E)
		life_craft_current = null
		world.log << "Crafting [R.id] failed: [E]"
	MechCraftFinishCore(made)
	if(!made)
		src << "The craft could not produce an item. Any materials already consumed were spent."
		if(client) client.LifeCraftDone(S, R)
		return 0
	var/mname = made.name
	src << "<font color=#78eb78>You make [R.result_count > 1 ? "[R.result_count]x " : ""][mname]!</font>"
	LifeLogFind(R.skill, R.label)
	AddLifeXP(R.skill, LifeCraftXP(R.skill, R.tier), clamp(perf, LIFE_PERF_MIN, LIFE_PERF_MAX))
	if(client) client.LifeCraftDone(S, R)
	return 1

/obj/LifeSkills/Station
	var/station_kind
	var/craft_skill
	var/craft_title
	var/craft_verb = "CRAFT"

	Click()
		if(!craft_skill) return ..()
		if(!usr) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the [name]."
			return
		if(usr.client) usr.client.LifeCraftOpen(src)

	InteractWith(mob/M)
		if(!craft_skill || !M || !M.client) return 0
		if(get_dist(M, src) > 1) return 0
		M.client.LifeCraftOpen(src)
		return 1

/datum/life_tagset/selftest
	tags = list("Copper" = list("selftest"))

/datum/craft_recipe/lifecraft/selftest
	id = "selftest_billet"
	skill = "SelfTest"
	label = "Test Billet"
	tier = 2
	rank_req = 1
	ls_cost = 0
	result_type = /obj/Items/Material/Ingot/copper
	slotspec = list(\
		list("Core", 2, "mat:Copper", 1),\
		list("Plate", 1, "cat:Ingots", 2),\
		list("Trace", 1, "tag:selftest", 1))
	stages = list(\
		list("id" = "timing_bar", "label" = "SHAPE", "w" = 0.5, "reps" = 2, "gate" = 0),\
		list("id" = "hold_fill", "label" = "SET", "w" = 0.5, "reps" = 1, "gate" = 1))

proc/LifeSelfTestLine(mob/M, ok, txt)
	M << "[ok ? "<font color=#78eb78>PASS</font>" : "<font color=#ff6464>FAIL</font>"] - [txt]"
	return ok ? 0 : 1

mob/Admin4/verb/lifeCraftSelfTest()
	set category = "Admin"
	var/fails = 0

	RegisterLifeMaterials()
	RegisterLifeMatFamilies()
	var/cats = LifeMatCategories.len
	var/mats = LifeMatRegistry.len
	RegisterLifeMatFamilies()
	fails += LifeSelfTestLine(src, (LifeMatCategories.len == cats && LifeMatRegistry.len == mats), "family registration idempotent ([cats] categories, [mats] materials)")

	RegisterLifeCrafts()
	var/nby = LifeCraftById.len
	RegisterLifeCrafts()
	fails += LifeSelfTestLine(src, (LifeCraftById.len == nby), "craft registration idempotent ([nby] recipes)")

	var/datum/craft_recipe/lifecraft/R = LifeCraftRecipe("selftest_billet")
	fails += LifeSelfTestLine(src, (R && R.slots && R.slots.len == 3), "slotspec parsed to [R && R.slots ? R.slots.len : 0] slots")
	if(!R || !R.slots || R.slots.len != 3)
		src << "<b>lifeCraftSelfTest: [fails] failure(s), slot build is broken so the rest is skipped.</b>"
		return
	var/datum/lifeskill/SK = GetLifeSkill("SelfTest")
	var/oldrank = SK.rank
	SK.rank = 1
	var/datum/craft_slotreq/s1 = R.slots[1]
	var/datum/craft_slotreq/s2 = R.slots[2]
	var/datum/craft_slotreq/s3 = R.slots[3]
	fails += LifeSelfTestLine(src, (s1.matclass == "Copper" && s2.category == "Ingots" && s2.min_tier == 2 && s3.mat_tag == "selftest"), "selectors: mat=[s1.matclass] cat=[s2.category] t[s2.min_tier] tag=[s3.mat_tag]")
	fails += LifeSelfTestLine(src, (s1.Accepts("Copper") && !s1.Accepts("Iron")), "Accepts mat: Copper yes, Iron no")
	fails += LifeSelfTestLine(src, (s2.Accepts("Iron") && !s2.Accepts("Copper")), "Accepts cat + min_tier: Iron yes, Copper no")
	fails += LifeSelfTestLine(src, (s3.Accepts("Copper") && !s3.Accepts("Iron")), "Accepts tag: Copper yes, Iron no")
	fails += LifeSelfTestLine(src, (s2.Describe() == "1x any Ingots (tier 2+)"), "Describe: [s2.Describe()]")

	var/datum/collectionlog/saved = matlog
	matlog = new
	MatLogAdd("Copper", QUAL_POOR, 5)
	MatLogAdd("Copper", QUAL_GOOD, 2)
	MatLogAdd("Iron", QUAL_NORMAL, 3)
	var/list/picks = R.AutoPicks(src)
	var/list/p1 = (picks.len >= 1 && islist(picks[1])) ? picks[1] : null
	var/list/p2 = (picks.len >= 2 && islist(picks[2])) ? picks[2] : null
	var/list/p3 = (picks.len >= 3 && islist(picks[3])) ? picks[3] : null
	fails += LifeSelfTestLine(src, (p1 && p1[1] == "Copper" && p1[2] == QUAL_POOR), "auto-pick takes lowest quality: [p1 ? "[p1[1]] q[p1[2]]" : "none"]")
	fails += LifeSelfTestLine(src, (p2 && p2[1] == "Iron" && p2[2] == QUAL_NORMAL), "auto-pick honors tier gate: [p2 ? "[p2[1]] q[p2[2]]" : "none"]")
	fails += LifeSelfTestLine(src, (p3 && p3[1] == "Copper" && p3[2] == QUAL_POOR), "auto-pick reuses a bucket with room left: [p3 ? "[p3[1]] q[p3[2]]" : "none"]")
	var/list/miss = R.Missing(src, picks)
	fails += LifeSelfTestLine(src, (miss.len == 0), "full stock is craftable ([miss.len] reasons)")

	matlog = new
	MatLogAdd("Copper", QUAL_POOR, 2)
	MatLogAdd("Iron", QUAL_NORMAL, 3)
	var/list/tight = R.AutoPicks(src)
	var/list/t3 = (tight.len >= 3 && islist(tight[3])) ? tight[3] : null
	fails += LifeSelfTestLine(src, (tight.len == R.slots.len && isnull(t3)), "double bucket: slot 3 gets no pick when slot 1 claimed both ([tight.len] rows for [R.slots.len] slots)")
	var/list/forced = list(list("Copper", QUAL_POOR), list("Iron", QUAL_NORMAL), list("Copper", QUAL_POOR))
	var/list/miss2 = R.Missing(src, forced)
	fails += LifeSelfTestLine(src, (miss2.len > 0), "double bucket: forcing the same bucket twice is refused ([miss2.len > 0 ? miss2[1] : "no reason"])")
	matlog = saved

	var/sum = 0
	for(var/i = 1 to 10000)
		sum += LifeBonusRound(1.35)
	var/mean = sum / 10000
	fails += LifeSelfTestLine(src, (abs(mean - 1.35) <= 0.027), "LifeBonusRound(1.35) mean over 10000 = [round(mean, 0.001)]")

	var/list/cases = list(\
		list(10, 5, 1.5, 22, "rank 10 best case"),\
		list(9, 5, 1.5, 22, "rank 9 best case"),\
		list(5, 3, 1.0, 10, "rank 5 midrange"))
	for(var/ci = 1 to cases.len)
		var/list/C = cases[ci]
		SK.rank = C[1]
		var/list/tally = list(0, 0, 0, 0, 0)
		for(var/i = 1 to 10000)
			var/q = LifeRollCraftQuality(src, "SelfTest", C[2], C[3], C[4], 0)
			tally[q]++
		var/txt = ""
		for(var/q = QUAL_POOR to QUAL_LEGENDARY)
			txt += "[QUALITY_NAMES[q]] [round(tally[q] / 100, 0.1)]%  "
		src << "<font color=#8be9ff>ROLL</font> - [C[5]] (rank [C[1]], avgq [C[2]], perf [C[3]], tool [C[4]]): [txt]"
	SK.rank = oldrank
	if(lifeskills && lifeskills.skills) lifeskills.skills -= "SelfTest"

	src << "<b>lifeCraftSelfTest: [fails ? "[fails] FAILURE(S)" : "all checks passed"].</b>"

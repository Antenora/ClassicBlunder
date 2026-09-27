client/var/tmp/obj/LifeSkills/Station/cp_station
client/var/tmp/cp_recipe_id
client/var/tmp/list/cp_picks

proc/LifeCraftKey(obj/LifeSkills/Station/S)
	return "craft:\ref[S]"

/obj/LifeSkills/Station/proc/CraftReach(mob/M)
	return (M && get_dist(M, src) <= 1) ? 1 : 0

proc/LifeCraftFits(datum/craft_recipe/lifecraft/R, obj/LifeSkills/Station/S)
	if(!R || !S || !S.craft_skill) return 0
	if(R.skill != S.craft_skill) return 0
	if(R.station && R.station != S.station_kind) return 0
	return 1

proc/LifeCraftPanelSort(list/L)
	var/list/out = list()
	for(var/datum/craft_recipe/lifecraft/R in L)
		var/placed = 0
		for(var/j = 1 to out.len)
			var/datum/craft_recipe/lifecraft/O = out[j]
			if(R.tier < O.tier || (R.tier == O.tier && (R.rank_req < O.rank_req || (R.rank_req == O.rank_req && lowertext(R.label) < lowertext(O.label)))))
				out.Insert(j, R)
				placed = 1
				break
		if(!placed) out += R
	return out

client/proc/LifeCraftTab(obj/LifeSkills/Station/S)
	if(!S) return "CRAFT"
	if(S.craft_title) return "[S.craft_title]"
	return uppertext("[S.name]")

client/proc/LifeCraftSub(obj/LifeSkills/Station/S)
	var/mob/M = mob
	if(!M || !S) return ""
	M.CheckLifeStaminaRefill()
	var/datum/lifeskill/SK = M.GetLifeSkill(S.craft_skill)
	var/head
	if(SK.rank < 1)
		head = "[S.craft_skill] is not learned - buy in at the Life Skills menu"
	else
		head = "[S.craft_skill] rank [SK.rank] - [SK.Title()]"
	var/extra = M.LifeCraftSubExtra()
	return "[head] | Life Stamina [M.LifeStamina]/[LIFE_STAMINA_MAX][extra ? " | [extra]" : ""]"

client/proc/LifeCraftSyncPicks(datum/craft_recipe/lifecraft/R)
	var/n = (R && R.slots) ? R.slots.len : 0
	if(!islist(cp_picks)) cp_picks = list()
	while(cp_picks.len < n)
		cp_picks.len++
	if(cp_picks.len > n) cp_picks.Cut(n + 1)

client/proc/LifeCraftPrunePicks(datum/craft_recipe/lifecraft/R)
	if(!mob || !islist(cp_picks)) return
	LifeCraftSyncPicks(R)
	for(var/i = 1 to cp_picks.len)
		var/list/p = islist(cp_picks[i]) ? cp_picks[i] : null
		if(!p || p.len < 2)
			cp_picks[i] = null
			continue
		if(mob.MatLogCountQ(p[1], QualityClamp(p[2])) <= 0) cp_picks[i] = null

client/proc/LifeCraftList(obj/LifeSkills/Station/S)
	var/mob/M = mob
	if(!M || !S || !S.craft_skill) return
	cp_station = S
	cp_recipe_id = null
	cp_picks = null
	var/list/pool = list()
	for(var/datum/craft_recipe/lifecraft/R in LifeCraftRecipes(S.craft_skill))
		if(!LifeCraftFits(R, S)) continue
		pool += R
	pool = LifeCraftPanelSort(pool)
	var/list/rows = list()
	var/tier = -1
	for(var/datum/craft_recipe/lifecraft/R in pool)
		if(R.tier != tier)
			tier = R.tier
			rows[++rows.len] = list("sec" = "TIER [tier]")
		var/list/needs = list()
		if(R.slots)
			for(var/datum/craft_slotreq/sr in R.slots)
				needs += sr.Describe()
		var/status = R.Locked(M)
		if(!status)
			var/list/miss = R.Missing(M, R.AutoPicks(M))
			status = miss.len ? miss[1] : "ready"
		rows[++rows.len] = list("t" = "[R.label]", "t2" = "[R.Summary(M)]", "c" = list(jointext(needs, ", "), "[status]"), "h" = "?src=\ref[S];cp=open;id=[url_encode("[R.id]")]")
	if(!rows.len) rows[++rows.len] = list("t" = "nothing can be made here yet", "c" = list("", ""))
	var/list/cols = list(list("l" = "RECIPE", "a" = "l"), list("l" = "NEEDS", "a" = "l"), list("l" = "STATUS", "a" = "r"))
	TableShow(LifeCraftKey(S), LifeCraftTab(S), "[S.craft_skill]", LifeCraftSub(S), cols, rows, "a recipe to set it up", null, list("two" = 1, "nosort" = 1))

client/proc/LifeCraftCard(obj/LifeSkills/Station/S, datum/craft_recipe/lifecraft/R)
	var/mob/M = mob
	if(!M || !S || !R) return
	cp_station = S
	cp_recipe_id = R.id
	LifeCraftSyncPicks(R)
	var/list/rows = list()
	rows[++rows.len] = list("sec" = "INGREDIENTS")
	if(R.slots)
		for(var/i = 1 to R.slots.len)
			var/datum/craft_slotreq/sr = R.slots[i]
			if(R.field_craft)
				rows[++rows.len] = list("t" = "[sr.name] - [sr.Describe()]", "c" = list("auto, lowest tier first"))
				continue
			var/cell = "pick one"
			var/list/p = islist(cp_picks[i]) ? cp_picks[i] : null
			if(p && p.len >= 2)
				var/have = M.MatLogCountQ(p[1], QualityClamp(p[2]))
				cell = "[QualityName(p[2])] [LifeMatName(p[1])] (have [have])"
				if(have < sr.amount) cell += " - short"
			rows[++rows.len] = list("t" = "[sr.name] - [sr.Describe()]", "c" = list(cell), "h" = "?src=\ref[S];cp=pick;slot=[i]")
	rows[++rows.len] = list("sec" = "PROJECTED")
	for(var/line in R.Project(M, cp_picks))
		rows[++rows.len] = list("t" = "", "c" = list("[line]"), "w" = 1)
	var/list/cols = list(list("l" = "SLOT", "a" = "l"), list("l" = "PICK", "a" = "r"))
	var/list/acts = list(list("[S.craft_verb]", "?src=\ref[S];cp=craft"), list("AUTO", "?src=\ref[S];cp=auto"), list("BACK", "?src=\ref[S];cp=back"))
	var/hint = "a slot to choose what goes in"
	if(R.field_craft)
		acts = list(list("BATCH", "?src=\ref[S];cp=batch"), list("BACK", "?src=\ref[S];cp=back"))
		hint = "BATCH to choose how many"
	TableShow(LifeCraftKey(S), LifeCraftTab(S), "[R.label]", LifeCraftSub(S), cols, rows, hint, acts, list("nosort" = 1))

client/proc/LifeCraftPick(obj/LifeSkills/Station/S, datum/craft_recipe/lifecraft/R, i)
	var/mob/M = mob
	if(!M || !S || !R || !R.slots || i < 1 || i > R.slots.len) return
	var/datum/craft_slotreq/sr = R.slots[i]
	var/list/opts = R.SlotOptions(M, i)
	if(!opts || !opts.len)
		M << "You have nothing that fits [sr.name] ([sr.Describe()])."
		return
	var/list/labels = list()
	for(var/j = 1 to opts.len)
		var/list/o = opts[j]
		labels += "[QualityName(o[2])] [LifeMatName(o[1])] x[o[3]] (tier [LifeMatTier(o[1])])"
	var/ans = Ask(M, "[sr.name]: choose what goes in.", "INGREDIENT", null, "pick", labels, 1)
	if(isnull(ans)) return
	var/k = labels.Find("[ans]")
	if(k < 1) return
	if(!mob || mob != M || M.KO || M.Dead) return
	if(!S || !S.craft_skill || !S.CraftReach(M) || M.Using || life_minigame_sink)
		PanelClose(LifeCraftKey(S))
		return
	if(cp_station != S || cp_recipe_id != R.id) return
	LifeCraftSyncPicks(R)
	if(i > cp_picks.len) return
	var/list/o = opts[k]
	cp_picks[i] = list(o[1], QualityClamp(o[2]))
	LifeCraftCard(S, R)

client/LifeCraftOpen(obj/LifeSkills/Station/S)
	if(!mob || !S || !S.craft_skill) return
	if(mob.KO || mob.Dead) return
	if(!S.CraftReach(mob))
		mob << "You need to get closer to the [S.name]."
		return
	if(cp_station != S)
		cp_recipe_id = null
		cp_picks = null
	LifeCraftList(S)

client/LifeCraftDone(obj/LifeSkills/Station/S, datum/craft_recipe/lifecraft/R)
	if(!mob || !S || !R) return
	if(mob.KO || mob.Dead) return
	if(!S.CraftReach(mob)) return
	if(np_open) return
	if(!LifeCraftFits(R, S)) return
	cp_station = S
	cp_recipe_id = R.id
	LifeCraftPrunePicks(R)
	LifeCraftCard(S, R)

/obj/LifeSkills/Station/Topic(href, href_list[])
	var/act = href_list["cp"]
	if(!act) return ..()
	var/mob/M = usr
	if(!istype(M) || !M.client) return
	var/client/C = M.client
	var/key = LifeCraftKey(src)
	if(!craft_skill || M.KO || M.Dead || M.Using || C.life_minigame_sink || !CraftReach(M))
		C.PanelClose(key)
		return
	if(act == "back")
		C.LifeCraftList(src)
		return
	if(act == "open")
		var/datum/craft_recipe/lifecraft/N = LifeCraftRecipe(href_list["id"])
		if(!LifeCraftFits(N, src))
			C.PanelClose(key)
			return
		if(C.cp_station != src || C.cp_recipe_id != N.id) C.cp_picks = null
		C.LifeCraftCard(src, N)
		return
	if(!C.cp_recipe_id)
		C.PanelClose(key)
		return
	var/datum/craft_recipe/lifecraft/R = LifeCraftRecipe(C.cp_recipe_id)
	if(C.cp_station != src || !LifeCraftFits(R, src))
		C.PanelClose(key)
		return
	switch(act)
		if("auto")
			C.cp_picks = R.AutoPicks(M)
			C.LifeCraftCard(src, R)
		if("pick")
			var/i = text2num(href_list["slot"])
			if(isnull(i) || i != round(i) || !R.slots || i < 1 || i > R.slots.len)
				C.PanelClose(key)
				return
			var/obj/LifeSkills/Station/here = src
			spawn()
				C.LifeCraftPick(here, R, i)
		if("craft")
			C.LifeCraftSyncPicks(R)
			var/list/auto = R.AutoPicks(M)
			for(var/i = 1 to C.cp_picks.len)
				if(!islist(C.cp_picks[i]) && islist(auto) && i <= auto.len && islist(auto[i]))
					C.cp_picks[i] = auto[i]
			var/list/miss = R.Missing(M, C.cp_picks)
			if(miss.len)
				M << "You cannot make that yet. ([miss[1]])"
				C.LifeCraftCard(src, R)
				return
			var/list/picks = C.cp_picks.Copy()
			var/obj/LifeSkills/Station/here = src
			C.PanelClose(key)
			spawn()
				M.DoLifeCraft(R, here, picks)
		if("batch")
			if(!R.field_craft)
				C.PanelClose(key)
				return
			var/obj/LifeSkills/Station/here = src
			spawn()
				R.FieldCraft(M)
				if(C) C.LifeCraftDone(here, R)
		else
			C.PanelClose(key)

mob/Admin4/verb/lifeCraftPanelTest()
	set category = "Admin"
	if(!client) return
	var/turf/T = get_step(src, dir)
	if(!T) T = loc
	if(!T)
		src << "No ground to put it on."
		return
	var/obj/LifeSkills/Station/S = new(T)
	S.name = "Test Bench"
	S.desc = "A temporary bench for the craft panel self test."
	S.icon = 'Icons/LifeSkills/Stations.dmi'
	S.icon_state = "anvil"
	S.Savable = 0
	S.craft_skill = "SelfTest"
	S.craft_title = "SELF TEST"
	S.craft_verb = "MAKE"
	src << "Test bench placed. Walk more than 3 tiles away to remove it."
	client.LifeCraftOpen(S)
	spawn()
		while(S && src && client && get_dist(src, S) <= 3)
			sleep(10)
		if(S)
			if(src && client)
				client.PanelClose(LifeCraftKey(S))
				if(client.cp_station == S)
					client.cp_station = null
					client.cp_recipe_id = null
					client.cp_picks = null
			del S
			if(src) src << "The test bench is gone."

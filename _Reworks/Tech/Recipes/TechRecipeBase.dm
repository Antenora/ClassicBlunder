/datum/craft_recipe/lifecraft/tech
	skill = "Technology"
	station = "workbench"
	rank_req = 0
	stages = list(list("id" = "timing_bar", "label" = "BUILD", "w" = 1, "reps" = 1, "gate" = 1))
	var/list/add_slots
	var/list/drop_slots
	var/metal_sel
	var/metal_n = 0
	var/optic_sel = TECH_SEL_OPTIC
	var/list/item_inputs

	New()
		..()
		if(!rank_req) rank_req = TECH_RANK_FOR(tier)
		var/list/base = TemplateSlots()
		if(base) slotspec = TechTwistSlots(base, drop_slots, add_slots)

	proc/TemplateSlots()
		return null

	proc/TechItemText()
		if(!item_inputs || !item_inputs.len) return ""
		var/list/parts = list()
		for(var/p in item_inputs)
			parts += "[item_inputs[p]]x [TechItemName(p)]"
		return jointext(parts, ", ")

	proc/TechItemsShort(mob/M, runs = 1)
		. = list()
		if(!M || !item_inputs) return
		for(var/p in item_inputs)
			var/need = item_inputs[p] * runs
			if(M.TechItemCount(p) < need) . += "[need]x [TechItemName(p)]"

	proc/TechItemLines(mob/M)
		. = list()
		if(!item_inputs) return
		for(var/p in item_inputs)
			var/need = item_inputs[p]
			var/line = "Uses: [need]x [TechItemName(p)] from your pack"
			if(M)
				var/have = M.TechItemCount(p)
				line += ", have [have][have < need ? ", short" : ""]"
			. += line

	Summary(mob/M)
		. = knowledge_req ? "[knowledge_req]" : "no node needed"
		var/t = TechItemText()
		if(t) . += ", uses [t]"

	Missing(mob/M, list/picks)
		. = ..()
		if(M) . += TechItemsShort(M)

	Project(mob/M, list/picks)
		. = ..()
		. += TechItemLines(M)

	MakeResult(mob/M, q, perf)
		if(!M || !result_type) return null
		if(item_inputs && !M.TechTakeItems(item_inputs))
			var/what = TechItemText()
			var/made = label
			spawn(0)
				if(M) M << "<font color=#ff6464>The [made] needs [what] from your pack, and it is gone. The work falls apart and the materials are spent.</font>"
			return null
		return TechMakeOutput(M, result_type, max(1, result_count), QualityClamp(q))

/datum/craft_recipe/lifecraft/tech/part

/datum/craft_recipe/lifecraft/tech/consumable
	TemplateSlots()
		. = list(list("Gel", TECH_A_BIOGEL, TECH_MAT_BIOGEL, 1))
		if(tier >= TECH_A_HERB_TIER) . += list(list("Herb", TECH_A_HERB, TECH_SEL_HERB, tier))
		if(tier >= TECH_A_GELATIN_TIER) . += list(list("Gelatin", TECH_A_GELATIN, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/handheld
	TemplateSlots()
		. = list(list("Casing", TECH_B_CASING, TECH_MAT_CASING, 1))
		. += list(list("Wiring", min(tier, TECH_B_WIRING_MAX), TECH_MAT_WIRING, 1))
		if(tier >= TECH_B_BOARD_TIER) . += list(list("Board", TECH_B_BOARD, TECH_MAT_BOARD, 1))
		if(tier >= TECH_B_OPTIC_TIER) . += list(list("Optic", TECH_B_OPTIC, optic_sel, 1))

/datum/craft_recipe/lifecraft/tech/placed
	TemplateSlots()
		. = list(list("Casing", TECH_C_CASING, TECH_MAT_CASING, 1))
		. += list(list("Board", TECH_C_BOARD, TECH_MAT_BOARD, 1))
		if(tier >= TECH_C_CELL_TIER) . += list(list("Cell", TECH_C_CELL, TECH_MAT_CELL, 1))
		. += list(list("Metal", metal_n ? metal_n : tier, metal_sel ? metal_sel : TECH_SEL_INGOT, tier))

/datum/craft_recipe/lifecraft/tech/wearable
	TemplateSlots()
		. = list(list("Casing", TECH_D_CASING, TECH_MAT_CASING, 1))
		. += list(list("Servo", TECH_D_SERVO, TECH_MAT_SERVO, 1))
		. += list(list("Metal", metal_n ? metal_n : TECH_D_METAL, metal_sel ? metal_sel : TECH_SEL_INGOT, tier))
		if(tier >= TECH_D_CELL_TIER) . += list(list("Cell", TECH_D_CELL, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/field
	station = null
	ls_cost = 0
	stages = null
	field_craft = 1

	FieldCraft(mob/M)
		return M ? M.DoLifeFieldCraft(src) : 0

	Summary(mob/M)
		. = "field craft, made in batches anywhere"
		var/t = TechItemText()
		if(t) . += ", uses [t] a run"

	Project(mob/M, list/picks)
		. = list()
		. += "Quality: [QualityName(QUAL_NORMAL)], field crafts do not roll"
		. += "Makes: [result_count]x [label] per run, up to [TECH_BATCH_MAX] runs a batch"
		. += TechItemLines(M)
		if(!M) return
		. += "Enough for: [M.TechFieldMost(src)] runs"
		. += "XP: [M.TechFreeXPLeft()] of [TECH_FREE_XP_PER_DAY] paid batches left today"

/datum/craft_recipe/lifecraft/tech/door
	var/locked = 1
	var/glazed = 0

	TemplateSlots()
		. = list(list("Casing", TECH_F_CASING, TECH_MAT_CASING, 1))
		. += list(list("Metal", metal_n ? metal_n : TECH_F_METAL, metal_sel ? metal_sel : "mat:Iron", 1))
		if(locked) . += list(list("Wiring", TECH_F_WIRING, TECH_MAT_WIRING, 1))
		if(glazed) . += list(list("Glass", TECH_F_SHARDS, "mat:GemShards", 1))

proc/TechTwistSlots(list/base, list/drop, list/add)
	var/list/out = list()
	for(var/list/row in base)
		if(drop && ("[row[1]]" in drop)) continue
		out += list(row.Copy())
	if(!add) return out
	for(var/list/row in add)
		var/merged = 0
		var/rt = (row.len >= 4) ? row[4] : 1
		for(var/list/o in out)
			var/ot = (o.len >= 4) ? o[4] : 1
			if(o[3] == row[3] && ot == rt)
				o[2] += row[2]
				merged = 1
				break
		if(!merged) out += list(row.Copy())
	return out

proc/TechStampMade(obj/Items/I, mob/M, q)
	if(!I || !M) return
	I.CraftQuality = QualityClamp(q)
	I.CreatorKey = M.ckey
	I.CreatorSignature = M.EnergySignature
	I.CreatorName = "[M.name]"

proc/TechHandOver(mob/M, obj/Items/I)
	if(!M || !I) return null
	if(!I.Grabbable)
		I.loc = M.loc
		return I
	var/path = I.type
	var/q = I.CraftQuality
	var/mid = I.metal_id
	M.GiveOrDrop(I)
	if(I) return I
	for(var/obj/Items/e in M)
		if(e.type == path && e.CraftQuality == q && e.metal_id == mid) return e
	return null

proc/TechMakeOutput(mob/M, path, n, q)
	if(!M || !path || n <= 0) return null
	if(ispath(path, /obj/Items/Material))
		GiveMaterial(M, path, n, q)
		return null
	var/obj/Items/first = new path
	TechStampMade(first, M, q)
	if(first.Stackable)
		first.TotalStack = n
		first.suffix = "[n]"
		return TechHandOver(M, first)
	. = TechHandOver(M, first)
	for(var/k = 2 to n)
		var/obj/Items/more = new path
		TechStampMade(more, M, q)
		var/got = TechHandOver(M, more)
		if(got) . = got

proc/TechItemName(path)
	if(!ispath(path, /obj/Items)) return "[path]"
	var/obj/Items/I = path
	return initial(I.name)

mob/proc/TechItemPool(path)
	var/list/out = list()
	if(!ispath(path, /obj/Items)) return out
	for(var/obj/Items/I in src)
		if(!istype(I, path)) continue
		if(I.suffix == "*Equipped*") continue
		if(I.Stackable && I.TotalStack <= 0) continue
		var/placed = 0
		for(var/j = 1 to out.len)
			var/obj/Items/o = out[j]
			if(I.CraftQuality < o.CraftQuality)
				out.Insert(j, I)
				placed = 1
				break
		if(!placed) out += I
	return out

mob/proc/TechItemCount(path)
	. = 0
	for(var/obj/Items/I in TechItemPool(path))
		. += I.Stackable ? I.TotalStack : 1

mob/proc/TechItemRuns(datum/craft_recipe/lifecraft/R)
	var/datum/craft_recipe/lifecraft/tech/T = R
	if(!istype(T) || !T.item_inputs || !T.item_inputs.len) return TECH_BATCH_MAX
	. = TECH_BATCH_MAX
	for(var/p in T.item_inputs)
		var/need = max(1, T.item_inputs[p])
		. = min(., round(TechItemCount(p) / need))

mob/proc/TechTakeItems(list/inputs, runs = 1)
	if(!inputs || !inputs.len) return 1
	for(var/p in inputs)
		if(TechItemCount(p) < inputs[p] * runs) return 0
	for(var/p in inputs)
		var/need = inputs[p] * runs
		for(var/obj/Items/I in TechItemPool(p))
			if(need <= 0) break
			if(I.Stackable)
				var/take = min(need, I.TotalStack)
				I.TotalStack -= take
				need -= take
				if(I.TotalStack <= 0)
					del I
				else
					I.suffix = "[I.TotalStack]"
			else
				need--
				del I
	if(client) client.BuildInvPage()
	return 1

mob/var/tech_free_day = -1
mob/var/tech_free_n = 0

mob/proc/TechFreeSettle()
	var/today = DaysOfWipe()
	if(tech_free_day == today) return
	tech_free_day = today
	tech_free_n = 0

mob/proc/TechFreeXPLeft()
	TechFreeSettle()
	return max(0, TECH_FREE_XP_PER_DAY - tech_free_n)

mob/proc/TechFreeXP(datum/craft_recipe/lifecraft/R)
	if(!R) return 0
	TechFreeSettle()
	if(tech_free_n >= TECH_FREE_XP_PER_DAY) return 0
	tech_free_n++
	AddLifeXP(R.skill, LifeCraftXP(R.skill, R.tier), 1)
	return 1

proc/TechFieldSlotOrder(datum/craft_recipe/lifecraft/R)
	. = list()
	if(!R || !R.slots) return
	for(var/i = 1 to R.slots.len)
		var/datum/craft_slotreq/S = R.slots[i]
		if(S.matclass) . += i
	for(var/i = 1 to R.slots.len)
		var/datum/craft_slotreq/S = R.slots[i]
		if(!S.matclass) . += i

mob/proc/TechFieldAllocate(datum/craft_recipe/lifecraft/R, want)
	var/list/claims = list()
	. = list(0, claims)
	if(!R || !R.slots || !R.slots.len || want <= 0) return
	var/list/order = TechFieldSlotOrder(R)
	var/list/opts = list()
	var/list/left = list()
	for(var/i = 1 to R.slots.len)
		var/list/o = R.SlotOptions(src, i)
		opts += list(o)
		for(var/list/row in o)
			var/key = "[row[1]]|[row[2]]"
			if(isnull(left[key])) left[key] = row[3]
	var/made = 0
	while(made < want)
		var/list/unit = list()
		var/ok = 1
		for(var/i in order)
			var/datum/craft_slotreq/S = R.slots[i]
			var/need = S.amount
			for(var/list/row in opts[i])
				if(need <= 0) break
				var/key = "[row[1]]|[row[2]]"
				var/have = left[key]
				if(have <= 0) continue
				var/take = min(have, need)
				left[key] = have - take
				need -= take
				unit[key] = (unit[key] ? unit[key] : 0) + take
			if(need > 0)
				ok = 0
				break
		if(!ok)
			for(var/key in unit) left[key] += unit[key]
			break
		for(var/key in unit) claims[key] = (claims[key] ? claims[key] : 0) + unit[key]
		made++
	. = list(made, claims)

mob/proc/TechFieldMost(datum/craft_recipe/lifecraft/R)
	var/list/plan = TechFieldAllocate(R, TECH_BATCH_MAX)
	return min(plan[1], TechItemRuns(R))

mob/proc/TechFieldShort(datum/craft_recipe/lifecraft/R)
	var/datum/craft_recipe/lifecraft/tech/T = R
	if(istype(T))
		var/list/short = T.TechItemsShort(src)
		if(short.len) return short[1]
	if(!R || !R.slots) return "materials"
	for(var/i = 1 to R.slots.len)
		var/datum/craft_slotreq/S = R.slots[i]
		var/have = 0
		for(var/list/row in R.SlotOptions(src, i))
			have += row[3]
		if(have < S.amount) return S.Describe()
	return "materials"

mob/proc/DoLifeFieldCraft(datum/craft_recipe/lifecraft/R, qty)
	if(!R || !R.field_craft) return 0
	if(KO || Dead) return 0
	if(Using)
		src << "You're in the middle of something."
		return 0
	if(client && client.life_minigame_sink)
		src << "Finish what you're doing first."
		return 0
	RegisterLifeCrafts()
	var/reason = R.Locked(src)
	if(reason)
		src << "You cannot make that yet. ([reason])"
		return 0
	if(isnull(qty))
		if(!client) return 0
		var/most = TechFieldMost(R)
		if(most < 1)
			src << "You cannot make that yet. ([TechFieldShort(R)])"
			return 0
		var/ans = Ask(src, "How many runs of [R.label]? Each run makes [R.result_count]. You have enough for [most].", "BATCH", most, "num", null, 1)
		if(isnull(ans)) return 0
		if(KO || Dead || Using) return 0
		if(client && client.life_minigame_sink) return 0
		qty = ans
	qty = min(round(qty), TECH_BATCH_MAX)
	if(qty < 1) return 0
	var/cost = R.CraftCost() * qty
	if(cost && !HasMoney(cost))
		src << "You need [Commas(cost)] for that batch."
		return 0
	var/list/plan = TechFieldAllocate(R, qty)
	var/can = min(plan[1], TechItemRuns(R))
	if(can < qty)
		src << "You only have enough for [can]."
		return 0
	if(R.ls_cost && !UseLifeStamina(R.ls_cost * qty)) return 0
	var/datum/craft_recipe/lifecraft/tech/T = R
	if(istype(T) && T.item_inputs && !TechTakeItems(T.item_inputs, qty))
		src << "You only have enough for [TechItemRuns(R)]."
		return 0
	var/list/claims = plan[2]
	for(var/key in claims)
		var/p = findtext(key, "|")
		LifeConsumeExact(src, copytext(key, 1, p), text2num(copytext(key, p + 1)), claims[key])
	if(cost) TakeMoney(cost)
	var/n = qty * max(1, R.result_count)
	TechMakeOutput(src, R.result_type, n, QUAL_NORMAL)
	LifeLogFind(R.skill, R.label)
	var/paid = TechFreeXP(R)
	src << "<font color=#78eb78>You make [n]x [R.label].[paid ? "" : " Field crafts pay no more XP today."]</font>"
	return qty

/obj/LifeSkills/Station/TechField
	name = "Field Kit"
	desc = "The tools a technologist carries for work away from the bench."
	density = 0
	Savable = 0
	station_kind = "field"
	craft_skill = "Technology"
	craft_title = "FIELD CRAFT"
	craft_verb = "BATCH"
	var/mob/kit_owner

	CraftReach(mob/M)
		return (M && M == kit_owner) ? 1 : 0

client/var/tmp/obj/LifeSkills/Station/TechField/tech_field_kit

client/TechFieldCraftOpen(recipe_id)
	if(!mob || mob.KO || mob.Dead) return
	if(!tech_field_kit) tech_field_kit = new
	tech_field_kit.kit_owner = mob
	if(recipe_id)
		var/datum/craft_recipe/lifecraft/R = LifeCraftRecipe(recipe_id)
		if(R && LifeCraftFits(R, tech_field_kit))
			if(cp_station != tech_field_kit) cp_picks = null
			LifeCraftCard(tech_field_kit, R)
			return
	LifeCraftOpen(tech_field_kit)

proc/TechFieldRecipeFor(path)
	if(!path) return null
	for(var/datum/craft_recipe/lifecraft/R in LifeCraftRecipes("Technology"))
		if(R.field_craft && R.result_type == path) return R
	return null

/atom/movable/shud/invfieldbtn
	layer = MINV_LAYER + 0.7
	mouse_opacity = 2
	maptext_height = 18
	var/recipe_id

	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HideItemDesc()
			return
		usr.client.TechFieldCraftOpen(recipe_id)

client/FieldCraftDescButton(obj/Items/I, list/objs)
	..()
	if(!I || !islist(objs)) return
	var/datum/craft_recipe/lifecraft/R = TechFieldRecipeFor(I.type)
	if(!R) return
	var/atom/movable/shud/invfieldbtn/fb = new
	fb.recipe_id = R.id
	fb.maptext_width = 100
	fb.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9874; Make more</span>"
	fb.screen_loc = "[InvXLoc(TECH_INV_BTN_X)],CENTER:[TECH_INV_BTN_Y - (I.BeltUsable ? TECH_INV_BTN_STEP : 0)]"
	objs += fb

proc/TechRecipeAuditLines()
	RegisterLifeMaterials()
	RegisterLifeMatFamilies()
	RegisterLifeMatTags()
	RegisterLifeCrafts()
	if(length(TechnologyTree) < 1)
		fillOutTechTree()
	var/list/out = list()
	var/list/recipes = LifeCraftRecipes("Technology")
	var/list/pernode = list()
	var/list/badnode = list()
	var/list/badsel = list()
	var/list/badtype = list()
	var/list/badrank = list()
	var/list/made = list()
	var/nfield = 0
	out += "Technology recipe audit"
	for(var/datum/craft_recipe/lifecraft/R in recipes)
		var/node = R.knowledge_req ? R.knowledge_req : "no node"
		pernode[node] = (pernode[node] ? pernode[node] : 0) + 1
		if(R.field_craft) nfield++
		if(R.knowledge_req && !TechnologyTree[R.knowledge_req]) badnode += "[R.id] needs [R.knowledge_req]"
		if(!ispath(R.result_type, /obj/Items)) badtype += "[R.id] makes [R.result_type]"
		else made[R.result_type] = 1
		if(R.rank_req != TECH_RANK_FOR(R.tier)) badrank += "[R.id] tier [R.tier] rank [R.rank_req]"
		var/list/ins = list()
		var/datum/craft_recipe/lifecraft/tech/TR = R
		var/list/items = istype(TR) ? TR.item_inputs : null
		if((!R.slots || !R.slots.len) && !length(items)) badsel += "[R.id] has no inputs"
		else if(R.slots)
			for(var/datum/craft_slotreq/S in R.slots)
				ins += S.Describe()
				var/hit = 0
				for(var/mc in LifeMatRegistry)
					if(S.Accepts(mc))
						hit = 1
						break
				if(!hit) badsel += "[R.id] slot [S.name] ([S.Describe()])"
		for(var/p in items)
			ins += "[items[p]]x [TechItemName(p)] (item)"
			if(!ispath(p, /obj/Items) || !isnum(items[p]) || items[p] < 1) badsel += "[R.id] item input [p]"
		out += "[R.id] | [R.label] | [node] | tier [R.tier] | rank [R.rank_req] | [R.station ? R.station : "anywhere"] | [jointext(ins, ", ")]"
	var/list/nodeline = list()
	for(var/n in pernode)
		nodeline += "[n] [pernode[n]]"
	var/list/unowned = list()
	var/list/excluded = list()
	for(var/T in typesof(/obj/Items/Tech) + typesof(/obj/Items/Gear))
		if(made[T]) continue
		var/why = TECH_AUDIT_EXCLUDE[T]
		if(why)
			excluded += "[T] ([why])"
			continue
		unowned += "[T]"
	out += "Recipes: [recipes.len] ([nfield] field crafts, [recipes.len - nfield] at the Workbench)"
	out += "Recipes per node: [jointext(nodeline, ", ")]"
	out += "Knowledge that is not a node ([badnode.len]): [badnode.len ? jointext(badnode, "; ") : "none"]"
	out += "Selectors that match nothing ([badsel.len]): [badsel.len ? jointext(badsel, "; ") : "none"]"
	out += "Results that are not compiled items ([badtype.len]): [badtype.len ? jointext(badtype, "; ") : "none"]"
	out += "Rank that disagrees with tier ([badrank.len]): [badrank.len ? jointext(badrank, "; ") : "none"]"
	out += "Tech and Gear items with no recipe and no owner ([unowned.len]): [unowned.len ? jointext(unowned, "; ") : "none"]"
	out += "Excluded, with the reason ([excluded.len]): [excluded.len ? jointext(excluded, "; ") : "none"]"
	return out

mob/Admin4/verb/techRecipeAudit()
	set category = "Admin"
	set name = "Technology Recipe Audit"
	for(var/line in TechRecipeAuditLines())
		src << line

mob/Admin4/verb/techGiveMaterials()
	set category = "Admin"
	RegisterLifeMaterials()
	var/list/recipes = LifeCraftRecipes("Technology")
	var/n = 0
	for(var/mc in LifeMatRegistry)
		var/datum/matdef/d = LifeMatRegistry[mc]
		if(!d || ispath(d.mtype, /obj/Items/Material/Part)) continue
		var/wanted = 0
		for(var/datum/craft_recipe/lifecraft/R in recipes)
			if(!R.slots) continue
			for(var/datum/craft_slotreq/S in R.slots)
				if(S.Accepts(mc))
					wanted = 1
					break
			if(wanted) break
		if(!wanted) continue
		MatLogAdd(mc, QUAL_NORMAL, 20)
		n++
	src << "Stocked [n] raw Technology materials, 20 Normal of each. The parts are yours to craft."

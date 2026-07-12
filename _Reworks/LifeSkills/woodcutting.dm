var/global/list/LifeTreeNodes = list()

/datum/tree_def
	var/id
	var/name
	var/tier = 1
	var/difficulty = 1
	var/wood_type
	var/fruit_type

var/list/LifeTreeDefs = list()

proc/LifeTreeAdd(id, name, tier, wood_type, fruit_type)
	var/datum/tree_def/d = new
	d.id = id
	d.name = name
	d.tier = tier
	d.difficulty = LIFE_HUNT_DIFF(tier)
	d.wood_type = wood_type
	d.fruit_type = fruit_type
	LifeTreeDefs[id] = d

proc/RegisterTrees()
	if(LifeTreeDefs.len) return
	LifeTreeAdd("apple_green",  "Apple Tree",   1, /obj/Items/Material/Wood/wood_apple,   /obj/Items/Material/Fruit/fruit_apple_green)
	LifeTreeAdd("apple_red",    "Apple Tree",   1, /obj/Items/Material/Wood/wood_apple,   /obj/Items/Material/Fruit/fruit_apple_red)
	LifeTreeAdd("apple_yellow", "Apple Tree",   1, /obj/Items/Material/Wood/wood_apple,   /obj/Items/Material/Fruit/fruit_apple_yellow)
	LifeTreeAdd("pear",         "Pear Tree",    2, /obj/Items/Material/Wood/wood_pear,    /obj/Items/Material/Fruit/fruit_pear)
	LifeTreeAdd("peach",        "Peach Tree",   3, /obj/Items/Material/Wood/wood_peach,   /obj/Items/Material/Fruit/fruit_peach)
	LifeTreeAdd("orange",       "Orange Tree",  3, /obj/Items/Material/Wood/wood_orange,  /obj/Items/Material/Fruit/fruit_orange)
	LifeTreeAdd("apricot",      "Apricot Tree", 4, /obj/Items/Material/Wood/wood_apricot, /obj/Items/Material/Fruit/fruit_apricot)
	LifeTreeAdd("plum",         "Plum Tree",    4, /obj/Items/Material/Wood/wood_plum,    /obj/Items/Material/Fruit/fruit_plum)

proc/LifeTreeDef(id)
	RegisterTrees()
	return LifeTreeDefs[id]

/obj/LifeSkills/Tree
	name = "Tree"
	icon = 'Icons/LifeSkills/TreeNodes.dmi'
	density = 1
	layer = OBJ_LAYER
	var/tree_id = "apple_green"
	var/charges = 4
	var/max_charges = 4
	var/depleted = FALSE
	var/growth_stage = 5     // 0 = stump, LIFE_TREE_STAGES-1 = grown
	var/tmp/mob/chopping_by

	New()
		..()
		LifeTreeNodes += src

	Del()
		LifeTreeNodes -= src
		..()

	proc/Setup(id)
		var/datum/tree_def/d = LifeTreeDef(id)
		if(!d) return 0
		tree_id = id
		growth_stage = LIFE_TREE_STAGES - 1
		icon_state = "[id]_s[growth_stage]"
		name = d.name
		desc = "A tree ripe for felling. Face it and press your Interact key to chop."
		charges = rand(3, 5)
		max_charges = charges
		return 1

	// felled
	proc/Deplete()
		depleted = TRUE
		density = 0
		growth_stage = 0
		var/matrix/fellM = matrix()
		fellM.Translate(0, 26)                // pivot at the root flare (~6px above the tapered tip)
		fellM.Turn(88 * pick(-1, 1))          // topple left or right, ~sideways
		fellM.Translate(0, -26)
		animate(src, transform = fellM, time = 16, easing = SINE_EASING)   // ~1.6s gradual fall
		animate(alpha = 0, time = 8)                                       // then fade out
		spawn(26)
			transform = null
			alpha = 255
			icon_state = "[tree_id]_s0"
			LifeScheduler.schedule(new/Event/TreeGrow(src), LIFE_SEC2EVT(round(LIFE_TREE_GROW_SECS / (LIFE_TREE_STAGES - 1))))

	proc/Grow()
		growth_stage++
		icon_state = "[tree_id]_s[growth_stage]"
		if(growth_stage >= LIFE_TREE_STAGES - 1)
			// choppable again
			depleted = FALSE
			density = 1
			charges = rand(3, 5)
			max_charges = charges
		else
			LifeScheduler.schedule(new/Event/TreeGrow(src), LIFE_SEC2EVT(round(LIFE_TREE_GROW_SECS / (LIFE_TREE_STAGES - 1))))

	Click()
		if(!usr || depleted) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the [name]."
			return
		usr.StartChop(src)

	InteractWith(mob/M)
		if(depleted) return 0
		if(get_dist(M, src) > 1) return 0
		M.StartChop(src)
		return 1

	Examined(mob/user)
		..()
		var/datum/tree_def/d = LifeTreeDef(tree_id)
		if(!d) return
		var/rank = user.LifeRank("Foraging")
		if(!LIFE_GATHER_GATE_OK(rank, d.difficulty))
			user << "<font color=#ff6464>Tier [d.tier] timber. Too tough for you - Foraging rank [d.difficulty - 1] required.</font>"
			return
		var/col = "#78eb78"
		var/word = "easy timber"
		if(d.difficulty - rank >= 1)
			col = "#ffd86b"
			word = "hard wood - it'll take some work"
		user << "<font color='[col]'>Tier [d.tier] timber. This looks like [word].</font>"

Event/TreeGrow
	var/obj/LifeSkills/Tree/tree
	New(t)
		tree = t
	fire()
		..()
		if(tree && tree.depleted)
			tree.Grow()

mob/proc/StartChop(obj/LifeSkills/Tree/T)
	if(!T || T.depleted || !client) return
	if(KO || Dead) return
	if(Using)
		src << "You're in the middle of something."
		return
	if(client.life_minigame_sink) return
	if(T.chopping_by && T.chopping_by != src)
		src << "Someone's already working that tree."
		return
	var/datum/tree_def/d = LifeTreeDef(T.tree_id)
	if(!d) return
	var/rank = LifeRank("Foraging")
	if(!LIFE_GATHER_GATE_OK(rank, d.difficulty))
		src << "<font color=#ff6464>This timber is too tough for you. (Foraging rank [d.difficulty - 1] required)</font>"
		return
	if(!UseLifeStamina(LIFE_COST_GATHER)) return
	T.chopping_by = src
	Using = 1
	var/obj/Items/LifeTool/tool = GetBestLifeTool(src, "Axe")
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * d.difficulty + LIFE_SPEED_PER_UNDER * max(0, d.difficulty - rank) - LIFE_SPEED_PER_OVER * max(0, rank - d.difficulty), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	if(tool) speed *= max(0.7, 1 - tool.SweetSpotBonus)
	var/list/opts = list("speed_mult" = speed, "target" = T)
	var/total = 0
	var/finished = 0
	var/aborted = 0
	for(var/i = 1 to LIFE_CHOP_STRIKES)
		var/p = RunLifeMinigame(src, "timing_bar", d.difficulty, opts)
		if(p < 0)
			aborted = 1
			break
		total += p
		finished++
	Using = 0
	if(T) T.chopping_by = null
	if(aborted || !finished)
		src << "You stop chopping."
		return
	ChopPayout(T, d, total / LIFE_CHOP_STRIKES, tool, rank)

mob/proc/ChopPayout(obj/LifeSkills/Tree/T, datum/tree_def/d, perf, obj/Items/LifeTool/tool, rank)
	if(!T || !d) return
	perf = max(perf, LIFE_PERF_MIN)
	perf = min(perf, LIFE_PERF_MAX)

	var/q = QUAL_NORMAL
	if(perf >= 1.4) q++
	if(perf < 0.7) q--
	if(prob(2 * rank)) q++
	if(tool && prob(tool.QualityBonus)) q++
	q = min(q, LifeQualityCap(rank))
	q = QualityClamp(q)

	var/amt = max(1, round(LIFE_WOOD_BASE_YIELD * perf + (tool ? tool.YieldBonus : 0)))
	var/obj/Items/Material/Wood/ws = new d.wood_type
	var/wname = ws.name
	del ws
	GiveMaterial(src, d.wood_type, amt, q)
	src << "<font color=#78eb78>You chop loose [amt]x [QualityName(q)] [wname].</font>"
	LifeLogFind("Foraging", wname)

	// fruit trees also shed some fruit
	if(d.fruit_type)
		var/famt = max(1, round(perf))
		var/obj/Items/Material/Fruit/fs = new d.fruit_type
		var/fname = fs.name
		del fs
		GiveMaterial(src, d.fruit_type, famt, q)
		src << "<font color=#b6eb78>[famt]x [fname] falls from the branches.</font>"
		LifeLogFind("Foraging", fname)

	if(tool) tool.LifeToolWear(src)
	AddLifeXP("Foraging", LifeGatherXP("Foraging", d.tier), perf)
	LifeOppRoll("Foraging", d.tier, d.wood_type, q)
	T.charges--
	if(T.charges <= 0)
		src << "The [T.name] is felled to a stump."
		T.Deplete()

// seeding
proc/LifePickSeedTree()
	RegisterTrees()
	var/total = 0
	for(var/id in LifeTreeDefs)
		var/datum/tree_def/d = LifeTreeDefs[id]
		total += LifeOreSeedWeight(d.difficulty)
	var/roll = rand(1, total)
	for(var/id in LifeTreeDefs)
		var/datum/tree_def/d = LifeTreeDefs[id]
		roll -= LifeOreSeedWeight(d.difficulty)
		if(roll <= 0) return id
	return "apple_green"

proc/SeedTrees()
	set background = 1 
	RegisterTrees()
	for(var/obj/LifeSkills/Tree/old in world)
		del old
	var/seeded = 0
	for(var/z = 1 to world.maxz)
		var/list/candidates = list()
		for(var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(T.density || T.Water || T.Lava) continue
			if(T.SecondaryTurfType != "Grass") continue
			candidates += T
		var/want = min(round(candidates.len / LIFE_TREE_DENSITY), LIFE_NODE_ZCAP)
		while(want > 0 && candidates.len)
			var/turf/T = pick(candidates)
			candidates -= T
			if(locate(/obj) in T) continue
			var/obj/LifeSkills/Tree/N = new(T)
			N.Setup(LifePickSeedTree())
			seeded++
			want--
		sleep(-1)
	world.log << "//\[info]: Seeded [seeded] trees."

mob/Admin4/verb/makeTree(id as text)
	set category = "Admin"
	RegisterTrees()
	if(!LifeTreeDefs[id])
		src << "No such tree. Valid: [jointext(LifeTreeDefs, ", ")]"
		return
	var/obj/LifeSkills/Tree/N = new(get_step(src, src.dir))
	N.Setup(id)
	src << "Placed \a [N.name]."

mob/Admin4/verb/reseedTrees()
	set category = "Admin"
	src << "Reseeding trees..."
	spawn() SeedTrees()

/obj/Items/Material/Wood
	icon = 'Icons/LifeSkills/TreeMats.dmi'
	desc = "Seasoned timber. Good for building and crafting."
	var/tier = 1

/obj/Items/Material/Fruit
	icon = 'Icons/LifeSkills/TreeMats.dmi'
	desc = "Fresh fruit. A cook will want it."
	var/tier = 1

/obj/Items/Material/Wood/wood_apple { name = "Applewood"; MaterialClass = "Applewood"; icon_state = "wood_apple"; tier = 1 }
/obj/Items/Material/Wood/wood_pear { name = "Pearwood"; MaterialClass = "Pearwood"; icon_state = "wood_pear"; tier = 2 }
/obj/Items/Material/Wood/wood_peach { name = "Peachwood"; MaterialClass = "Peachwood"; icon_state = "wood_peach"; tier = 3 }
/obj/Items/Material/Wood/wood_orange { name = "Orangewood"; MaterialClass = "Orangewood"; icon_state = "wood_orange"; tier = 3 }
/obj/Items/Material/Wood/wood_apricot { name = "Apricot Wood"; MaterialClass = "ApricotWood"; icon_state = "wood_apricot"; tier = 4 }
/obj/Items/Material/Wood/wood_plum { name = "Plumwood"; MaterialClass = "Plumwood"; icon_state = "wood_plum"; tier = 4 }
/obj/Items/Material/Fruit/fruit_apple_green { name = "Green Apple"; MaterialClass = "GreenApple"; icon_state = "fruit_apple_green"; tier = 1 }
/obj/Items/Material/Fruit/fruit_apple_red { name = "Red Apple"; MaterialClass = "RedApple"; icon_state = "fruit_apple_red"; tier = 1 }
/obj/Items/Material/Fruit/fruit_apple_yellow { name = "Yellow Apple"; MaterialClass = "YellowApple"; icon_state = "fruit_apple_yellow"; tier = 1 }
/obj/Items/Material/Fruit/fruit_pear { name = "Pear"; MaterialClass = "Pear"; icon_state = "fruit_pear"; tier = 2 }
/obj/Items/Material/Fruit/fruit_peach { name = "Peach"; MaterialClass = "Peach"; icon_state = "fruit_peach"; tier = 3 }
/obj/Items/Material/Fruit/fruit_orange { name = "Orange"; MaterialClass = "Orange"; icon_state = "fruit_orange"; tier = 3 }
/obj/Items/Material/Fruit/fruit_apricot { name = "Apricot"; MaterialClass = "Apricot"; icon_state = "fruit_apricot"; tier = 4 }
/obj/Items/Material/Fruit/fruit_plum { name = "Plum"; MaterialClass = "Plum"; icon_state = "fruit_plum"; tier = 4 }

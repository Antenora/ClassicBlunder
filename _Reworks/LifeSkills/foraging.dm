var/global/list/LifeForageNodes = list()

// which plant art sits on a patch. tier drives difficulty + the flora it can drop.
/datum/plant_def
	var/id
	var/name
	var/tier = 1
	var/difficulty = 1
	var/icon_file

var/list/LifePlantDefs = list()

proc/LifePlantAdd(id, name, tier, icon_file)
	var/datum/plant_def/d = new
	d.id = id
	d.name = name
	d.tier = tier
	d.difficulty = LIFE_HUNT_DIFF(tier)      // tier*2-1, shared 1..10 scale
	d.icon_file = icon_file
	LifePlantDefs[id] = d

proc/InitLifePlantDefs()
	if(LifePlantDefs.len) return
	// tier 1
	LifePlantAdd("plains_bush",    "Wild Bush",       1, 'Icons/LifeSkills/ForageNodes/plains_bush.png')
	LifePlantAdd("smol_mushroom",  "Toadstools",      1, 'Icons/LifeSkills/ForageNodes/smol_mushroom.png')
	LifePlantAdd("yellow_flowers", "Yellow Blooms",   1, 'Icons/LifeSkills/ForageNodes/yellow_flowers.png')
	LifePlantAdd("red_flowers",    "Red Blooms",      1, 'Icons/LifeSkills/ForageNodes/red_flowers.png')
	// tier 2
	LifePlantAdd("medium_mushroom","Mushroom Ring",   2, 'Icons/LifeSkills/ForageNodes/medium_mushroom.png')
	LifePlantAdd("bluebells",      "Wild Bluebells",  2, 'Icons/LifeSkills/ForageNodes/bluebells.png')
	LifePlantAdd("pink_blooms",    "Pink Blooms",     2, 'Icons/LifeSkills/ForageNodes/pink_blooms.png')
	// tier 3
	LifePlantAdd("bigger_mushroom","Tall Mushroom",   3, 'Icons/LifeSkills/ForageNodes/bigger_mushroom.png')
	LifePlantAdd("bigger_flowers", "Wildflowers",     3, 'Icons/LifeSkills/ForageNodes/bigger_flowers.png')
	LifePlantAdd("jungle_bush",    "Jungle Shrub",    3, 'Icons/LifeSkills/ForageNodes/jungle_bush.png')
	// tier 4
	LifePlantAdd("rose_bush",      "Rose Bush",       4, 'Icons/LifeSkills/ForageNodes/rose_bush.png')
	LifePlantAdd("pitcher_plant",  "Pitcher Plant",   4, 'Icons/LifeSkills/ForageNodes/pitcher_plant.png')
	// tier 5 - the magical growths
	LifePlantAdd("glow_plant",     "Glowbloom",       5, 'Icons/LifeSkills/ForageNodes/glow_plant.png')
	LifePlantAdd("magic_tree",     "Spirit Sapling",  5, 'Icons/LifeSkills/ForageNodes/magic_tree.png')

proc/LifePlantDef(id)
	InitLifePlantDefs()
	return LifePlantDefs[id]

// flora drop pool cached by tier, read off the item defs' tier var
var/list/LifeFloraTierPool = list()
proc/InitFloraTierPool()
	if(LifeFloraTierPool.len) return
	for(var/T in typesof(/obj/Items/Material/Flora) - /obj/Items/Material/Flora)
		var/obj/Items/Material/Flora/f = new T
		if(!f.MaterialClass) { del f; continue }
		var/key = "[f.tier]"
		if(!LifeFloraTierPool[key]) LifeFloraTierPool[key] = list()
		LifeFloraTierPool[key] += T
		del f

proc/LifeFloraPoolForTier(tier)
	InitFloraTierPool()
	var/list/p = LifeFloraTierPool["[tier]"]
	if((!p || !p.len) && tier > 1) return LifeFloraPoolForTier(tier - 1)
	return p ? p : list()

// the node
/obj/LifeSkills/ForageNode
	name = "Plant"
	density = 0
	layer = OBJ_LAYER
	var/plant_id = "plains_bush"
	var/charges = 3
	var/max_charges = 3
	var/depleted = FALSE
	var/tmp/mob/gathering_by

	New()
		..()
		LifeForageNodes += src

	Del()
		LifeForageNodes -= src
		..()

	proc/Setup(id)
		var/datum/plant_def/d = LifePlantDef(id)
		if(!d) return 0
		plant_id = id
		icon = d.icon_file
		icon_state = ""
		name = d.name
		desc = "A foraging spot. Face it and press your Interact key to gather."
		charges = rand(LIFE_NODE_CHARGES_MIN, LIFE_NODE_CHARGES_MAX)
		max_charges = charges
		UpdateStage()
		return 1

	proc/UpdateStage()
		if(depleted)
			alpha = 0
			mouse_opacity = 0
			return
		alpha = 255
		mouse_opacity = 1

	proc/Deplete()
		depleted = TRUE
		UpdateStage()
		LifeScheduler.schedule(new/Event/ForageRespawn(src), LIFE_SEC2EVT(LIFE_NODE_RESPAWN_SECS))

	proc/Respawn()
		depleted = FALSE
		charges = rand(LIFE_NODE_CHARGES_MIN, LIFE_NODE_CHARGES_MAX)
		max_charges = charges
		UpdateStage()

	Click()
		if(!usr || depleted) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the [name]."
			return
		usr.StartForage(src)

	InteractWith(mob/M)
		if(depleted) return 0
		if(get_dist(M, src) > 1) return 0
		M.StartForage(src)
		return 1

	Examined(mob/user)
		..()
		var/datum/plant_def/d = LifePlantDef(plant_id)
		if(!d) return
		var/rank = user.LifeRank("Foraging")
		if(!LIFE_GATHER_GATE_OK(rank, d.difficulty))
			user << "<font color=#ff6464>Tier [d.tier] growth. You lack the knowledge - Foraging rank [d.difficulty - 1] required.</font>"
			return
		var/col = "#78eb78"
		var/word = "an easy pick"
		if(d.difficulty - rank >= 1)
			col = "#ffd86b"
			word = "a delicate pick, a steady hand is needed"
		user << "<font color='[col]'>Tier [d.tier] growth. This looks like [word].</font>"

Event/ForageRespawn
	var/obj/LifeSkills/ForageNode/node
	New(n)
		node = n
	fire()
		..()
		if(node && node.depleted)
			node.Respawn()

mob/proc/StartForage(obj/LifeSkills/ForageNode/N)
	if(!N || N.depleted || !client) return
	if(KO || Dead) return
	if(Using)
		src << "You're in the middle of something."
		return
	if(client.life_minigame_sink) return
	if(N.gathering_by && N.gathering_by != src)
		src << "Someone's already working that patch."
		return
	var/datum/plant_def/d = LifePlantDef(N.plant_id)
	if(!d) return
	var/rank = LifeRank("Foraging")
	if(!LIFE_GATHER_GATE_OK(rank, d.difficulty))
		src << "<font color=#ff6464>This growth is beyond you. (Foraging rank [d.difficulty - 1] required)</font>"
		return
	if(!UseLifeStamina(LIFE_COST_GATHER)) return
	N.gathering_by = src
	Using = 1
	var/obj/Items/LifeTool/tool = GetBestLifeTool(src, "Sickle")
	var/need = LIFE_FORAGE_NEED(d.difficulty)
	if(tool) need = max(3, round(need * max(0.6, 1 - tool.SweetSpotBonus)))
	var/list/opts = list("target" = N, "need" = need, "limit" = LIFE_FORAGE_TIME(d.difficulty, rank))
	var/perf = RunLifeMinigame(src, "hold_fill", d.difficulty, opts)
	Using = 0
	if(N) N.gathering_by = null
	if(perf < 0)
		src << "You stop gathering."
		return
	ForagePayout(N, d, perf, tool, rank)

mob/proc/ForagePayout(obj/LifeSkills/ForageNode/N, datum/plant_def/d, perf, obj/Items/LifeTool/tool, rank)
	if(!N || !d) return
	perf = max(perf, LIFE_PERF_MIN)
	perf = min(perf, LIFE_PERF_MAX)

	var/q = QUAL_NORMAL
	if(perf >= 1.4) q++
	if(perf < 0.7) q--
	if(prob(2 * rank)) q++
	if(tool && prob(tool.QualityBonus)) q++
	q = min(q, LifeQualityCap(rank))
	if(q >= QUAL_LEGENDARY)
		var/legchance = LIFE_GATHER_LEG_BASE + max(0, rank - 8)
		if(perf >= 1.4) legchance += 1
		if(!prob(legchance)) q = QUAL_EPIC
	q = QualityClamp(q)

	var/list/pool = LifeFloraPoolForTier(d.tier)
	if(pool.len)
		var/ftype = pick(pool)
		var/obj/Items/Material/Flora/sample = new ftype
		var/fname = sample.name
		del sample
		var/amt = max(1, round(LIFE_FORAGE_BASE_YIELD * perf + (tool ? tool.YieldBonus : 0)))
		GiveMaterial(src, ftype, amt, q)
		src << "<font color=#78eb78>You gather [amt]x [QualityName(q)] [fname].</font>"
		LifeLogFind("Foraging", fname)
		LifeOppRoll("Foraging", d.tier, ftype, q)

	// Botanist's Eye: rank 10 turns up a rare specimen once a day
	if(rank >= LIFE_MAX_RANK && LifeBloomDay != DaysOfWipe())
		LifeBloomDay = DaysOfWipe()
		var/list/rare = LifeFloraPoolForTier(5)
		if(rare.len)
			var/rtype = pick(rare)
			var/obj/Items/Material/Flora/rs = new rtype
			var/rn = rs.name
			del rs
			GiveMaterial(src, rtype, 1, min(q + 1, LifeQualityCap(rank)))
			src << "<b>Botanist's Eye - you spot a rare [rn] others would miss.</b>"
			LifeLogFind("Foraging", rn)

	if(tool) tool.LifeToolWear(src)
	AddLifeXP("Foraging", LifeGatherXP("Foraging", d.tier), perf)
	N.charges--
	if(N.charges <= 0)
		src << "The [N.name] is picked clean."
		N.Deplete()

// world seeding
proc/LifePickSeedPlant()
	InitLifePlantDefs()
	var/total = 0
	for(var/id in LifePlantDefs)
		var/datum/plant_def/d = LifePlantDefs[id]
		total += LifeOreSeedWeight(d.difficulty)      
	var/roll = rand(1, total)
	for(var/id in LifePlantDefs)
		var/datum/plant_def/d = LifePlantDefs[id]
		roll -= LifeOreSeedWeight(d.difficulty)
		if(roll <= 0) return id
	return "plains_bush"

proc/SeedForageNodes()
	set background = 1   
	InitLifePlantDefs()
	for(var/obj/LifeSkills/ForageNode/old in world)
		del old
	var/seeded = 0
	for(var/z = 1 to world.maxz)
		var/list/candidates = list()
		for(var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(T.density || T.Water || T.Lava) continue
			if(T.SecondaryTurfType != "Grass") continue
			candidates += T
		var/want = min(round(candidates.len / LIFE_NODE_DENSITY), LIFE_NODE_ZCAP)
		while(want > 0 && candidates.len)
			var/turf/T = pick(candidates)
			candidates -= T
			if(locate(/obj) in T) continue
			var/obj/LifeSkills/ForageNode/N = new(T)
			N.Setup(LifePickSeedPlant())
			seeded++
			want--
		sleep(-1)
	world.log << "//\[info]: Seeded [seeded] foraging nodes."

mob/Admin4/verb/makeForageNode(id as text)
	set category = "Admin"
	InitLifePlantDefs()
	if(!LifePlantDefs[id])
		src << "No such plant. Valid: [jointext(LifePlantDefs, ", ")]"
		return
	var/obj/LifeSkills/ForageNode/N = new(get_step(src, src.dir))
	N.Setup(id)
	src << "Placed \a [N.name]."

mob/Admin4/verb/reseedForageNodes()
	set category = "Admin"
	src << "Reseeding foraging nodes..."
	spawn() SeedForageNodes()

/obj/Items/Material/Flora
	icon = 'Icons/LifeSkills/ForagingMats.dmi'
	desc = "A foraged plant. Alchemists and cooks prize these."
	var/tier = 1

/obj/Items/Material/Flora/red_herb { name = "Red Herb"; MaterialClass = "RedHerb"; icon_state = "red_herb"; tier = 1 }
/obj/Items/Material/Flora/green_herb { name = "Green Herb"; MaterialClass = "GreenHerb"; icon_state = "green_herb"; tier = 1 }
/obj/Items/Material/Flora/broadleaf { name = "Broadleaf"; MaterialClass = "Broadleaf"; icon_state = "broadleaf"; tier = 1 }
/obj/Items/Material/Flora/wild_grass { name = "Wild Grass"; MaterialClass = "WildGrass"; icon_state = "wild_grass"; tier = 1 }
/obj/Items/Material/Flora/marigold { name = "Marigold"; MaterialClass = "Marigold"; icon_state = "marigold"; tier = 1 }
/obj/Items/Material/Flora/brown_cap { name = "Brown Cap"; MaterialClass = "BrownCap"; icon_state = "brown_cap"; tier = 1 }
/obj/Items/Material/Flora/common_root { name = "Common Root"; MaterialClass = "CommonRoot"; icon_state = "common_root"; tier = 1 }
/obj/Items/Material/Flora/cave_carrot { name = "Cave Carrot"; MaterialClass = "CaveCarrot"; icon_state = "cave_carrot"; tier = 1 }
/obj/Items/Material/Flora/golden_herb { name = "Golden Herb"; MaterialClass = "GoldenHerb"; icon_state = "golden_herb"; tier = 2 }
/obj/Items/Material/Flora/olive_herb { name = "Olive Herb"; MaterialClass = "OliveHerb"; icon_state = "olive_herb"; tier = 2 }
/obj/Items/Material/Flora/green_leaf { name = "Green Leaf"; MaterialClass = "GreenLeaf"; icon_state = "green_leaf"; tier = 2 }
/obj/Items/Material/Flora/daisy { name = "Daisy"; MaterialClass = "Daisy"; icon_state = "daisy"; tier = 2 }
/obj/Items/Material/Flora/blue_cap { name = "Blue Cap"; MaterialClass = "BlueCap"; icon_state = "blue_cap"; tier = 2 }
/obj/Items/Material/Flora/lily_pad { name = "Lily Pad"; MaterialClass = "LilyPad"; icon_state = "lily_pad"; tier = 2 }
/obj/Items/Material/Flora/wild_berries { name = "Wild Berries"; MaterialClass = "WildBerries"; icon_state = "wild_berries"; tier = 2 }
/obj/Items/Material/Flora/forest_nut { name = "Forest Nut"; MaterialClass = "ForestNut"; icon_state = "forest_nut"; tier = 2 }
/obj/Items/Material/Flora/mint_sprig { name = "Mint Sprig"; MaterialClass = "MintSprig"; icon_state = "mint_sprig"; tier = 3 }
/obj/Items/Material/Flora/frost_herb { name = "Frost Herb"; MaterialClass = "FrostHerb"; icon_state = "frost_herb"; tier = 3 }
/obj/Items/Material/Flora/waxleaf { name = "Waxleaf"; MaterialClass = "Waxleaf"; icon_state = "waxleaf"; tier = 3 }
/obj/Items/Material/Flora/cornflower { name = "Cornflower"; MaterialClass = "Cornflower"; icon_state = "cornflower"; tier = 3 }
/obj/Items/Material/Flora/field_mushroom { name = "Field Mushroom"; MaterialClass = "FieldMushroom"; icon_state = "field_mushroom"; tier = 3 }
/obj/Items/Material/Flora/morel { name = "Morel"; MaterialClass = "Morel"; icon_state = "morel"; tier = 3 }
/obj/Items/Material/Flora/jungle_vine { name = "Jungle Vine"; MaterialClass = "JungleVine"; icon_state = "jungle_vine"; tier = 3 }
/obj/Items/Material/Flora/golden_pollen { name = "Golden Pollen"; MaterialClass = "GoldenPollen"; icon_state = "golden_pollen"; tier = 3 }
/obj/Items/Material/Flora/blushbloom { name = "Blushbloom"; MaterialClass = "Blushbloom"; icon_state = "blushbloom"; tier = 4 }
/obj/Items/Material/Flora/witchweed { name = "Witchweed"; MaterialClass = "Witchweed"; icon_state = "witchweed"; tier = 4 }
/obj/Items/Material/Flora/nightleaf { name = "Nightleaf"; MaterialClass = "Nightleaf"; icon_state = "nightleaf"; tier = 4 }
/obj/Items/Material/Flora/white_bloom { name = "White Bloom"; MaterialClass = "WhiteBloom"; icon_state = "white_bloom"; tier = 4 }
/obj/Items/Material/Flora/toadstool { name = "Toadstool"; MaterialClass = "Toadstool"; icon_state = "toadstool"; tier = 4 }
/obj/Items/Material/Flora/emperor_cap { name = "Emperor Cap"; MaterialClass = "EmperorCap"; icon_state = "emperor_cap"; tier = 4 }
/obj/Items/Material/Flora/cursed_cherries { name = "Cursed Cherries"; MaterialClass = "CursedCherries"; icon_state = "cursed_cherries"; tier = 4 }
/obj/Items/Material/Flora/honeycomb { name = "Wild Honeycomb"; MaterialClass = "Honeycomb"; icon_state = "honeycomb"; tier = 4 }
/obj/Items/Material/Flora/ashwort { name = "Ashwort"; MaterialClass = "Ashwort"; icon_state = "ashwort"; tier = 5 }
/obj/Items/Material/Flora/moonwort { name = "Moonwort"; MaterialClass = "Moonwort"; icon_state = "moonwort"; tier = 5 }
/obj/Items/Material/Flora/gloomvine { name = "Gloomvine"; MaterialClass = "Gloomvine"; icon_state = "gloomvine"; tier = 5 }
/obj/Items/Material/Flora/starflower { name = "Starflower"; MaterialClass = "Starflower"; icon_state = "starflower"; tier = 5 }
/obj/Items/Material/Flora/crimson_orchid { name = "Crimson Orchid"; MaterialClass = "CrimsonOrchid"; icon_state = "crimson_orchid"; tier = 5 }
/obj/Items/Material/Flora/glowshroom { name = "Glowshroom"; MaterialClass = "Glowshroom"; icon_state = "glowshroom"; tier = 5 }
/obj/Items/Material/Flora/fae_mushroom { name = "Fae Mushroom"; MaterialClass = "FaeMushroom"; icon_state = "fae_mushroom"; tier = 5 }
/obj/Items/Material/Flora/rainbow_petal { name = "Rainbow Petal"; MaterialClass = "RainbowPetal"; icon_state = "rainbow_petal"; tier = 5 }
/obj/Items/Material/Flora/golden_apple { name = "Golden Apple"; MaterialClass = "GoldenApple"; icon_state = "golden_apple"; tier = 5 }
/obj/Items/Material/Flora/everflame_bud { name = "Everflame Bud"; MaterialClass = "EverflameBud"; icon_state = "everflame_bud"; tier = 5 }
/obj/Items/Material/Flora/strange_fruit { name = "Strange Fruit"; MaterialClass = "StrangeFruit"; icon_state = "strange_fruit"; tier = 5 }

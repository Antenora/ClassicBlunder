// Ore veins. Currently auto-seeded on Dirt/Sand each boot and not saved, plus admin spawners. May change

var/global/list/LifeOreNodes = list()
var/global/tmp/EventScheduler/LifeScheduler = new()

/obj/LifeSkills
	Savable = 0
	Destructable = 0   
	Attackable = 0

/obj/LifeSkills/OreNode
	name = "Ore Vein"
	icon = 'Icons/LifeSkills/Nodes.dmi'
	density = 1
	var/ore_id = "copper"
	var/charges = 4
	var/max_charges = 4
	var/depleted = FALSE
	var/tmp/mob/mining_by

	New()
		..()
		LifeOreNodes += src

	Del()
		LifeOreNodes -= src
		..()

	proc/Setup(id)
		var/datum/ore_def/d = LifeOreDef(id)
		if(!d) return 0
		ore_id = id
		switch(d.kind)
			if("gem") name = "[d.name] Deposit"
			if("utility") name = "[d.name] Deposit"
			else name = "[d.name] Vein"
		desc = "A workable [lowertext(name)]. Face it and press your Interact key to mine."
		charges = rand(LIFE_NODE_CHARGES_MIN, LIFE_NODE_CHARGES_MAX)
		max_charges = charges
		UpdateStage()
		return 1

	proc/UpdateStage()
		if(depleted)
			alpha = 0
			density = 0
			mouse_opacity = 0
			return
		alpha = 255
		density = 1
		mouse_opacity = 1
		var/st = 3
		if(charges / max_charges > 0.66) st = 1
		else if(charges / max_charges > 0.33) st = 2
		icon_state = "[ore_id]_[st]"

	proc/Deplete()
		depleted = TRUE
		UpdateStage()
		LifeScheduler.schedule(new/Event/OreRespawn(src), LIFE_SEC2EVT(LIFE_NODE_RESPAWN_SECS))

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
		usr.StartMining(src)

	InteractWith(mob/M)
		if(depleted) return 0
		if(get_dist(M, src) > 1) return 0
		M.StartMining(src)
		return 1

	Examined(mob/user)
		..()
		var/datum/ore_def/d = LifeOreDef(ore_id)
		if(!d) return
		var/rank = user.LifeRank("Mining")
		var/rich = "rich"
		if(charges / max_charges <= 0.33) rich = "nearly spent"
		else if(charges / max_charges <= 0.66) rich = "worked"
		if(!LIFE_MINE_GATE_OK(rank, d.difficulty))
			user << "<font color=#ff6464>Tier [d.tier] - difficulty [d.difficulty]. You cannot work this - Mining rank [d.difficulty - 1] required. The vein is [rich].</font>"
			return
		var/col = "#78eb78"
		var/word = "an easy dig"
		if(d.difficulty - rank >= 1)
			col = "#ffd86b"
			word = "a stretch - strikes can come up empty"
		user << "<font color='[col]'>Tier [d.tier] - difficulty [d.difficulty]. This looks like [word]. The vein is [rich].</font>"

Event/OreRespawn
	var/obj/LifeSkills/OreNode/node
	New(n)
		node = n
	fire()
		..()
		if(node && node.depleted)
			node.Respawn()

proc/LifePickSeedOre()
	InitLifeOreDefs()
	var/total = 0
	for(var/id in LifeOreDefs)
		var/datum/ore_def/d = LifeOreDefs[id]
		total += LifeOreSeedWeight(d.difficulty)
	var/roll = rand(1, total)
	for(var/id in LifeOreDefs)
		var/datum/ore_def/d = LifeOreDefs[id]
		roll -= LifeOreSeedWeight(d.difficulty)
		if(roll <= 0) return id
	return "copper"

proc/SeedLifeSkillNodes()
	set background = 1
	InitLifeOreDefs()
	for(var/obj/LifeSkills/OreNode/old in world)
		del old
	var/seeded = 0
	for(var/z = 1 to world.maxz)
		var/list/candidates = list()
		for(var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(T.density || T.Water || T.Lava) continue
			if(T.SecondaryTurfType != "Dirt" && T.SecondaryTurfType != "Sand") continue
			candidates += T
		var/want = min(round(candidates.len / LIFE_NODE_DENSITY), LIFE_NODE_ZCAP)
		while(want > 0 && candidates.len)
			var/turf/T = pick(candidates)
			candidates -= T
			if(locate(/obj) in T) continue
			var/obj/LifeSkills/OreNode/N = new(T)
			N.Setup(LifePickSeedOre())
			seeded++
			want--
		sleep(-1)
	world.log << "//\[info]: Seeded [seeded] ore nodes."

mob/Admin4/verb/makeOreNode(id as text)
	set category = "Admin"
	InitLifeOreDefs()
	if(!LifeOreDefs[id])
		src << "No such ore. Valid: [jointext(LifeOreDefs, ", ")]"
		return
	var/obj/LifeSkills/OreNode/N = new(get_step(src, src.dir))
	N.Setup(id)
	src << "Placed \a [N.name]."

mob/Admin4/verb/Life_Node_Spawns_Toggle()
	set category = "Admin"
	set name = "Life Node Spawns Toggle"
	glob.LIFE_NODE_SPAWNS = !glob.LIFE_NODE_SPAWNS
	src << "Boot-time life-skill node seeding: [glob.LIFE_NODE_SPAWNS ? "ON" : "OFF"] (takes effect next world start)."
	Log("Admin", "[ExtractInfo(src)] set life node boot spawns to [glob.LIFE_NODE_SPAWNS].")

mob/Admin4/verb/reseedOreNodes()
	set category = "Admin"
	src << "Reseeding ore nodes..."
	spawn() SeedLifeSkillNodes()

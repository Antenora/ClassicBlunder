var/global/list/LifeFishSpots = list()

/datum/fish_spot_def
	var/id
	var/name
	var/tier = 1
	var/difficulty = 1

var/list/LifeSpotDefs = list()

proc/LifeSpotAdd(id, name, tier)
	var/datum/fish_spot_def/d = new
	d.id = id
	d.name = name
	d.tier = tier
	d.difficulty = LIFE_HUNT_DIFF(tier)
	LifeSpotDefs[id] = d

proc/RegisterFishSpots()
	if(LifeSpotDefs.len) return
	LifeSpotAdd("shallows", "Fishing Spot", 1)
	LifeSpotAdd("pond", "Fishing Spot", 2)
	LifeSpotAdd("river", "Fishing Spot", 3)
	LifeSpotAdd("deep", "Fishing Spot", 4)
	LifeSpotAdd("abyss", "Fishing Spot", 5)

proc/LifeSpotDef(id)
	RegisterFishSpots()
	return LifeSpotDefs[id]

// fish drop pool cached by tier
var/list/LifeFishTierPool = list()
proc/InitFishTierPool()
	if(LifeFishTierPool.len) return
	for(var/T in typesof(/obj/Items/Material/Fish) - /obj/Items/Material/Fish)
		var/obj/Items/Material/Fish/f = new T
		if(!f.MaterialClass || f.junk) { del f; continue }   // junk hooks
		var/key = "[f.tier]"
		if(!LifeFishTierPool[key]) LifeFishTierPool[key] = list()
		LifeFishTierPool[key] += T
		del f

proc/LifeFishPoolForTier(tier)
	InitFishTierPool()
	var/list/p = LifeFishTierPool["[tier]"]
	if((!p || !p.len) && tier > 1) return LifeFishPoolForTier(tier - 1)
	return p ? p : list()

/obj/LifeSkills/FishingSpot
	name = "Fishing Spot"
	icon = 'Icons/LifeSkills/FishingSpots.dmi'
	density = 0
	layer = OBJ_LAYER
	var/spot_id = "shallows"
	var/charges = 4
	var/max_charges = 4
	var/depleted = FALSE
	var/tmp/mob/fishing_by

	New()
		..()
		LifeFishSpots += src

	Del()
		LifeFishSpots -= src
		..()

	proc/Setup(id)
		var/datum/fish_spot_def/d = LifeSpotDef(id)
		if(!d) return 0
		spot_id = id
		icon_state = id
		name = d.name
		desc = "Fish are gathering here. Face it and press your Interact key to cast."
		charges = rand(LIFE_NODE_CHARGES_MIN, LIFE_NODE_CHARGES_MAX)
		max_charges = charges
		return 1

	proc/Deplete()
		depleted = TRUE
		alpha = 0
		mouse_opacity = 0
		LifeScheduler.schedule(new/Event/SpotRespawn(src), LIFE_SEC2EVT(LIFE_NODE_RESPAWN_SECS))

	proc/Respawn()
		depleted = FALSE
		alpha = 255
		mouse_opacity = 1
		charges = rand(LIFE_NODE_CHARGES_MIN, LIFE_NODE_CHARGES_MAX)
		max_charges = charges

	Click()
		if(!usr || depleted) return
		if(get_dist(usr, src) > 3)
			usr << "You're too far from the water."
			return
		usr.StartFish(src)

	InteractWith(mob/M)
		if(depleted) return 0
		if(get_dist(M, src) > 3) return 0
		M.StartFish(src)
		return 1

	Examined(mob/user)
		..()
		var/datum/fish_spot_def/d = LifeSpotDef(spot_id)
		if(!d) return
		var/rank = user.LifeRank("Fishing")
		if(!LIFE_GATHER_GATE_OK(rank, d.difficulty))
			user << "<font color=#ff6464>Tier [d.tier] waters. You're not ready - Fishing rank [d.difficulty - 1] required.</font>"
			return
		var/col = "#78eb78"
		var/word = "calm fishing"
		if(d.difficulty - rank >= 1)
			col = "#ffd86b"
			word = "lively - the fish here fight hard"
		user << "<font color='[col]'>Tier [d.tier] waters. This looks like [word].</font>"

Event/SpotRespawn
	var/obj/LifeSkills/FishingSpot/spot
	New(s)
		spot = s
	fire()
		..()
		if(spot && spot.depleted)
			spot.Respawn()

// the bobber shown over a spot while a line is out
/obj/LifeSkills/Bobber
	icon = 'Icons/LifeSkills/FishingBobber.dmi'
	icon_state = "bob"
	layer = OBJ_LAYER + 0.5
	mouse_opacity = 0
	density = 0

// cast + reel
mob/proc/StartFish(obj/LifeSkills/FishingSpot/S)
	if(!S || S.depleted || !client) return
	if(KO || Dead) return
	if(Using)
		src << "You're in the middle of something."
		return
	if(client.life_minigame_sink) return
	if(S.fishing_by && S.fishing_by != src)
		src << "Someone's already fishing there."
		return
	var/datum/fish_spot_def/d = LifeSpotDef(S.spot_id)
	if(!d) return
	var/rank = LifeRank("Fishing")
	if(!LIFE_GATHER_GATE_OK(rank, d.difficulty))
		src << "<font color=#ff6464>These waters are beyond you. (Fishing rank [d.difficulty - 1] required)</font>"
		return
	if(!UseLifeStamina(LIFE_COST_GATHER)) return
	var/list/pool = LifeFishPoolForTier(d.tier)
	if(!pool.len) return
	// the fish is decided at the bite, its pattern + tier drive the reel
	var/ftype = pick(pool)
	var/datum/life_opp/armed = OppFishArmed()
	var/isjunk = 0
	if(!armed && prob(5))
		isjunk = 1
		ftype = pick(/obj/Items/Material/Fish/junk_boot, /obj/Items/Material/Fish/junk_nomessage)
	var/obj/Items/Material/Fish/fish = new ftype
	var/fpat = fish.pattern
	var/fname = fish.name
	del fish
	var/oppdiff = 0
	if(armed)
		oppdiff = 2
		if(armed.id == "legendary_strike") fpat = "dart"
	S.fishing_by = src
	Using = 1
	var/obj/LifeSkills/Bobber/bob = new(get_turf(S))
	src << "You cast your line and wait..."
	var/wait = rand(20, 200) + (prob(35) ? rand(0, 400) : 0)    // ~1s to ~30s, mixed
	var/waited = 0
	while(waited < wait)
		if(!S || S.depleted || KO || Dead)
			if(bob) del bob
			Using = 0
			if(S) S.fishing_by = null
			return
		if(get_dist(src, S) > 3)
			if(bob) del bob
			Using = 0
			S.fishing_by = null
			src << "You wander off, reeling in your empty line."
			return
		sleep(1)
		waited++
	// a bite - a 2-second window to strike
	src << "<b>Something's biting! Hit [InteractKeyName()] to reel it in!</b>"
	var/hooked = 0
	for(var/i = 1 to 40)
		if(!S || S.depleted || KO || Dead || get_dist(src, S) > 3) break
		if(client.life_interact_down)
			hooked = 1
			break
		sleep(1)
	if(bob) del bob
	if(!hooked)
		src << "<font color=#ff6464>You were too slow, the [fname] slips away.</font>"
		Using = 0
		if(S) S.fishing_by = null
		AddLifeXP("Fishing", LifeGatherXP("Fishing", d.tier) * 0.25, LIFE_PERF_MIN)
		return
	var/list/opts = list("target" = S, "pattern" = fpat)
	var/perf = RunLifeMinigame(src, "fish_bar", isjunk ? 1 : min(d.difficulty + oppdiff, 10), opts)
	Using = 0
	if(S) S.fishing_by = null
	if(perf < 0)
		src << "Your line goes slack."
		return
	if(perf <= 0)
		src << "<font color=#ff6464>The [fname] shakes free and gets away!</font>"
		if(armed) src << "<font color=#ff6464>The [armed.name] slips back into the deep...</font>"
		AddLifeXP("Fishing", LifeGatherXP("Fishing", d.tier) * 0.4, LIFE_PERF_MIN)
		return
	FishPayout(S, d, ftype, fname, perf, rank, armed, isjunk)

mob/proc/FishPayout(obj/LifeSkills/FishingSpot/S, datum/fish_spot_def/d, ftype, fname, perf, rank, datum/life_opp/armed, isjunk = 0)
	if(!S || !d) return
	perf = clamp(perf, LIFE_PERF_MIN, LIFE_PERF_MAX)
	if(isjunk)
		GiveMaterial(src, ftype, 1, QUAL_POOR)
		src << "You reel in... [fname]. The sea has moods."
		LifeLogFind("Fishing", fname)
		AddLifeXP("Fishing", LifeGatherXP("Fishing", 1) * 0.3, LIFE_PERF_MIN)
		if(prob(0.5))
			var/obj/Items/BottledTreasure/JB = new
			GiveOrDrop(JB)
			src << "<font color=#ffd86b><b>Tangled around it - Bottled Treasure!</b></font>"
		S.charges--
		if(S.charges <= 0)
			src << "The fish here have scattered."
			S.Deplete()
		return
	var/q = QUAL_NORMAL
	if(perf >= 1.4) q++
	if(perf < 0.7) q--
	if(prob(2 * rank)) q++
	q = min(q, LifeQualityCap(rank))
	if(q >= QUAL_LEGENDARY)
		var/legchance = LIFE_GATHER_LEG_BASE + max(0, rank - 8)
		if(perf >= 1.4) legchance += 1
		if(!prob(legchance)) q = QUAL_EPIC
	q = QualityClamp(q)
	if(armed && armed.id == "legendary_strike")
		q = clamp(LifeQualityCap(rank), QUAL_EPIC, QUAL_LEGENDARY)   // the strike fights like a legend and lands like one

	GiveMaterial(src, ftype, 1, q)
	src << "<font color=#78eb78>You land a [QualityName(q)] [fname]!</font>"
	LifeLogFind("Fishing", fname)
	if(prob((armed && armed.id == "sunken_cache") ? 10 : 0.5))
		var/obj/Items/BottledTreasure/B = new
		GiveOrDrop(B)
		src << "<font color=#ffd86b><b>A sealed bottle glints in the haul - Bottled Treasure!</b></font>"
	if(armed) OppFishResolve(armed, d.tier, rank)
	else LifeOppRoll("Fishing", d.tier, ftype, q)

	// Legend of the Deep: rank 10 hooks a legendary catch once a day
	if(rank >= LIFE_MAX_RANK && LifeLegendDay != DaysOfWipe())
		LifeLegendDay = DaysOfWipe()
		var/list/deep = LifeFishPoolForTier(5)
		if(deep.len)
			var/ltype = pick(deep)
			var/obj/Items/Material/Fish/lf = new ltype
			var/ln = lf.name
			del lf
			GiveMaterial(src, ltype, 1, min(q + 1, LifeQualityCap(rank)))
			src << "<b>Legend of the Deep - a mighty [ln] takes the hook!</b>"
			LifeLogFind("Fishing", ln)

	AddLifeXP("Fishing", LifeGatherXP("Fishing", d.tier), perf)
	S.charges--
	if(S.charges <= 0)
		src << "The fish here have scattered."
		S.Deplete()

/obj/Items/Material/Fish/junk_boot
	name = "Old Boot"
	MaterialClass = "OldBoot"
	icon = 'Icons/LifeSkills/FishJunk.dmi'
	icon_state = "boot"
	desc = "Someone's lost sole."
	tier = 1
	junk = 1
	pattern = "sinker"

/obj/Items/Material/Fish/junk_nomessage
	name = "Message not in a Bottle"
	MaterialClass = "MessageNotInABottle"
	icon = 'Icons/LifeSkills/FishJunk.dmi'
	icon_state = "nomessage"
	desc = "A bottle, conspicuously devoid of message."
	tier = 1
	junk = 1
	pattern = "floater"

/obj/Items/BottledTreasure
	name = "Bottled Treasure"
	icon = 'Icons/LifeSkills/BottledTreasure.dmi'
	icon_state = "bottle"
	Savable = 1
	Grabbable = 1
	Cost = 0
	desc = "A sealed bottle hauled from the deep. Click it to break the seal."
	Click()
		if(!usr || loc != usr) return
		// 1..1000: $1 15% / $100 30% / $1000 38.9% / $10k 15% / $100k 1% / $1M 0.1%
		var/roll = rand(1, 1000)
		var/amt
		if(roll == 1000) amt = 1000000
		else if(roll >= 990) amt = 100000
		else if(roll >= 840) amt = 10000
		else if(roll >= 451) amt = 1000
		else if(roll >= 151) amt = 100
		else amt = 1
		usr.GiveMoney(amt)
		if(amt >= 100000)
			usr << "<font color=#ffd86b><b>The seal cracks - a FORTUNE spills out! $[Commas(amt)]!</b></font>"
		else if(amt >= 1000)
			usr << "<font color=#78eb78>The seal cracks - $[Commas(amt)] inside!</font>"
		else
			usr << "The seal cracks... $[Commas(amt)]. The sea has a sense of humor."
		del src

// world seeding
proc/LifePickSeedSpot()
	RegisterFishSpots()
	var/total = 0
	for(var/id in LifeSpotDefs)
		var/datum/fish_spot_def/d = LifeSpotDefs[id]
		total += LifeOreSeedWeight(d.difficulty)
	var/roll = rand(1, total)
	for(var/id in LifeSpotDefs)
		var/datum/fish_spot_def/d = LifeSpotDefs[id]
		roll -= LifeOreSeedWeight(d.difficulty)
		if(roll <= 0) return id
	return "shallows"

proc/SeedFishSpots()
	set background = 1
	RegisterFishSpots()
	for(var/obj/LifeSkills/FishingSpot/old in world)
		del old
	var/seeded = 0
	for(var/z = 1 to world.maxz)
		var/list/candidates = list()
		for(var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(!T.Water || T.Lava) continue
			candidates += T
		var/want = min(round(candidates.len / LIFE_NODE_DENSITY), LIFE_NODE_ZCAP)
		while(want > 0 && candidates.len)
			var/turf/T = pick(candidates)
			candidates -= T
			if(locate(/obj) in T) continue
			var/obj/LifeSkills/FishingSpot/N = new(T)
			N.Setup(LifePickSeedSpot())
			seeded++
			want--
		sleep(-1)
	world.log << "//\[info]: Seeded [seeded] fishing spots."

mob/Admin4/verb/makeFishingSpot(id as text)
	set category = "Admin"
	RegisterFishSpots()
	if(!LifeSpotDefs[id])
		src << "No such spot. Valid: [jointext(LifeSpotDefs, ", ")]"
		return
	var/obj/LifeSkills/FishingSpot/N = new(get_step(src, src.dir))
	N.Setup(id)
	src << "Placed \a [N.name]."

mob/Admin4/verb/reseedFishingSpots()
	set category = "Admin"
	src << "Reseeding fishing spots..."
	spawn() SeedFishSpots()

/obj/Items/Material/Fish
	icon = 'Icons/LifeSkills/FishingMats.dmi'
	desc = "A fresh catch. Cooks and alchemists both have uses for it."
	var/tier = 1
	var/pattern = "mixed"
	var/junk = 0       

/obj/Items/Material/Fish/koi { name = "Koi"; MaterialClass = "Koi"; icon_state = "koi"; tier = 3; pattern = "smooth" }
/obj/Items/Material/Fish/goldfish { name = "Goldfish"; MaterialClass = "Goldfish"; icon_state = "goldfish"; tier = 1; pattern = "floater" }
/obj/Items/Material/Fish/betta { name = "Betta"; MaterialClass = "Betta"; icon_state = "betta"; tier = 2; pattern = "mixed" }
/obj/Items/Material/Fish/carp { name = "Carp"; MaterialClass = "Carp"; icon_state = "carp"; tier = 1; pattern = "smooth" }
/obj/Items/Material/Fish/catfish { name = "Catfish"; MaterialClass = "Catfish"; icon_state = "catfish"; tier = 2; pattern = "sinker" }
/obj/Items/Material/Fish/sea_bass { name = "Sea Bass"; MaterialClass = "SeaBass"; icon_state = "sea_bass"; tier = 2; pattern = "mixed" }
/obj/Items/Material/Fish/red_snapper { name = "Red Snapper"; MaterialClass = "RedSnapper"; icon_state = "red_snapper"; tier = 3; pattern = "mixed" }
/obj/Items/Material/Fish/tuna { name = "Tuna"; MaterialClass = "Tuna"; icon_state = "tuna"; tier = 4; pattern = "dart" }
/obj/Items/Material/Fish/marlin { name = "Marlin"; MaterialClass = "Marlin"; icon_state = "marlin"; tier = 5; pattern = "dart" }
/obj/Items/Material/Fish/mahi_mahi { name = "Mahi Mahi"; MaterialClass = "MahiMahi"; icon_state = "mahi_mahi"; tier = 4; pattern = "dart" }
/obj/Items/Material/Fish/garfish { name = "Garfish"; MaterialClass = "Garfish"; icon_state = "garfish"; tier = 3; pattern = "mixed" }
/obj/Items/Material/Fish/chub { name = "Chub"; MaterialClass = "Chub"; icon_state = "chub"; tier = 1; pattern = "mixed" }
/obj/Items/Material/Fish/bluegill { name = "Bluegill"; MaterialClass = "Bluegill"; icon_state = "bluegill"; tier = 1; pattern = "floater" }
/obj/Items/Material/Fish/perch { name = "Perch"; MaterialClass = "Perch"; icon_state = "perch"; tier = 1; pattern = "mixed" }
/obj/Items/Material/Fish/tilapia { name = "Tilapia"; MaterialClass = "Tilapia"; icon_state = "tilapia"; tier = 2; pattern = "mixed" }
/obj/Items/Material/Fish/angelfish { name = "Angelfish"; MaterialClass = "Angelfish"; icon_state = "angelfish"; tier = 2; pattern = "floater" }
/obj/Items/Material/Fish/pink_salmon { name = "Pink Salmon"; MaterialClass = "PinkSalmon"; icon_state = "pink_salmon"; tier = 3; pattern = "mixed" }
/obj/Items/Material/Fish/sturgeon { name = "Sturgeon"; MaterialClass = "Sturgeon"; icon_state = "sturgeon"; tier = 4; pattern = "smooth" }
/obj/Items/Material/Fish/pike { name = "Pike"; MaterialClass = "Pike"; icon_state = "pike"; tier = 3; pattern = "dart" }
/obj/Items/Material/Fish/mako_shark { name = "Mako Shark"; MaterialClass = "MakoShark"; icon_state = "mako_shark"; tier = 5; pattern = "dart" }
/obj/Items/Material/Fish/manta_ray { name = "Manta Ray"; MaterialClass = "MantaRay"; icon_state = "manta_ray"; tier = 4; pattern = "smooth" }
/obj/Items/Material/Fish/puffer { name = "Puffer Fish"; MaterialClass = "Puffer"; icon_state = "puffer"; tier = 4; pattern = "sinker" }
/obj/Items/Material/Fish/anchovy { name = "Anchovy"; MaterialClass = "Anchovy"; icon_state = "anchovy"; tier = 1; pattern = "floater" }
/obj/Items/Material/Fish/mackerel { name = "Mackerel"; MaterialClass = "Mackerel"; icon_state = "mackerel"; tier = 2; pattern = "mixed" }
/obj/Items/Material/Fish/eel { name = "Eel"; MaterialClass = "Eel"; icon_state = "eel"; tier = 3; pattern = "sinker" }
/obj/Items/Material/Fish/rainbow_trout { name = "Rainbow Trout"; MaterialClass = "RainbowTrout"; icon_state = "rainbow_trout"; tier = 3; pattern = "mixed" }
/obj/Items/Material/Fish/bream { name = "Bream"; MaterialClass = "Bream"; icon_state = "bream"; tier = 2; pattern = "mixed" }
/obj/Items/Material/Fish/clownfish { name = "Clownfish"; MaterialClass = "Clownfish"; icon_state = "clownfish"; tier = 2; pattern = "floater" }
/obj/Items/Material/Fish/lionfish { name = "Lionfish"; MaterialClass = "Lionfish"; icon_state = "lionfish"; tier = 4; pattern = "mixed" }
/obj/Items/Material/Fish/angler { name = "Angler"; MaterialClass = "Angler"; icon_state = "angler"; tier = 5; pattern = "dart" }
/obj/Items/Material/Fish/seahorse { name = "Seahorse"; MaterialClass = "Seahorse"; icon_state = "seahorse"; tier = 3; pattern = "floater" }
/obj/Items/Material/Fish/starfish { name = "Starfish"; MaterialClass = "Starfish"; icon_state = "starfish"; tier = 2; pattern = "smooth" }
/obj/Items/Material/Fish/frog { name = "Frog"; MaterialClass = "Frog"; icon_state = "frog"; tier = 1; pattern = "floater" }
/obj/Items/Material/Fish/snapping_turtle { name = "Snapping Turtle"; MaterialClass = "SnappingTurtle"; icon_state = "snapping_turtle"; tier = 3; pattern = "sinker" }
/obj/Items/Material/Fish/hermit_crab { name = "Hermit Crab"; MaterialClass = "HermitCrab"; icon_state = "hermit_crab"; tier = 2; pattern = "smooth" }

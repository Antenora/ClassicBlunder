// Hunting. Slain monsters leave carveable remains; the monster's Potential sets the tier
/obj/LifeSkills/Remains
	name = "Remains"
	desc = "The remains of a fallen creature. Face it and press your Interact key to carve."
	density = 0
	layer = OBJ_LAYER
	var/pot_tier = 1
	var/tmp/mob/carving_by
	var/tmp/decaying = 0

	proc/Setup(mob/dead)
		if(dead)
			icon = dead.icon
			icon_state = dead.icon_state
			// placeholder
			color = list(0.35,0.35,0.35, 0.35,0.35,0.35, 0.35,0.35,0.35, 0,0,0)
			dir = SOUTH
			name = "[dead.name]'s Remains"
			pot_tier = LifePotentialTier(dead.Potential)
		LifeScheduler.schedule(new/Event/RemainsDecay(src), LIFE_SEC2EVT(LIFE_REMAINS_DECAY_SECS))

	InteractWith(mob/M)
		if(decaying) return 0
		if(get_dist(M, src) > 1) return 0
		M.StartCarve(src)
		return 1

	Click()
		if(!usr || decaying) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the [name]."
			return
		usr.StartCarve(src)

	Examined(mob/user)
		..()
		var/rank = user.LifeRank("Hunting")
		var/D = LIFE_HUNT_DIFF(pot_tier)
		if(!LIFE_GATHER_GATE_OK(rank, D))
			user << "<font color=#ff6464>Tier [pot_tier] remains. Too much for you - Hunting rank [D - 1] required.</font>"
			return
		var/col = "#78eb78"
		var/word = "a clean carve"
		if(D - rank >= 1)
			col = "#ffd86b"
			word = "delicate - a slip wastes the materials"
		user << "<font color='[col]'>Tier [pot_tier] remains. This looks like [word].</font>"

Event/RemainsDecay
	var/obj/LifeSkills/Remains/rem
	New(r)
		rem = r
	fire()
		..()
		if(rem && !rem.carving_by)
			del rem

// <15 / 15-39 / 40-69 / 70-99 / 100+ tentative
proc/LifePotentialTier(pot)
	if(pot >= 100) return 5
	if(pot >= 70) return 4
	if(pot >= 40) return 3
	if(pot >= 15) return 2
	return 1

// spawn a carveable corpse wherever a monster falls. every kill, anyone may carve.
proc/LifeSpawnRemains(mob/dead)
	if(!dead || !istype(dead, /mob/Player/AI)) return
	var/turf/T = get_turf(dead)
	if(!T) return
	var/obj/LifeSkills/Remains/R = new(T)
	R.Setup(dead)

// also temporary
mob/proc/StartCarve(obj/LifeSkills/Remains/R)
	if(!R || R.decaying || !client) return
	if(KO || Dead) return
	if(Using)
		src << "You're in the middle of something."
		return
	if(client.life_minigame_sink) return
	if(R.carving_by && R.carving_by != src)
		src << "Someone's already working those remains."
		return
	var/rank = LifeRank("Hunting")
	var/D = LIFE_HUNT_DIFF(R.pot_tier)
	if(!LIFE_GATHER_GATE_OK(rank, D))
		src << "<font color=#ff6464>These remains are beyond you. (Hunting rank [D - 1] required)</font>"
		return
	if(!UseLifeStamina(LIFE_COST_HUNT)) return
	R.carving_by = src
	Using = 1
	var/obj/Items/LifeTool/tool = GetBestLifeTool(src, "Knife")
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * D + LIFE_SPEED_PER_UNDER * max(0, D - rank) - LIFE_SPEED_PER_OVER * max(0, rank - D), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	if(tool) speed *= max(0.7, 1 - tool.SweetSpotBonus)
	var/list/opts = list("speed_mult" = speed, "target" = R)
	var/total = 0
	var/finished = 0
	var/aborted = 0
	for(var/i = 1 to LIFE_CARVE_STRIKES)
		var/p = RunLifeMinigame(src, "timing_bar", D, opts)
		if(p < 0)
			aborted = 1
			break
		total += p
		finished++
	Using = 0
	if(R) R.carving_by = null
	if(aborted || !finished)
		src << "You couldn't finish carving the remains."
		return
	CarvePayout(R, total / LIFE_CARVE_STRIKES, tool, rank)

mob/proc/CarvePayout(obj/LifeSkills/Remains/R, perf, obj/Items/LifeTool/tool, rank)
	if(!R) return
	var/tier = R.pot_tier
	var/D = LIFE_HUNT_DIFF(tier)
	if(D > rank)
		if(perf < LIFE_PERF_MIN)
			src << "<font color=#ff6464>Your unskilled cuts ruin the [R.name], nothing usable comes free.</font>"
			AddLifeXP("Hunting", LifeGatherXP("Hunting", tier) * 0.5, LIFE_PERF_MIN)
			if(tool) tool.LifeToolWear(src)
			LifeConsumeRemains(R)
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
		var/legchance = LIFE_GATHER_LEG_BASE + max(0, rank - 8)
		if(perf >= 1.4) legchance += 1
		if(!prob(legchance)) q = QUAL_EPIC
	q = QualityClamp(q)

	RegisterHuntContent()
	var/list/pool = LifeHuntPoolForTier(tier)
	if(!pool.len)
		LifeConsumeRemains(R)
		return
	var/drops = LIFE_HUNT_DROP_COUNT
	while(drops > 0 && pool.len)
		var/matclass = pick(pool)
		pool -= matclass
		var/datum/hunt_drop/hd = LifeHuntDrops[matclass]
		var/amt = max(1, round(LIFE_HUNT_BASE_YIELD * perf + (tool ? tool.YieldBonus : 0)))
		GiveMaterial(src, hd.mtype, amt, q)
		src << "<font color=#78eb78>You carve loose [amt]x [QualityName(q)] [hd.name].</font>"
		LifeLogFind("Hunting", hd.name)
		drops--

	// Trophy Extraction: rank 10 pulls a bonus prime cut once a day
	if(rank >= LIFE_MAX_RANK && LifeTrophyDay != DaysOfWipe())
		LifeTrophyDay = DaysOfWipe()
		var/datum/hunt_drop/hd = LifeHuntBestTrophy(tier)
		if(hd)
			GiveMaterial(src, hd.mtype, 1, min(q + 1, LifeQualityCap(rank)))
			src << "<b>Trophy Extraction - you claim a pristine [hd.name].</b>"
			LifeLogFind("Hunting", hd.name)

	if(tool) tool.LifeToolWear(src)
	AddLifeXP("Hunting", LifeGatherXP("Hunting", tier), perf)
	LifeConsumeRemains(R)

proc/LifeConsumeRemains(obj/LifeSkills/Remains/R)
	if(!R) return
	R.decaying = 1
	del R

// drops
/datum/hunt_drop
	var/matclass
	var/name
	var/mtype
	var/tier = 1

var/list/LifeHuntDrops = list()

proc/LifeHuntAdd(mtype, tier, passive_key, passive_label, base_mag, per_quality)
	var/obj/Items/Material/MonsterPart/m = new mtype
	if(!m.MaterialClass) { del m; return }
	var/datum/hunt_drop/hd = new
	hd.matclass = m.MaterialClass
	hd.name = m.name
	hd.mtype = mtype
	hd.tier = m.tier
	LifeHuntDrops[hd.matclass] = hd
	if(passive_key)
		LifeMatAdd(hd.matclass, hd.name, passive_key, passive_label, base_mag, per_quality)
	del m

// self-guards; also fills the monster_mat def table that Smithing sockets read
proc/RegisterHuntContent()
	if(LifeHuntDrops.len) return
	// tier 1
	LifeHuntAdd(/obj/Items/Material/MonsterPart/rat_tail,     1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/slime_meat,   1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/bat_wing,     1, "AttackSpeed", "Attack Speed", 2, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/small_bone,   1)
	// tier 2
	LifeHuntAdd(/obj/Items/Material/MonsterPart/wolf_fang,    2, "CriticalChance", "Crit Chance", 3, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/goblin_hide,  2)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/snake_venom,  2)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/boar_sinew,   2, "Brutalize", "Brutalize", 1, 1)
	// tier 3
	LifeHuntAdd(/obj/Items/Material/MonsterPart/drake_scale,  3, "ShatterResist", "Shatter Resist", 3, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/ogre_sinew,   3, "MeleeResist", "Melee Resist", 2, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/minotaur_horn,3, "CriticalDamage", "Crit Damage", 0.03, 0.01)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/harpy_talon,  3)
	// tier 4
	LifeHuntAdd(/obj/Items/Material/MonsterPart/wyvern_beak,  4, "CriticalChance", "Crit Chance", 4, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/demon_horn,   4, "PureDamage", "Pure Damage", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/vampire_fang, 4)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/naga_scale,   4, "BlockChance", "Block Chance", 6, 2)
	// tier 5
	LifeHuntAdd(/obj/Items/Material/MonsterPart/dragon_scale, 5, "ShatterResist", "Shatter Resist", 5, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/dragon_bone,  5, "PureDamage", "Pure Damage", 2, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/dragon_essence,5)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/colossal_core,5, "ManaGeneration", "Mana Generation", 3, 1)

// materials at the band's tier, falling back a tier if the band is unpopulated
proc/LifeHuntPoolForTier(tier)
	RegisterHuntContent()
	var/list/out = list()
	for(var/mc in LifeHuntDrops)
		var/datum/hunt_drop/hd = LifeHuntDrops[mc]
		if(hd.tier == tier) out += mc
	if(!out.len && tier > 1) return LifeHuntPoolForTier(tier - 1)
	return out

proc/LifeHuntBestTrophy(tier)
	RegisterHuntContent()
	var/list/pool = LifeHuntPoolForTier(tier)
	return pool.len ? LifeHuntDrops[pick(pool)] : null

// drop items
/obj/Items/Material/MonsterPart/rat_tail      { name = "Rat Tail";       MaterialClass = "RatTail";      icon_state = "rat_tail";      tier = 1 }
/obj/Items/Material/MonsterPart/slime_meat    { name = "Slime Meat";     MaterialClass = "SlimeMeat";    icon_state = "slime_meat";    tier = 1 }
/obj/Items/Material/MonsterPart/bat_wing       { name = "Bat Wing";       MaterialClass = "BatWing";      icon_state = "bat_wing";      tier = 1 }
/obj/Items/Material/MonsterPart/small_bone     { name = "Bones";          MaterialClass = "Bones";        icon_state = "bones";         tier = 1 }
/obj/Items/Material/MonsterPart/wolf_fang      { name = "Wolf Fang";      MaterialClass = "WolfFang";     icon_state = "wolf_fang";     tier = 2 }
/obj/Items/Material/MonsterPart/goblin_hide    { name = "Goblin Hide";    MaterialClass = "GoblinHide";   icon_state = "goblin_hide";   tier = 2 }
/obj/Items/Material/MonsterPart/snake_venom    { name = "Snake Venom";    MaterialClass = "SnakeVenom";   icon_state = "snake_venom";   tier = 2 }
/obj/Items/Material/MonsterPart/boar_sinew     { name = "Boar Sinew";     MaterialClass = "BoarSinew";    icon_state = "boar_sinew";    tier = 2 }
/obj/Items/Material/MonsterPart/drake_scale    { name = "Drake Scale";    MaterialClass = "DrakeScale";   icon_state = "drake_scale";   tier = 3 }
/obj/Items/Material/MonsterPart/ogre_sinew     { name = "Ogre Sinew";     MaterialClass = "OgreSinew";    icon_state = "ogre_sinew";    tier = 3 }
/obj/Items/Material/MonsterPart/minotaur_horn  { name = "Minotaur Horn";  MaterialClass = "MinotaurHorn"; icon_state = "minotaur_horn"; tier = 3 }
/obj/Items/Material/MonsterPart/harpy_talon    { name = "Harpy Talon";    MaterialClass = "HarpyTalon";   icon_state = "harpy_talon";   tier = 3 }
/obj/Items/Material/MonsterPart/wyvern_beak    { name = "Wyvern Beak";    MaterialClass = "WyvernBeak";   icon_state = "wyvern_beak";   tier = 4 }
/obj/Items/Material/MonsterPart/demon_horn     { name = "Demon Horn";     MaterialClass = "DemonHorn";    icon_state = "demon_horn";    tier = 4 }
/obj/Items/Material/MonsterPart/vampire_fang   { name = "Vampire Fang";   MaterialClass = "VampireFang";  icon_state = "vampire_fang";  tier = 4 }
/obj/Items/Material/MonsterPart/naga_scale     { name = "Naga Scale";     MaterialClass = "NagaScale";    icon_state = "naga_scale";    tier = 4 }
/obj/Items/Material/MonsterPart/dragon_scale   { name = "Dragon Scale";   MaterialClass = "DragonScale";  icon_state = "dragon_scale";  tier = 5 }
/obj/Items/Material/MonsterPart/dragon_bone    { name = "Dragon Bone";    MaterialClass = "DragonBone";   icon_state = "dragon_bone";   tier = 5 }
/obj/Items/Material/MonsterPart/dragon_essence { name = "Dragon Essence"; MaterialClass = "DragonEssence";icon_state = "dragon_essence";tier = 5 }
/obj/Items/Material/MonsterPart/colossal_core  { name = "Colossal Core";  MaterialClass = "ColossalCore"; icon_state = "colossal_core"; tier = 5 }

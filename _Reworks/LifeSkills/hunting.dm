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
	var/need = LIFE_SAW_STROKES(D)
	if(tool) need = max(3, round(need * max(0.6, 1 - tool.SweetSpotBonus)))   // a sharp knife = fewer strokes
	var/list/opts = list("target" = R, "need" = need, "limit" = LIFE_SAW_TIME(D, rank))
	var/perf = RunLifeMinigame(src, "drag_saw", D, opts)
	Using = 0
	if(R) R.carving_by = null
	if(perf < 0)
		src << "You couldn't finish carving the remains."
		return
	CarvePayout(R, perf, tool, rank)

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
		var/matclass = LifeHuntWeightedPick(pool)
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
	var/list/opool = LifeHuntPoolForTier(tier)
	if(opool.len)
		var/datum/hunt_drop/ohd = LifeHuntDrops[LifeHuntWeightedPick(opool)]
		if(ohd) LifeOppRoll("Hunting", tier, ohd.mtype, q)
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
	var/weight = LIFE_W_COMMON
	var/rare_only = 0      // reserved for rare-monster encounters (Daily Opportunities); skipped by normal carves

var/list/LifeHuntDrops = list()

// tier comes from the item def (mtype's tier var). weight = rarity, rare_only reserves it for rare monsters.
proc/LifeHuntAdd(mtype, weight = LIFE_W_COMMON, passive_key, passive_label, base_mag, per_quality, rare_only = 0)
	var/obj/Items/Material/MonsterPart/m = new mtype
	if(!m.MaterialClass) { del m; return }
	var/datum/hunt_drop/hd = new
	hd.matclass = m.MaterialClass
	hd.name = m.name
	hd.mtype = mtype
	hd.tier = m.tier
	hd.weight = weight
	hd.rare_only = rare_only
	LifeHuntDrops[hd.matclass] = hd
	if(passive_key)
		LifeMatAdd(hd.matclass, hd.name, passive_key, passive_label, base_mag, per_quality)
	del m

// self-guards; also fills the monster_mat def table that Smithing sockets read
proc/RegisterHuntContent()
	if(LifeHuntDrops.len) return
	// tier 1
	LifeHuntAdd(/obj/Items/Material/MonsterPart/rat_tail, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/slime_meat, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/bones, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/worm_tail, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/rotten_fang, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/bat_wing, LIFE_W_UTILITY, "Godspeed", "Godspeed", 0.6, 0.6)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/bat_guano, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/lizard_tail, LIFE_W_COMMON)
	// tier 2
	LifeHuntAdd(/obj/Items/Material/MonsterPart/wolf_fang, LIFE_W_DAMAGE, "CriticalDamage", "Crit Damage", 0.01, 0.01)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/goblin_hide, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/snake_venom, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/boar_sinew, LIFE_W_DAMAGE, "Pursuer", "Pursuer", 0.6, 0.6)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/gelatin, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/slime_core, LIFE_W_UTILITY, "ManaGeneration", "Mana Gen", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/crab_meat, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/bone_meal, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/kobold_earring, LIFE_W_UTILITY, "EnergyGeneration", "Energy Gen", 0.5, 0.5)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/turtle_leg, LIFE_W_UTILITY, "MeleeResist", "Melee Resist", 0.6, 0.6, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/fungus, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/werewolf_tuft, LIFE_W_UTILITY, "Adrenaline", "Adrenaline", 1, 1)
	// tier 3
	LifeHuntAdd(/obj/Items/Material/MonsterPart/drake_scale, LIFE_W_UTILITY, "ShatterResist", "Shatter Resist", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/ogre_sinew, LIFE_W_STRONG, "HeavyHitter", "Heavy Hitter", 0.4, 0.4)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/minotaur_horn, LIFE_W_UTILITY, "Momentum", "Momentum", 0.4, 0.4)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/harpy_talon, LIFE_W_STRONG)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/red_scales, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/ectoplasm, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/mandragora_root, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/succubus_horn, LIFE_W_STRONG, "ManaSteal", "Mana Steal", 3, 3)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/cannibal_canine, LIFE_W_DAMAGE, "LifeSteal", "Life Steal", 3, 3)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/scorpion_sting, LIFE_W_DAMAGE, "StunningStrike", "Stunning Strike", 0.2, 0.2, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/ninja_star, LIFE_W_DAMAGE)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/turtle_shell, LIFE_W_UTILITY, "Harden", "Harden", 0.6, 0.6)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/minotaur_hoof, LIFE_W_UTILITY, "Juggernaut", "Juggernaut", 0.4, 0.4)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/spider_poison, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/mud_golem_core, LIFE_W_DAMAGE, "HardStyle", "Hard Style", 0.6, 0.6)
	// tier 4
	LifeHuntAdd(/obj/Items/Material/MonsterPart/wyvern_beak, LIFE_W_DAMAGE, "CriticalDamage", "Crit Damage", 0.03, 0.03)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/demon_horn, LIFE_W_DAMAGE, "SoulFire", "Soul Fire", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/vampire_fang, LIFE_W_DAMAGE, "LifeSteal", "Life Steal", 5, 5, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/naga_scale, LIFE_W_STRONG, "CriticalBlock", "Block Power", 0.03, 0.03)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/cyclops_eye, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/yeti_horn, LIFE_W_UTILITY, "ChillResist", "Chill Resist", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/stone_golem_core, LIFE_W_UTILITY, "Persistence", "Persistence", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/fire_golem_core, LIFE_W_UTILITY, "BurnResist", "Burn Resist", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/golden_tooth, LIFE_W_STRONG, "Duelist", "Duelist", 0.6, 0.6, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/sorrowful_tears, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/demon_leg, LIFE_W_STRONG, "Warping", "Warping", 0.4, 0.4, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/broken_shield, LIFE_W_STRONG, "CounterMaster", "Counter Master", 0.8, 0.8)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/elder_scroll, LIFE_W_STRONG, "TechniqueMastery", "Technique Mastery", 0.6, 0.6)
	// tier 5
	LifeHuntAdd(/obj/Items/Material/MonsterPart/dragon_scale, LIFE_W_UTILITY, "LifeGeneration", "Life Gen", 1, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/dragon_essence, LIFE_W_COMMON)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/golden_dragon_claw, LIFE_W_DAMAGE, "DoubleStrike", "Double Strike", 0.4, 0.4, 1)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/colossal_scale, LIFE_W_DAMAGE, "SweepingStrike", "Sweeping Strike", 0.2, 0.2)
	LifeHuntAdd(/obj/Items/Material/MonsterPart/earth_dragon_gem, LIFE_W_STRONG, "EnergySteal", "Energy Steal", 2, 2)

// materials at the band's tier, falling back a tier if the band is unpopulated
proc/LifeHuntPoolForTier(tier)
	RegisterHuntContent()
	var/list/out = list()
	for(var/mc in LifeHuntDrops)
		var/datum/hunt_drop/hd = LifeHuntDrops[mc]
		if(hd.rare_only) continue      // reserved for rare-monster encounters
		if(hd.tier == tier) out += mc
	if(!out.len && tier > 1) return LifeHuntPoolForTier(tier - 1)
	return out

// weighted pick from a pool of matclasses, by each drop's rarity weight
proc/LifeHuntWeightedPick(list/pool)
	if(!pool || !pool.len) return null
	var/total = 0
	for(var/mc in pool)
		var/datum/hunt_drop/hd = LifeHuntDrops[mc]
		if(hd) total += hd.weight
	if(total <= 0) return pick(pool)
	var/roll = rand(1, total)
	for(var/mc in pool)
		var/datum/hunt_drop/hd = LifeHuntDrops[mc]
		if(!hd) continue
		roll -= hd.weight
		if(roll <= 0) return mc
	return pool[pool.len]

proc/LifeHuntBestTrophy(tier)
	RegisterHuntContent()
	var/list/pool = LifeHuntPoolForTier(tier)
	return pool.len ? LifeHuntDrops[LifeHuntWeightedPick(pool)] : null

// drop items (types + icon_states are generated from the bake script's master list, kept in sync)
/obj/Items/Material/MonsterPart/rat_tail { name = "Rat Tail"; MaterialClass = "RatTail"; icon_state = "rat_tail"; tier = 1 }
/obj/Items/Material/MonsterPart/slime_meat { name = "Slime Meat"; MaterialClass = "SlimeMeat"; icon_state = "slime_meat"; tier = 1 }
/obj/Items/Material/MonsterPart/bones { name = "Bones"; MaterialClass = "Bones"; icon_state = "bones"; tier = 1 }
/obj/Items/Material/MonsterPart/worm_tail { name = "Worm Tail"; MaterialClass = "WormTail"; icon_state = "worm_tail"; tier = 1 }
/obj/Items/Material/MonsterPart/rotten_fang { name = "Rotten Fang"; MaterialClass = "RottenFang"; icon_state = "rotten_fang"; tier = 1 }
/obj/Items/Material/MonsterPart/bat_wing { name = "Bat Wing"; MaterialClass = "BatWing"; icon_state = "bat_wing"; tier = 1 }
/obj/Items/Material/MonsterPart/bat_guano { name = "Bat Guano"; MaterialClass = "BatGuano"; icon_state = "bat_guano"; tier = 1 }
/obj/Items/Material/MonsterPart/lizard_tail { name = "Lizard Tail"; MaterialClass = "LizardTail"; icon_state = "lizard_tail"; tier = 1 }
/obj/Items/Material/MonsterPart/wolf_fang { name = "Wolf Fang"; MaterialClass = "WolfFang"; icon_state = "wolf_fang"; tier = 2 }
/obj/Items/Material/MonsterPart/goblin_hide { name = "Goblin Hide"; MaterialClass = "GoblinHide"; icon_state = "goblin_hide"; tier = 2 }
/obj/Items/Material/MonsterPart/snake_venom { name = "Snake Venom"; MaterialClass = "SnakeVenom"; icon_state = "snake_venom"; tier = 2 }
/obj/Items/Material/MonsterPart/boar_sinew { name = "Boar Sinew"; MaterialClass = "BoarSinew"; icon_state = "boar_sinew"; tier = 2 }
/obj/Items/Material/MonsterPart/gelatin { name = "Gelatin"; MaterialClass = "Gelatin"; icon_state = "gelatin"; tier = 2 }
/obj/Items/Material/MonsterPart/slime_core { name = "Slime Core"; MaterialClass = "SlimeCore"; icon_state = "slime_core"; tier = 2 }
/obj/Items/Material/MonsterPart/crab_meat { name = "Crab Meat"; MaterialClass = "CrabMeat"; icon_state = "crab_meat"; tier = 2 }
/obj/Items/Material/MonsterPart/bone_meal { name = "Bone Meal"; MaterialClass = "BoneMeal"; icon_state = "bone_meal"; tier = 2 }
/obj/Items/Material/MonsterPart/kobold_earring { name = "Kobold Earring"; MaterialClass = "KoboldEarring"; icon_state = "kobold_earring"; tier = 2 }
/obj/Items/Material/MonsterPart/turtle_leg { name = "Turtle Leg"; MaterialClass = "TurtleLeg"; icon_state = "turtle_leg"; tier = 2 }
/obj/Items/Material/MonsterPart/fungus { name = "Fungus"; MaterialClass = "Fungus"; icon_state = "fungus"; tier = 2 }
/obj/Items/Material/MonsterPart/werewolf_tuft { name = "Werewolf Tuft"; MaterialClass = "WerewolfTuft"; icon_state = "werewolf_tuft"; tier = 2 }
/obj/Items/Material/MonsterPart/drake_scale { name = "Drake Scale"; MaterialClass = "DrakeScale"; icon_state = "drake_scale"; tier = 3 }
/obj/Items/Material/MonsterPart/ogre_sinew { name = "Ogre Sinew"; MaterialClass = "OgreSinew"; icon_state = "ogre_sinew"; tier = 3 }
/obj/Items/Material/MonsterPart/minotaur_horn { name = "Minotaur Horn"; MaterialClass = "MinotaurHorn"; icon_state = "minotaur_horn"; tier = 3 }
/obj/Items/Material/MonsterPart/harpy_talon { name = "Harpy Talon"; MaterialClass = "HarpyTalon"; icon_state = "harpy_talon"; tier = 3 }
/obj/Items/Material/MonsterPart/red_scales { name = "Red Scales"; MaterialClass = "RedScales"; icon_state = "red_scales"; tier = 3 }
/obj/Items/Material/MonsterPart/ectoplasm { name = "Ectoplasm"; MaterialClass = "Ectoplasm"; icon_state = "ectoplasm"; tier = 3 }
/obj/Items/Material/MonsterPart/mandragora_root { name = "Mandragora Root"; MaterialClass = "MandragoraRoot"; icon_state = "mandragora_root"; tier = 3 }
/obj/Items/Material/MonsterPart/succubus_horn { name = "Succubus Horn"; MaterialClass = "SuccubusHorn"; icon_state = "succubus_horn"; tier = 3 }
/obj/Items/Material/MonsterPart/cannibal_canine { name = "Cannibal Canine"; MaterialClass = "CannibalCanine"; icon_state = "cannibal_canine"; tier = 3 }
/obj/Items/Material/MonsterPart/scorpion_sting { name = "Scorpion Sting"; MaterialClass = "ScorpionSting"; icon_state = "scorpion_sting"; tier = 3 }
/obj/Items/Material/MonsterPart/ninja_star { name = "Ninja Star"; MaterialClass = "NinjaStar"; icon_state = "ninja_star"; tier = 3 }
/obj/Items/Material/MonsterPart/turtle_shell { name = "Turtle Shell"; MaterialClass = "TurtleShell"; icon_state = "turtle_shell"; tier = 3 }
/obj/Items/Material/MonsterPart/minotaur_hoof { name = "Minotaur Hoof"; MaterialClass = "MinotaurHoof"; icon_state = "minotaur_hoof"; tier = 3 }
/obj/Items/Material/MonsterPart/spider_poison { name = "Spider Poison"; MaterialClass = "SpiderPoison"; icon_state = "spider_poison"; tier = 3 }
/obj/Items/Material/MonsterPart/wyvern_beak { name = "Wyvern Beak"; MaterialClass = "WyvernBeak"; icon_state = "wyvern_beak"; tier = 4 }
/obj/Items/Material/MonsterPart/demon_horn { name = "Demon Horn"; MaterialClass = "DemonHorn"; icon_state = "demon_horn"; tier = 4 }
/obj/Items/Material/MonsterPart/vampire_fang { name = "Vampire Fang"; MaterialClass = "VampireFang"; icon_state = "vampire_fang"; tier = 4 }
/obj/Items/Material/MonsterPart/naga_scale { name = "Naga Scale"; MaterialClass = "NagaScale"; icon_state = "naga_scale"; tier = 4 }
/obj/Items/Material/MonsterPart/cyclops_eye { name = "Cyclops Eye"; MaterialClass = "CyclopsEye"; icon_state = "cyclops_eye"; tier = 4 }
/obj/Items/Material/MonsterPart/yeti_horn { name = "Yeti Horn"; MaterialClass = "YetiHorn"; icon_state = "yeti_horn"; tier = 4 }
/obj/Items/Material/MonsterPart/stone_golem_core { name = "Stone Golem Core"; MaterialClass = "StoneGolemCore"; icon_state = "stone_golem_core"; tier = 4 }
/obj/Items/Material/MonsterPart/fire_golem_core { name = "Fire Golem Core"; MaterialClass = "FireGolemCore"; icon_state = "fire_golem_core"; tier = 4 }
/obj/Items/Material/MonsterPart/golden_tooth { name = "Golden Tooth"; MaterialClass = "GoldenTooth"; icon_state = "golden_tooth"; tier = 4 }
/obj/Items/Material/MonsterPart/red_eye { name = "Red Eye"; MaterialClass = "RedEye"; icon_state = "red_eye"; tier = 4 }
/obj/Items/Material/MonsterPart/sorrowful_tears { name = "Sorrowful Tears"; MaterialClass = "SorrowfulTears"; icon_state = "sorrowful_tears"; tier = 4 }
/obj/Items/Material/MonsterPart/demon_leg { name = "Demon Leg"; MaterialClass = "DemonLeg"; icon_state = "demon_leg"; tier = 4 }
/obj/Items/Material/MonsterPart/dragon_scale { name = "Dragon Scale"; MaterialClass = "DragonScale"; icon_state = "dragon_scale"; tier = 5 }
/obj/Items/Material/MonsterPart/dragon_bone { name = "Dragon Bone"; MaterialClass = "DragonBone"; icon_state = "dragon_bone"; tier = 5 }
/obj/Items/Material/MonsterPart/dragon_essence { name = "Dragon Essence"; MaterialClass = "DragonEssence"; icon_state = "dragon_essence"; tier = 5 }
/obj/Items/Material/MonsterPart/colossal_core { name = "Colossal Core"; MaterialClass = "ColossalCore"; icon_state = "colossal_core"; tier = 5 }
/obj/Items/Material/MonsterPart/fire_dragon_claw { name = "Fire Dragon Claw"; MaterialClass = "FireDragonClaw"; icon_state = "fire_dragon_claw"; tier = 5 }
/obj/Items/Material/MonsterPart/white_dragon_claw { name = "White Dragon Claw"; MaterialClass = "WhiteDragonClaw"; icon_state = "white_dragon_claw"; tier = 5 }
/obj/Items/Material/MonsterPart/poison_dragon_claw { name = "Poison Dragon Claw"; MaterialClass = "PoisonDragonClaw"; icon_state = "poison_dragon_claw"; tier = 5 }
/obj/Items/Material/MonsterPart/water_dragon_claw { name = "Water Dragon Claw"; MaterialClass = "WaterDragonClaw"; icon_state = "water_dragon_claw"; tier = 5 }
/obj/Items/Material/MonsterPart/golden_dragon_claw { name = "Golden Dragon Claw"; MaterialClass = "GoldenDragonClaw"; icon_state = "golden_dragon_claw"; tier = 5 }
// rare-pool refill (regular drops added when the 8 above were reserved rare_only)
/obj/Items/Material/MonsterPart/ant_antennae { name = "Ant Antennae"; MaterialClass = "AntAntennae"; icon_state = "ant_antennae"; tier = 2 }
/obj/Items/Material/MonsterPart/mud_golem_core { name = "Mud Golem Core"; MaterialClass = "MudGolemCore"; icon_state = "mud_golem_core"; tier = 3 }
/obj/Items/Material/MonsterPart/cyclops_horn { name = "Cyclops Horn"; MaterialClass = "CyclopsHorn"; icon_state = "cyclops_horn"; tier = 4 }
/obj/Items/Material/MonsterPart/broken_shield { name = "Broken Shield"; MaterialClass = "BrokenShield"; icon_state = "broken_shield"; tier = 4 }
/obj/Items/Material/MonsterPart/elder_scroll { name = "Elder Scroll"; MaterialClass = "ElderScroll"; icon_state = "elder_scroll"; tier = 4 }
/obj/Items/Material/MonsterPart/colossal_scale { name = "Colossal Dragon Scale"; MaterialClass = "ColossalScale"; icon_state = "colossal_scale"; tier = 5 }
/obj/Items/Material/MonsterPart/ashes_dragon_claw { name = "Ashes Dragon Claw"; MaterialClass = "AshesDragonClaw"; icon_state = "ashes_dragon_claw"; tier = 5 }
/obj/Items/Material/MonsterPart/earth_dragon_gem { name = "Earth Dragon Gemstone"; MaterialClass = "EarthDragonGem"; icon_state = "earth_dragon_gem"; tier = 5 }

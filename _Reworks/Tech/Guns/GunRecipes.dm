proc/GunRecipeMetal(datum/craft_recipe/lifecraft/R, list/picks)
	if(!R || !R.slots || !islist(picks))
		return null
	for(var/i = 1 to min(R.slots.len, picks.len))
		var/datum/craft_slotreq/S = R.slots[i]
		if(S.name != "Metal")
			continue
		var/list/p = picks[i]
		if(!islist(p) || !p.len)
			return null
		var/mid = lowertext("[p[1]]")
		return LIFE_METAL_TIER[mid] ? mid : null
	return null

proc/GunCraftName(obj/Items/Gun/G, mid)
	if(G.CraftQuality == QUAL_LEGENDARY && length(G.LegendNames))
		return pick(G.LegendNames)
	var/q = (G.CraftQuality == QUAL_NORMAL) ? "" : "[QualityName(G.CraftQuality)] "
	var/m = mid ? "[LIFE_METAL_NAME[mid]] " : ""
	return "[q][m][initial(G.name)]"

/datum/craft_recipe/lifecraft/tech/gun
	TemplateSlots()
		. = list(list("Metal", 1, TECH_SEL_INGOT, tier))
		. += list(list("Casing", 1, TECH_MAT_CASING, 1))

	MakeResult(mob/M, q, perf, list/picks)
		var/mid = GunRecipeMetal(src, picks)
		. = ..()
		var/obj/Items/Gun/G = .
		if(!istype(G))
			return
		G.metal_id = mid
		G.setStatLine()
		G.name = GunCraftName(G, mid)

/datum/craft_recipe/lifecraft/tech/gun/handgun
	id = "tech_gun_handgun"
	label = "Handgun"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Gun/Handgun/Handgun

/datum/craft_recipe/lifecraft/tech/gun/usp
	id = "tech_gun_usp"
	label = "USP"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Gun/Handgun/USP

/datum/craft_recipe/lifecraft/tech/gun/red9
	id = "tech_gun_red9"
	label = "Red 9"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Gun/Handgun/Red9

/datum/craft_recipe/lifecraft/tech/gun/magnum
	id = "tech_gun_magnum"
	label = "Magnum"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Gun/Handgun/Magnum
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/gun/dualwield
	id = "tech_gun_dualwield"
	label = "Dualwield"
	tier = 4
	knowledge_req = "Heavy Weaponry"
	result_type = /obj/Items/Gun/Handgun/Dualwield

/datum/craft_recipe/lifecraft/tech/gun/smg
	id = "tech_gun_smg"
	label = "SMG"
	tier = 2
	knowledge_req = "Assault Weaponry"
	result_type = /obj/Items/Gun/Automatic/SMG
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/gun/TMP
	id = "tech_gun_tmp"
	label = "TMP"
	tier = 2
	knowledge_req = "Assault Weaponry"
	result_type = /obj/Items/Gun/Automatic/TMP
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/gun/glock18c
	id = "tech_gun_glock18c"
	label = "Glock 18C"
	tier = 3
	knowledge_req = "Weapon Modding"
	result_type = /obj/Items/Gun/Automatic/Glock18C
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/gun/tactical
	id = "tech_gun_tactical"
	label = "Tactical"
	tier = 4
	knowledge_req = "Heavy Weaponry"
	result_type = /obj/Items/Gun/Automatic/Tactical
	add_slots = list(\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/gun/shotgun
	id = "tech_gun_shotgun"
	label = "Shotgun"
	tier = 2
	knowledge_req = "Assault Weaponry"
	result_type = /obj/Items/Gun/Shotgun/Shotgun

/datum/craft_recipe/lifecraft/tech/gun/punisher
	id = "tech_gun_punisher"
	label = "Punisher"
	tier = 4
	knowledge_req = "Heavy Weaponry"
	result_type = /obj/Items/Gun/Shotgun/Punisher

/datum/craft_recipe/lifecraft/tech/field/ammo

/datum/craft_recipe/lifecraft/tech/field/ammo/pistol
	id = "tech_ammo_pistol"
	label = "Pistol Rounds"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Ammo/Pistol/Standard
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/rifle
	id = "tech_ammo_rifle"
	label = "Rifle Rounds"
	tier = 2
	knowledge_req = "Assault Weaponry"
	result_type = /obj/Items/Ammo/Rifle/Standard
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 1, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/shells
	id = "tech_ammo_shells"
	label = "Shotgun Shells"
	tier = 2
	knowledge_req = "Assault Weaponry"
	result_type = /obj/Items/Ammo/Shell/Standard
	result_count = GUN_SHELLS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Iron", 1, "mat:Iron", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/training_pistol
	id = "tech_ammo_training_pistol"
	label = "Training Pistol Rounds"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Ammo/Pistol/Training
	result_count = GUN_TRAINING_PER_RUN
	slotspec = list(list("Propellant", 1, TECH_MAT_PROPELLANT, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/training_rifle
	id = "tech_ammo_training_rifle"
	label = "Training Rifle Rounds"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Ammo/Rifle/Training
	result_count = GUN_TRAINING_PER_RUN
	slotspec = list(list("Propellant", 1, TECH_MAT_PROPELLANT, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/training_shells
	id = "tech_ammo_training_shells"
	label = "Training Shells"
	tier = 1
	knowledge_req = "Military Technology"
	result_type = /obj/Items/Ammo/Shell/Training
	result_count = GUN_TRAINING_PER_RUN
	slotspec = list(list("Propellant", 1, TECH_MAT_PROPELLANT, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/hollow_point_pistol
	id = "tech_ammo_hp_pistol"
	label = "Hollow-Point Pistol Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Pistol/Hollow_Point
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1),\
		list("Gelatin", 1, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/hollow_point_rifle
	id = "tech_ammo_hp_rifle"
	label = "Hollow-Point Rifle Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Rifle/Hollow_Point
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 1, "mat:Steel", 1),\
		list("Gelatin", 1, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/armor_piercing_pistol
	id = "tech_ammo_ap_pistol"
	label = "Armor-Piercing Pistol Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Pistol/Armor_Piercing
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1),\
		list("Steel", 1, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/armor_piercing_rifle
	id = "tech_ammo_ap_rifle"
	label = "Armor-Piercing Rifle Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Rifle/Armor_Piercing
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 2, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/tranq_pistol
	id = "tech_ammo_tranq_pistol"
	label = "Tranq Pistol Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Pistol/Tranq
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1),\
		list("Gel", 1, TECH_MAT_BIOGEL, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/tranq_rifle
	id = "tech_ammo_tranq_rifle"
	label = "Tranq Rifle Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Rifle/Tranq
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 1, "mat:Steel", 1),\
		list("Gel", 1, TECH_MAT_BIOGEL, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/tracer_pistol
	id = "tech_ammo_tracer_pistol"
	label = "Tracer Pistol Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Pistol/Tracer
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1),\
		list("Shards", 1, "mat:GemShards", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/tracer_rifle
	id = "tech_ammo_tracer_rifle"
	label = "Tracer Rifle Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Rifle/Tracer
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 1, "mat:Steel", 1),\
		list("Shards", 1, "mat:GemShards", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/emp_pistol
	id = "tech_ammo_emp_pistol"
	label = "EMP Pistol Rounds"
	tier = 4
	knowledge_req = "Electronic Warfare"
	result_type = /obj/Items/Ammo/Pistol/EMP
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/emp_rifle
	id = "tech_ammo_emp_rifle"
	label = "EMP Rifle Rounds"
	tier = 4
	knowledge_req = "Electronic Warfare"
	result_type = /obj/Items/Ammo/Rifle/EMP
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 1, "mat:Steel", 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/slug
	id = "tech_ammo_slug"
	label = "Slug Shells"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Shell/Slug
	result_count = GUN_SHELLS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Iron", 2, "mat:Iron", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/dragons_breath
	id = "tech_ammo_dragons_breath"
	label = "Dragon's Breath Shells"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Shell/Dragons_Breath
	result_count = GUN_SHELLS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Iron", 1, "mat:Iron", 1),\
		list("Coal", 2, "mat:Coal", 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod
	tier = 3
	knowledge_req = "Weapon Modding"

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/extended_mag
	id = "tech_mod_extended_mag"
	label = "Extended Mag"
	result_type = /obj/Items/GunMod/Extended_Mag
	add_slots = list(list("Casing", 1, TECH_MAT_CASING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/scope
	id = "tech_mod_scope"
	label = "Scope"
	result_type = /obj/Items/GunMod/Scope
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/compensator
	id = "tech_mod_compensator"
	label = "Compensator"
	result_type = /obj/Items/GunMod/Compensator
	add_slots = list(list("Steel", 1, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/speed_loader
	id = "tech_mod_speed_loader"
	label = "Speed Loader"
	result_type = /obj/Items/GunMod/Speed_Loader
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/laser_sight
	id = "tech_mod_laser_sight"
	label = "Laser Sight"
	result_type = /obj/Items/GunMod/Laser_Sight
	add_slots = list(\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Wiring", 1, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/bayonet
	id = "tech_mod_bayonet"
	label = "Bayonet"
	result_type = /obj/Items/GunMod/Bayonet
	add_slots = list(list("Steel", 2, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/suppressor
	id = "tech_mod_suppressor"
	label = "Suppressor"
	result_type = /obj/Items/GunMod/Suppressor
	add_slots = list(list("Casing", 2, TECH_MAT_CASING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/gunmod/underbarrel_launcher
	id = "tech_mod_underbarrel"
	label = "Underbarrel Launcher"
	result_type = /obj/Items/GunMod/Underbarrel_Launcher
	add_slots = list(\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/ballistic_weave
	id = "tech_ballistic_weave"
	label = "Ballistic Weave"
	tier = 3
	knowledge_req = "Weapon Modding"
	result_type = /obj/Items/GunMod/Ballistic_Weave
	slotspec = list(\
		list("Sinew", 2, "mat:BoarSinew", 1),\
		list("Steel", 1, "mat:Steel", 1),\
		list("Casing", 1, TECH_MAT_CASING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/heavy
	tier = 4
	knowledge_req = "Heavy Weaponry"

/datum/craft_recipe/lifecraft/tech/handheld/heavy/missile_launcher
	id = "tech_missile_launcher"
	label = "Missile Launcher"
	result_type = /obj/Items/Gear/Missile_Launcher
	add_slots = list(list("Propellant", 2, TECH_MAT_PROPELLANT, 1))

/datum/craft_recipe/lifecraft/tech/handheld/heavy/incinerator
	id = "tech_incinerator"
	label = "Incinerator"
	result_type = /obj/Items/Gear/Incinerator
	add_slots = list(list("Fuel", 1, TECH_MAT_FUELCELL, 1))

/datum/craft_recipe/lifecraft/tech/handheld/heavy/freeze_ray
	id = "tech_freeze_ray"
	label = "Freeze Ray"
	result_type = /obj/Items/Gear/Freeze_Ray
	add_slots = list(\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Gel", 1, TECH_MAT_BIOGEL, 1))

/datum/craft_recipe/lifecraft/tech/chemical_mortar
	id = "tech_chemical_mortar"
	label = "Chemical Mortar"
	tier = 4
	knowledge_req = "Heavy Weaponry"
	result_type = /obj/Items/Gear/Chemical_Mortar
	slotspec = list(\
		list("Gel", 2, TECH_MAT_BIOGEL, 1),\
		list("Propellant", 2, TECH_MAT_PROPELLANT, 1))
	item_inputs = list(/obj/Items/Gear/Missile_Launcher = 1)

/datum/craft_recipe/lifecraft/tech/handheld/mech_part
	tier = MECH_TIER_LIGHT
	knowledge_req = "Mech Fabrication"

	New()
		if(tier >= MECH_TIER_WALKER)
			knowledge_req = "Vehicular Power Armor"
			if(!add_slots) add_slots = list()
			add_slots += list(list("Nanites", 1, TECH_MAT_NANITES, 1))
		..()

	MakeResult(mob/M, q, perf, list/picks)
		var/mid = MechRecipeMetal(src, picks)
		. = ..()
		var/obj/Items/I = .
		if(!istype(I)) return
		I.metal_id = mid
		if(istype(I, /obj/Items/Gun))
			var/obj/Items/Gun/G = I
			G.setStatLine()
			G.name = GunCraftName(G, mid)
		else
			I.name = MechPartCraftName(I, mid)

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee
	add_slots = list(\
		list("Metal", 3, TECH_SEL_INGOT, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/heat_hawk
	id = "tech_mech_heat_hawk"
	label = "Heat Hawk"
	result_type = /obj/Items/MechPart/Arm/Heat_Hawk

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/beam_saber
	id = "tech_mech_beam_saber"
	label = "Beam Saber"
	result_type = /obj/Items/MechPart/Arm/Beam_Saber

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/progressive_knife
	id = "tech_mech_progressive_knife"
	label = "Progressive Knife"
	result_type = /obj/Items/MechPart/Arm/Progressive_Knife

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/heat_rod
	id = "tech_mech_heat_rod"
	label = "Heat Rod"
	result_type = /obj/Items/MechPart/Arm/Heat_Rod

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/claw_arm
	id = "tech_mech_claw_arm"
	label = "Claw Arm"
	result_type = /obj/Items/MechPart/Arm/Claw_Arm
	item_inputs = list(/obj/Items/Gear/Power_Claw = 1)

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/power_fist
	id = "tech_mech_power_fist"
	label = "Power Fist"
	result_type = /obj/Items/MechPart/Arm/Power_Fist
	item_inputs = list(/obj/Items/Gear/Blast_Fist = 1)

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/chainsaw_blade
	id = "tech_mech_chainsaw_blade"
	label = "Chainsaw Blade"
	result_type = /obj/Items/MechPart/Arm/Chainsaw_Blade
	item_inputs = list(/obj/Items/Gear/Chainsaw = 1)

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/mech_shield
	id = "tech_mech_shield"
	label = "Mech Shield"
	result_type = /obj/Items/MechPart/Arm/Mech_Shield

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/rocket_punch
	id = "tech_mech_rocket_punch"
	label = "Rocket Punch"
	result_type = /obj/Items/MechPart/Arm/Rocket_Punch

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/pile_bunker
	id = "tech_mech_pile_bunker"
	label = "Pile Bunker"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Arm/Pile_Bunker
	item_inputs = list(/obj/Items/Gear/Pile_Bunker = 1)

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/drill_arm
	id = "tech_mech_drill_arm"
	label = "Drill Arm"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Arm/Drill_Arm

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/melee/giga_drill
	id = "tech_mech_giga_drill"
	label = "Giga Drill"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Arm/Giga_Drill
	add_slots = list(\
		list("Metal", 6, TECH_SEL_INGOT, 1),\
		list("Servo", 2, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/energy
	add_slots = list(\
		list("Lens", 2, TECH_MAT_LENS, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/energy/beam_rifle
	id = "tech_mech_beam_rifle"
	label = "Beam Rifle"
	result_type = /obj/Items/Gun/Handgun/Beam_Rifle

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/energy/beam_machine_gun
	id = "tech_mech_beam_machine_gun"
	label = "Beam Machine Gun"
	result_type = /obj/Items/Gun/Automatic/Beam_Machine_Gun

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/energy/scatter_beam_gun
	id = "tech_mech_scatter_beam_gun"
	label = "Scatter Beam Gun"
	result_type = /obj/Items/Gun/Shotgun/Scatter_Beam_Gun

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/energy/beam_magnum
	id = "tech_mech_beam_magnum"
	label = "Beam Magnum"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/Gun/Handgun/Beam_Magnum

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/energy/twin_buster_rifle
	id = "tech_mech_twin_buster_rifle"
	label = "Twin Buster Rifle"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/Gun/Handgun/Twin_Buster_Rifle

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/ballistic
	add_slots = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Propellant", 2, TECH_MAT_PROPELLANT, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/ballistic/gatling_arm
	id = "tech_mech_gatling_arm"
	label = "Gatling Arm"
	result_type = /obj/Items/Gun/Automatic/Gatling_Arm

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/ballistic/hyper_bazooka
	id = "tech_mech_hyper_bazooka"
	label = "Hyper Bazooka"
	result_type = /obj/Items/Gun/Handgun/Hyper_Bazooka

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back
	add_slots = list(\
		list("Casing", 3, TECH_MAT_CASING, 1),\
		list("Propellant", 3, TECH_MAT_PROPELLANT, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back/missile_pod
	id = "tech_mech_missile_pod"
	label = "Missile Pod"
	result_type = /obj/Items/MechPart/Back/Missile_Pod

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back/micro_missile_swarm
	id = "tech_mech_micro_missile_swarm"
	label = "Micro-Missile Swarm"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Micro_Missile_Swarm

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back/shoulder_cannon
	id = "tech_mech_shoulder_cannon"
	label = "Shoulder Cannon"
	result_type = /obj/Items/MechPart/Back/Shoulder_Cannon

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back/grenade_rack
	id = "tech_mech_grenade_rack"
	label = "Grenade Rack"
	result_type = /obj/Items/MechPart/Back/Grenade_Rack

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back_energy
	add_slots = list(\
		list("Casing", 3, TECH_MAT_CASING, 1),\
		list("Lens", 2, TECH_MAT_LENS, 1),\
		list("Cell", 2, TECH_MAT_CELL, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back_energy/mega_particle_cannon
	id = "tech_mech_mega_particle_cannon"
	label = "Mega Particle Cannon"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Mega_Particle_Cannon

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/back_energy/satellite_cannon
	id = "tech_mech_satellite_cannon"
	label = "Satellite Cannon"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Satellite_Cannon

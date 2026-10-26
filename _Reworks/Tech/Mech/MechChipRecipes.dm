/datum/craft_recipe/lifecraft/tech/handheld/chip/mech
	tier = MECH_TIER_LIGHT
	knowledge_req = "Mech Fabrication"
	drop_slots = list("Casing", "Wiring", "Board", "Optic")
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/mech/mech_alarm
	id = "chip_mech_alarm"
	label = "Mech Alarm"
	result_type = /obj/Items/Chip/System/Mech_Alarm

/datum/craft_recipe/lifecraft/tech/handheld/chip/mech/mech_beacon
	id = "chip_mech_beacon"
	label = "Mech Beacon"
	result_type = /obj/Items/Chip/System/Mech_Beacon
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1))

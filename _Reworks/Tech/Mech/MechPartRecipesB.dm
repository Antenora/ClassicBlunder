/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back
	add_slots = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/booster_pack
	id = "tech_mech_booster_pack"
	label = "Booster Pack"
	result_type = /obj/Items/MechPart/Back/Booster_Pack

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/shoulder_ram
	id = "tech_mech_shoulder_ram"
	label = "Shoulder Ram"
	result_type = /obj/Items/MechPart/Back/Shoulder_Ram

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/chaff_and_smoke
	id = "tech_mech_chaff_and_smoke"
	label = "Chaff and Smoke"
	result_type = /obj/Items/MechPart/Back/Chaff_and_Smoke

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/heat_sink_fins
	id = "tech_mech_heat_sink_fins"
	label = "Heat Sink Fins"
	result_type = /obj/Items/MechPart/Back/Heat_Sink_Fins

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/back_shield
	id = "tech_mech_back_shield"
	label = "Back Shield"
	result_type = /obj/Items/MechPart/Back/Back_Shield

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/sub_arms
	id = "tech_mech_sub_arms"
	label = "Sub-Arms"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Sub_Arms

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/wing_binder
	id = "tech_mech_wing_binder"
	label = "Wing Binder"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Wing_Binder
	add_slots = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Cell", 2, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/funnel_rack
	id = "tech_mech_funnel_rack"
	label = "Funnel Rack"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Funnel_Rack
	add_slots = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1),\
		list("Board", 2, TECH_MAT_BOARD, 1),\
		list("Lens", 3, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/system_back/fin_funnel_barrier
	id = "tech_mech_fin_funnel_barrier"
	label = "Fin Funnel Barrier"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Back/Fin_Funnel_Barrier
	add_slots = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1),\
		list("Lens", 2, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/charge_capacitor
	id = "tech_mech_charge_capacitor"
	label = "Charge Capacitor"
	result_type = /obj/Items/MechPart/Internal/Charge_Capacitor
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Cell", 2, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/cooling_system
	id = "tech_mech_cooling_system"
	label = "Cooling System"
	result_type = /obj/Items/MechPart/Internal/Cooling_System
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/emergency_coolant
	id = "tech_mech_emergency_coolant"
	label = "Emergency Coolant"
	result_type = /obj/Items/MechPart/Internal/Emergency_Coolant
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Gel", 2, TECH_MAT_BIOGEL, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/targeting_fcs
	id = "tech_mech_targeting_fcs"
	label = "Targeting FCS"
	result_type = /obj/Items/MechPart/Internal/Targeting_FCS
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Lens", 2, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/sensor_package
	id = "tech_mech_sensor_package"
	label = "Sensor Package"
	result_type = /obj/Items/MechPart/Internal/Sensor_Package
	add_slots = list(\
		list("Board", 2, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/reactive_armor
	id = "tech_mech_reactive_armor"
	label = "Reactive Armor"
	result_type = /obj/Items/MechPart/Internal/Reactive_Armor
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Metal", 4, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/ejection_booster
	id = "tech_mech_ejection_booster"
	label = "Ejection Booster"
	result_type = /obj/Items/MechPart/Internal/Ejection_Booster

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/auto_repair_nanites
	id = "tech_mech_auto_repair_nanites"
	label = "Auto-Repair Nanites"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Internal/Auto_Repair_Nanites
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Nanites", 2, TECH_MAT_NANITES, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/internal/finger_amplifier
	id = "tech_mech_finger_amplifier"
	label = "Finger Amplifier"
	tier = MECH_TIER_WALKER
	result_type = /obj/Items/MechPart/Internal/Finger_Amplifier

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/limit_drive
	tier = MECH_TIER_WALKER
	add_slots = list(\
		list("Cell", 3, TECH_MAT_CELL, 1),\
		list("Board", 2, TECH_MAT_BOARD, 1),\
		list("Core", 1, TECH_SEL_CORE, 1),\
		list("Nanites", 1, TECH_MAT_NANITES, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/limit_drive/trans_am
	id = "tech_mech_trans_am_drive"
	label = "Trans-Am Drive"
	result_type = /obj/Items/MechPart/Internal/Trans_Am_Drive

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/limit_drive/fortress
	id = "tech_mech_fortress_drive"
	label = "Fortress Drive"
	result_type = /obj/Items/MechPart/Internal/Fortress_Drive

/datum/craft_recipe/lifecraft/tech/handheld/mech_part/limit_drive/destroyer
	id = "tech_mech_destroyer_drive"
	label = "Destroyer Drive"
	result_type = /obj/Items/MechPart/Internal/Destroyer_Drive

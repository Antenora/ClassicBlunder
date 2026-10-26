var/_emp_audit_boot = EmplacementAuditBoot()

proc/EmplacementAuditBoot()
	spawn(0)
		if(TECH_AUDIT_EXCLUDE)
			TECH_AUDIT_EXCLUDE[/obj/Items/Gear/Field_Gadget] = "abstract parent of the three field gadgets, brief 21"
	return 1

/datum/craft_recipe/lifecraft/tech/placed/sentry_turret
	id = "tech_sentry_turret"
	label = "Sentry Turret"
	tier = 4
	knowledge_req = "Automated Defenses"
	result_type = /obj/Items/Tech/Sentry_Turret
	add_slots = list(\
		list("Servo", 2, TECH_MAT_SERVO, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/placed/force_field_emitter
	id = "tech_force_field_emitter"
	label = "Force Field Emitter"
	tier = 4
	knowledge_req = "Force Shielding"
	result_type = /obj/Items/Tech/Force_Field_Emitter
	add_slots = list(\
		list("Lens", 2, TECH_MAT_LENS, 1),\
		list("Cell", 2, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/handheld/force_field_remote
	id = "tech_force_field_remote"
	label = "Force Field Remote"
	tier = 4
	knowledge_req = "Force Shielding"
	result_type = /obj/Items/Tech/Force_Field_Remote

/datum/craft_recipe/lifecraft/tech/handheld/field_gadget
	tier = 3
	knowledge_req = "Field Gadgets"
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/field_gadget/ore_scanner
	id = "tech_ore_scanner"
	label = "Ore Scanner"
	result_type = /obj/Items/Gear/Field_Gadget/Ore_Scanner

/datum/craft_recipe/lifecraft/tech/handheld/field_gadget/fish_finder
	id = "tech_fish_finder"
	label = "Fish Finder"
	result_type = /obj/Items/Gear/Field_Gadget/Fish_Finder

/datum/craft_recipe/lifecraft/tech/handheld/field_gadget/botanical_analyzer
	id = "tech_botanical_analyzer"
	label = "Botanical Analyzer"
	result_type = /obj/Items/Gear/Field_Gadget/Botanical_Analyzer

/datum/craft_recipe/lifecraft/tech/placed/auto_sprinkler
	id = "tech_auto_sprinkler"
	label = "Auto-Sprinkler"
	tier = 3
	knowledge_req = "Field Gadgets"
	result_type = /obj/Items/Tech/Auto_Sprinkler

/datum/craft_recipe/lifecraft/tech/placed/drone
	id = "tech_drone"
	label = "Drone"
	tier = 4
	knowledge_req = "Drones"
	result_type = /obj/Items/Tech/Drone
	add_slots = list(list("Servo", 2, TECH_MAT_SERVO, 1))

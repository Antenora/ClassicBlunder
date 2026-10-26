var/_dev_audit_boot = DeviceAuditBoot()

proc/DeviceAuditBoot()
	spawn(0)
		if(TECH_AUDIT_EXCLUDE)
			TECH_AUDIT_EXCLUDE[/obj/Items/Tech/Emitter] = "abstract parent of the five emitters, brief 20"
	return 1

/datum/craft_recipe/lifecraft/tech/handheld/alarm
	id = "tech_alarm"
	label = "Alarm"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Alarm
	add_slots = list(list("Wiring", 2, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/lamp
	id = "tech_lamp"
	label = "Lamp"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Lamp
	add_slots = list(list("Shards", 1, "mat:GemShards", 1))

/datum/craft_recipe/lifecraft/tech/street_light
	id = "tech_street_light"
	label = "Street Light"
	tier = 2
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Street_Light
	slotspec = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/holo_sign
	id = "tech_holo_sign"
	label = "Holo-Sign"
	tier = 2
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Holo_Sign
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/door_repair_kit
	id = "tech_door_repair_kit"
	label = "Door Repair Kit"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Door_Repair_Kit
	slotspec = list(\
		list("Iron", 2, "mat:Iron", 1),\
		list("Wiring", 1, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/training_dummy
	id = "tech_training_dummy"
	label = "Training Dummy"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/PunchingBag
	slotspec = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/placed/aid_station
	id = "tech_aid_station"
	label = "Aid Station"
	tier = 2
	knowledge_req = "Trauma Care"
	result_type = /obj/Items/Tech/Aid_Station
	drop_slots = list("Cell")

/datum/craft_recipe/lifecraft/tech/handheld/emitter
	tier = 4
	knowledge_req = "EM Wave Projectors"
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/emitter/blutz_wave
	id = "tech_emitter_blutz_wave"
	label = "Blutz Wave Emitter"
	result_type = /obj/Items/Tech/Emitter/Blutz_Wave

/datum/craft_recipe/lifecraft/tech/handheld/emitter/ultraviolet
	id = "tech_emitter_ultraviolet"
	label = "Ultraviolet Emitter"
	result_type = /obj/Items/Tech/Emitter/Ultraviolet

/datum/craft_recipe/lifecraft/tech/handheld/emitter/gravity_well
	id = "tech_emitter_gravity_well"
	label = "Gravity Well Emitter"
	result_type = /obj/Items/Tech/Emitter/Gravity_Well
	add_slots = list(\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/handheld/emitter/jammer
	id = "tech_emitter_jammer"
	label = "Jammer Emitter"
	result_type = /obj/Items/Tech/Emitter/Jammer
	add_slots = list(\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/handheld/emitter/rain_seeder
	id = "tech_emitter_rain_seeder"
	label = "Rain Seeder Emitter"
	result_type = /obj/Items/Tech/Emitter/Rain_Seeder
	add_slots = list(\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Herb", 2, TECH_SEL_HERB, 1))

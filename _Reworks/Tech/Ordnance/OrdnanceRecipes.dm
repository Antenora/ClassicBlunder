/datum/craft_recipe/lifecraft/tech/ordnance

/datum/craft_recipe/lifecraft/tech/ordnance/frag_grenade
	id = "tech_frag_grenade"
	label = "Frag Grenade"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Frag_Grenade
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Propellant", 2, TECH_MAT_PROPELLANT, 1))

/datum/craft_recipe/lifecraft/tech/ordnance/smoke_grenade
	id = "tech_smoke_grenade"
	label = "Smoke Grenade"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Smoke_Grenade
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Coal", 2, "mat:Coal", 1))

/datum/craft_recipe/lifecraft/tech/ordnance/flash_grenade
	id = "tech_flash_grenade"
	label = "Flash Grenade"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Flash_Grenade
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Shards", 1, "mat:GemShards", 1))

/datum/craft_recipe/lifecraft/tech/ordnance/gas_grenade
	id = "tech_gas_grenade"
	label = "Gas Grenade"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Gas_Grenade
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Gel", 1, TECH_MAT_BIOGEL, 1),\
		list("Herb", 1, TECH_SEL_HERB, 1))

/datum/craft_recipe/lifecraft/tech/ordnance/caltrops
	id = "tech_caltrops"
	label = "Caltrops"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Caltrops
	slotspec = list(list("Iron", 2, "mat:Iron", 1))

/datum/craft_recipe/lifecraft/tech/ordnance/flare
	id = "tech_flare"
	label = "Flare"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Flare
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Coal", 1, "mat:Coal", 1))

/datum/craft_recipe/lifecraft/tech/ordnance/bola
	id = "tech_bola"
	label = "Bola"
	tier = 2
	knowledge_req = "Demolitions"
	result_type = /obj/Items/Ordnance/Bola
	slotspec = list(\
		list("Sinew", 1, "mat:BoarSinew", 1),\
		list("Iron", 1, "mat:Iron", 1))

/datum/craft_recipe/lifecraft/tech/ordnance/emp_grenade
	id = "tech_emp_grenade"
	label = "EMP Grenade"
	tier = 4
	knowledge_req = "Electronic Warfare"
	result_type = /obj/Items/Ordnance/EMP_Grenade
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/ordnance/emp_mine
	id = "tech_emp_mine"
	label = "EMP Mine"
	tier = 4
	knowledge_req = "Electronic Warfare"
	result_type = /obj/Items/Ordnance/EMP_Mine
	slotspec = list(\
		list("Casing", 3, TECH_MAT_CASING, 1),\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/ordnance/frag_mine
	id = "tech_frag_mine"
	label = "Frag Mine"
	tier = 4
	knowledge_req = "Electronic Warfare"
	result_type = /obj/Items/Ordnance/Frag_Mine
	slotspec = list(list("Board", 1, TECH_MAT_BOARD, 1))
	item_inputs = list(/obj/Items/Ordnance/Frag_Grenade = 1)

/datum/craft_recipe/lifecraft/tech/ordnance/breaching_charge
	id = "tech_breaching_charge"
	label = "Breaching Charge"
	tier = 4
	knowledge_req = "Electronic Warfare"
	result_type = /obj/Items/Ordnance/Breaching_Charge
	slotspec = list(\
		list("Propellant", 4, TECH_MAT_PROPELLANT, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1))

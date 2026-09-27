/datum/craft_recipe/lifecraft/tech/consumable/coagulant_spray
	id = "tech_coagulant_spray"
	label = "Coagulant Spray"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Coagulant_Spray
	item_inputs = list(/obj/Items/Tech/Soap = 1)

/datum/craft_recipe/lifecraft/tech/consumable/restorative_salve
	id = "tech_restorative_salve"
	label = "Restorative Salve"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Restorative_Salve
	item_inputs = list(/obj/Items/Tech/Perfume = 1)

/datum/craft_recipe/lifecraft/tech/consumable/emergency_autoinjector
	id = "tech_emergency_autoinjector"
	label = "Emergency Autoinjector"
	tier = 2
	knowledge_req = "Trauma Care"
	result_type = /obj/Items/Tech/Emergency_Autoinjector
	add_slots = list(list("Wiring", 1, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/defibrillator
	id = "tech_defibrillator"
	label = "Defibrillator"
	tier = 2
	knowledge_req = "Medkits"
	result_type = /obj/Items/Tech/Defibrillator
	add_slots = list(list("Cell", 1, TECH_MAT_CELL, 1))

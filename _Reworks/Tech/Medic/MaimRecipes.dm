/datum/craft_recipe/lifecraft/tech/consumable/trauma_kit
	id = "tech_trauma_kit"
	label = "Trauma Kit"
	tier = 2
	knowledge_req = "Trauma Care"
	result_type = /obj/Items/Tech/Trauma_Kit
	drop_slots = list("Herb")
	add_slots = list(list("Gel", 1, TECH_MAT_BIOGEL, 1), list("Gelatin", 1, "mat:Gelatin", 1), list("Casing", 1, TECH_MAT_CASING, 1))

/datum/craft_recipe/lifecraft/tech/consumable/painkillers
	id = "tech_painkillers"
	label = "Painkillers"
	tier = 2
	knowledge_req = "Trauma Care"
	result_type = /obj/Items/Tech/PainKillers

/datum/craft_recipe/lifecraft/tech/handheld/medical_scanner
	id = "tech_medical_scanner"
	label = "Medical Scanner"
	tier = 1
	knowledge_req = "Medicine"
	result_type = /obj/Items/Tech/Medical_Scanner

/datum/craft_recipe/lifecraft/tech/consumable/surgery_kit
	id = "tech_surgery_kit"
	label = "Surgery Kit"
	tier = 3
	knowledge_req = "Improved Medical Technology"
	result_type = /obj/Items/Tech/Surgery_Kit
	add_slots = list(list("Casing", 1, TECH_MAT_CASING, 1), list("Lens", 1, TECH_MAT_LENS, 1))
	item_inputs = list(/obj/Items/Tech/Soap = 1)

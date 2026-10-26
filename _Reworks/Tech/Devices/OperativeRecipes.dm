/datum/craft_recipe/lifecraft/tech/tracker_tag
	id = "tech_tracker_tag"
	label = "Tracker Tag"
	tier = 2
	knowledge_req = "Espionage Equipment"
	result_type = /obj/Items/Tech/Tracker_Tag
	result_count = 3
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/bug_sweeper
	id = "tech_bug_sweeper"
	label = "Bug Sweeper"
	tier = 2
	knowledge_req = "Espionage Equipment"
	result_type = /obj/Items/Tech/Bug_Sweeper

/datum/craft_recipe/lifecraft/tech/handheld/dragon_radar
	id = "tech_dragon_radar"
	label = "Dragon Radar"
	tier = 2
	knowledge_req = "Scouters"
	result_type = /obj/Items/Tech/Dragon_Radar
	add_slots = list(\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Shards", 2, "mat:GemShards", 1))

/datum/craft_recipe/lifecraft/tech/handheld/jammer
	id = "tech_jammer"
	label = "Jammer"
	tier = 3
	knowledge_req = "Intrusion Tools"
	result_type = /obj/Items/Tech/Jammer
	add_slots = list(list("Board", 1, TECH_MAT_BOARD, 1))

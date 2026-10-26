/datum/craft_recipe/lifecraft/tech/hoverboard
	id = "tech_hoverboard"
	label = "Hoverboard"
	tier = 1
	knowledge_req = "Military Engineering"
	result_type = /obj/Items/Gear/Hoverboard
	slotspec = list(\
		list("Casing", 2, TECH_MAT_CASING, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1),\
		list("Metal", 2, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/powered_tool
	tier = 2
	knowledge_req = "Military Engineering"
	result_type = /obj/Items/LifeTool/Powered
	slotspec = list(\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))
	item_inputs = list(/obj/Items/LifeTool = 1)
	var/powered_kind = "Pick"

	TechItemText()
		return "1x plain [powered_kind]"

	TechItemsShort(mob/M, runs = 1)
		. = list()
		if(M && !M.PoweredToolBase(powered_kind)) . += "1x plain [powered_kind]"

	TechItemLines(mob/M)
		. = list()
		var/line = "Uses: your best plain [powered_kind] from your pack"
		if(M && !M.PoweredToolBase(powered_kind)) line += ", you have none"
		. += line

	MakeResult(mob/M, q, perf, picks)
		if(!M) return null
		var/obj/Items/LifeTool/base = M.PoweredToolBase(powered_kind)
		if(!base)
			var/made = label
			var/kind = powered_kind
			spawn(0)
				if(M) M << "<font color=#ff6464>The [made] needs a plain [kind] from your pack, and it is gone. The work falls apart and the materials are spent.</font>"
			return null
		var/obj/Items/LifeTool/Powered/P = PoweredToolFrom(base)
		del base
		if(M.client) M.client.BuildInvPage()
		return TechHandOver(M, P)

/datum/craft_recipe/lifecraft/tech/powered_tool/pick
	id = "tech_powered_pick"
	label = "Powered Pick"
	powered_kind = "Pick"

/datum/craft_recipe/lifecraft/tech/powered_tool/hammer
	id = "tech_powered_hammer"
	label = "Powered Hammer"
	powered_kind = "Hammer"

/datum/craft_recipe/lifecraft/tech/wearable/jet_boots
	id = "tech_jet_boots"
	label = "Jet Boots"
	tier = 2
	knowledge_req = "Jet Propulsion"
	result_type = /obj/Items/Gear/Jet_Boots

/datum/craft_recipe/lifecraft/tech/wearable/jet_pack
	id = "tech_jet_pack"
	label = "Jet Pack"
	tier = 2
	knowledge_req = "Jet Propulsion"
	result_type = /obj/Items/Gear/Jet_Pack
	add_slots = list(list("Cell", 1, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/wearable/power_armor
	id = "tech_power_armor"
	label = "Powered Exoskeleton"
	tier = 3
	knowledge_req = "Powered Exoskeletons"
	result_type = /obj/Items/Gear/Power_Armor
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Cell", 2, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/exo_special
	tier = 4
	knowledge_req = "Powered Armor Specialization"
	item_inputs = list(/obj/Items/Gear/Power_Armor = 1)

	MakeResult(mob/M, q, perf, picks)
		var/list/pool = M ? M.TechItemPool(/obj/Items/Gear/Power_Armor) : null
		var/obj/Items/Gear/old = (pool && pool.len) ? pool[1] : null
		var/list/parts = (old && old.integrated_parts) ? old.integrated_parts.Copy() : null
		var/list/chips = (old && old.socket_chips) ? old.socket_chips.Copy() : null
		var/list/kept = old ? old.integrated_kept : null
		if(old) old.integrated_kept = null
		. = ..()
		var/obj/Items/Gear/G = .
		if(!istype(G))
			if(old) old.integrated_kept = kept
			return
		G.integrated_parts = parts
		G.socket_chips = chips
		G.integrated_kept = kept
		for(var/k in kept)
			var/obj/Skills/S = kept[k]
			if(S) S.AssociatedGear = G

/datum/craft_recipe/lifecraft/tech/exo_special/burst
	id = "tech_power_armor_burst"
	label = "Power Armor Burst"
	result_type = /obj/Items/Gear/Power_Armor_Burst
	slotspec = list(\
		list("Servo", 2, TECH_MAT_SERVO, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/exo_special/burly
	id = "tech_power_armor_burly"
	label = "Power Armor Burly"
	result_type = /obj/Items/Gear/Power_Armor_Burly
	slotspec = list(\
		list("Servo", 2, TECH_MAT_SERVO, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Steel", 3, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/exo_special/blitz
	id = "tech_power_armor_blitz"
	label = "Power Armor Blitz"
	result_type = /obj/Items/Gear/Power_Armor_Blitz
	slotspec = list(\
		list("Servo", 2, TECH_MAT_SERVO, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Wiring", 4, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/weapon_module
	tier = 3
	knowledge_req = "Weapon Modules"
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Servo", 2, TECH_MAT_SERVO, 1),\
		list("Steel", 2, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/weapon_module/blast_fist
	id = "tech_blast_fist"
	label = "Blast Fist"
	result_type = /obj/Items/Gear/Blast_Fist

/datum/craft_recipe/lifecraft/tech/weapon_module/pile_bunker
	id = "tech_pile_bunker"
	label = "Pile Bunker"
	result_type = /obj/Items/Gear/Pile_Bunker

/datum/craft_recipe/lifecraft/tech/weapon_module/power_claw
	id = "tech_power_claw"
	label = "Power Claw"
	result_type = /obj/Items/Gear/Power_Claw

/datum/craft_recipe/lifecraft/tech/module_upgrade
	tier = 3
	knowledge_req = "Weapon Modules"
	slotspec = list(\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/module_upgrade/power_fist
	id = "tech_power_fist"
	label = "Power Fist"
	result_type = /obj/Items/Gear/Power_Fist
	item_inputs = list(/obj/Items/Gear/Blast_Fist = 1)

/datum/craft_recipe/lifecraft/tech/module_upgrade/chainsaw
	id = "tech_chainsaw"
	label = "Chainsaw"
	result_type = /obj/Items/Gear/Chainsaw
	item_inputs = list(/obj/Items/Gear/Pile_Bunker = 1)

/datum/craft_recipe/lifecraft/tech/module_upgrade/hook_grip_claw
	id = "tech_hook_grip_claw"
	label = "Hook Grip Claw"
	result_type = /obj/Items/Gear/Hook_Grip_Claw
	item_inputs = list(/obj/Items/Gear/Power_Claw = 1)

/datum/craft_recipe/lifecraft/tech/progressive_blade
	id = "tech_progressive_blade"
	label = "Progressive Blade"
	tier = 3
	knowledge_req = "Melee Weaponry"
	result_type = /obj/Items/Gear/Progressive_Blade
	slotspec = list(\
		list("Steel", 3, "mat:Steel", 1),\
		list("Servo", 1, TECH_MAT_SERVO, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/lightsaber
	id = "tech_lightsaber"
	label = "Lightsaber"
	tier = 3
	knowledge_req = "Melee Weaponry"
	result_type = /obj/Items/Gear/Lightsaber
	slotspec = list(\
		list("Casing", 1, TECH_MAT_CASING, 1),\
		list("Lens", 2, TECH_MAT_LENS, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Shards", 1, "mat:GemShards", 1))
	item_inputs = list(/obj/Items/Gear/Progressive_Blade = 1)

/datum/craft_recipe/lifecraft/tech/lightsaber/double
	id = "tech_double_lightsaber"
	label = "Double Lightsaber"
	result_type = /obj/Items/Gear/Double_Lightsaber
	item_inputs = list(/obj/Items/Gear/Lightsaber = 1)

/datum/craft_recipe/lifecraft/tech/lightsaber/great
	id = "tech_great_lightsaber"
	label = "Great Lightsaber"
	result_type = /obj/Items/Gear/Great_Lightsaber
	item_inputs = list(/obj/Items/Gear/Lightsaber = 1)

/datum/craft_recipe/lifecraft/tech/lightsaber/crossguard
	id = "tech_crossguard_lightsaber"
	label = "Crossguard Lightsaber"
	result_type = /obj/Items/Gear/Crossguard_Lightsaber
	item_inputs = list(/obj/Items/Gear/Lightsaber = 1)

/datum/craft_recipe/lifecraft/tech/lightsaber/shoto
	id = "tech_shoto_lightsaber"
	label = "Shoto Lightsaber"
	result_type = /obj/Items/Gear/Shoto_Lightsaber
	item_inputs = list(/obj/Items/Gear/Lightsaber = 1)

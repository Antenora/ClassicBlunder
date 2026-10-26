/obj/Items/MechKit
	name = "Frame Kit"
	desc = "A mech chassis tune. It goes into a mech at assembly, and a Mech Bay swaps it later."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "AdvancedKit"
	var/kit_key

	Speed
		name = "Speed Frame Kit"
		desc = "A mech chassis tune: +3 SPD, -2 VIT, -1 END."
		kit_key = "Speed"

	Tank
		name = "Tank Frame Kit"
		desc = "A mech chassis tune: +3 VIT, +2 END, -3 SPD."
		kit_key = "Tank"

	Assault
		name = "Assault Frame Kit"
		desc = "A mech chassis tune: +3 STR, +2 FOR, -2 DEF."
		kit_key = "Assault"

	Mobile_Fighter
		name = "Mobile Fighter Frame Kit"
		desc = "A mech chassis tune: +2 STR, +2 SPD, +1 OFF, -3 VIT, and mech-compatible pilot skills cost 20 percent less heat."
		kit_key = "Mobile Fighter"

proc/MechRecipePick(datum/craft_recipe/lifecraft/R, list/picks, slotname)
	if(!R || !R.slots || !islist(picks)) return null
	for(var/i = 1 to min(R.slots.len, picks.len))
		var/datum/craft_slotreq/S = R.slots[i]
		if(S.name != slotname) continue
		var/list/p = picks[i]
		return (islist(p) && p.len >= 2) ? p : null
	return null

proc/MechRecipeMetal(datum/craft_recipe/lifecraft/R, list/picks)
	var/list/p = MechRecipePick(R, picks, "Metal")
	if(!p) return null
	var/mid = lowertext("[p[1]]")
	return LIFE_METAL_TIER[mid] ? mid : null

proc/MechRecipeCoreTier(datum/craft_recipe/lifecraft/R, list/picks)
	var/list/p = MechRecipePick(R, picks, "Core")
	if(!p) return MECH_CORE_TIER_MIN
	return clamp(LifeMatTier(p[1]), MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)

mob/proc/MechKitKinds()
	. = list()
	for(var/obj/Items/MechKit/K in TechItemPool(/obj/Items/MechKit))
		if(K.kit_key && !(K.kit_key in .)) . += K.kit_key

mob/proc/MechKitTake(kind)
	var/list/pool = TechItemPool(/obj/Items/MechKit)
	if(kind)
		for(var/obj/Items/MechKit/K in pool)
			if(K.kit_key == kind) return K
	return pool.len ? pool[1] : null

/datum/craft_recipe/lifecraft/tech/wearable/mech
	station = "mechbay"
	result_type = /obj/Items/Mech
	drop_slots = list("Casing", "Servo", "Metal", "Cell")
	item_inputs = list(/obj/Items/MechKit = 1)
	var/model_key

	New()
		var/list/row = MechModelRow(model_key)
		var/cls = row ? row["class"] : "Medium"
		tier = MechModelTier(model_key)
		knowledge_req = (tier == MECH_TIER_LIGHT) ? "Mech Fabrication" : "Vehicular Power Armor"
		add_slots = list(\
			list("Metal", row ? row["plating_n"] : MECH_PLATING_MEDIUM, TECH_SEL_INGOT, 1),\
			list("Core", MECH_CORE_COUNT, TECH_SEL_CORE, 1),\
			list("Servo", MechClassRecipeCount(cls, "Servo"), TECH_MAT_SERVO, 1),\
			list("Cell", MechClassRecipeCount(cls, "Cell"), TECH_MAT_CELL, 1),\
			list("Casing", MechClassRecipeCount(cls, "Casing"), TECH_MAT_CASING, 1),\
			list("Wiring", MechClassRecipeCount(cls, "Wiring"), TECH_MAT_WIRING, 1))
		..()

	TechItemText()
		return "1x any Frame Kit"

	Missing(mob/M, list/picks)
		. = ..()
		if(!M) return
		var/obj/Items/Mech/out = MechDeployedFor(M.ckey)
		if(out) . += "[out.name] is still deployed, capsule it first"

	StageList(mob/M)
		if(M)
			M.mech_kit_kind = null
			var/list/kinds = M.MechKitKinds()
			if(kinds.len == 1)
				M.mech_kit_kind = kinds[1]
			else if(kinds.len > 1)
				M.mech_kit_kind = Ask(M, "Which Frame kit goes into the [label]?", "FRAME KIT", null, "pick", kinds, 0)
		return ..()

	MakeResult(mob/M, q, perf, list/picks)
		if(!M) return null
		var/obj/Items/MechKit/K = M.MechKitTake(M.mech_kit_kind)
		M.mech_kit_kind = null
		if(!K)
			var/made = label
			spawn(0)
				if(M) M << "<font color=#ff6464>The [made] needs a Frame kit from your pack, and it is gone. The work falls apart and the materials are spent.</font>"
			return null
		var/kit = K.kit_key
		del K
		if(M.client) M.client.BuildInvPage()
		var/obj/Items/Mech/R = TechMakeOutput(M, /obj/Items/Mech, 1, QualityClamp(q))
		if(!istype(R)) return R
		R.model = model_key
		R.metal_id = MechRecipeMetal(src, picks)
		//allows for intrinsic core like Spiral Drive
		var/list/core_pick = MechRecipePick(src, picks, "Core")
		var/intrinsic_id = core_pick ? MechCraftIntrinsicID(core_pick[1]) : null
		if(intrinsic_id)
			if(!M.MechCraftAttachCore(R, intrinsic_id))
				del R
				return null
		else
			R.core_tier = MechRecipeCoreTier(src, picks)

		R.coating = null
		R.frame_kit = kit
		R.builder = M.ckey
		R.pilots = list(M.ckey)
		R.fuel = MECH_FUEL_START
		R.disabled = 0
		if(intrinsic_id)
			var/datum/mech_intrinsic_part/P = MechIntrinsicParts[intrinsic_id]
			var/list/I = R.intrinsic_installed["Reactor"]

			try
				P.OnInstall(M, R, I["state"])
			catch(var/exception/E)
				world.log << "Assembly intrinsic [intrinsic_id] OnInstall failed: [E]"
		R.Hull = R.MechHullMax()
		MechDeployedSet(M, R)
		R.MechPlaced(1)
		return R

/datum/craft_recipe/lifecraft/tech/wearable/mech/vanguard
	id = "tech_mech_vanguard"
	label = "Vanguard"
	model_key = "MechA"

/datum/craft_recipe/lifecraft/tech/wearable/mech/duelist
	id = "tech_mech_duelist"
	label = "Duelist"
	model_key = "MechB"

/datum/craft_recipe/lifecraft/tech/wearable/mech/seraph
	id = "tech_mech_seraph"
	label = "Seraph"
	model_key = "MechC"

/datum/craft_recipe/lifecraft/tech/wearable/mech/sentinel
	id = "tech_mech_sentinel"
	label = "Sentinel"
	model_key = "MechD"

/datum/craft_recipe/lifecraft/tech/wearable/mech/paladin
	id = "tech_mech_paladin"
	label = "Paladin"
	model_key = "TV_Robot01"

/datum/craft_recipe/lifecraft/tech/wearable/mech/musha
	id = "tech_mech_musha"
	label = "Musha"
	model_key = "TV_Robot02"

/datum/craft_recipe/lifecraft/tech/wearable/mech/bastion
	id = "tech_mech_bastion"
	label = "Bastion"
	model_key = "TV_Robot03"

/datum/craft_recipe/lifecraft/tech/wearable/mech/typhon
	id = "tech_mech_typhon"
	label = "Typhon"
	model_key = "TV_Robot04"

/datum/craft_recipe/lifecraft/tech/wearable/mech/juggernaut
	id = "tech_mech_juggernaut"
	label = "Juggernaut"
	model_key = "TV_Robot05"

/datum/craft_recipe/lifecraft/tech/wearable/mech/shark
	id = "tech_mech_shark"
	label = "Shark"
	model_key = "TV_Robot08"

/datum/craft_recipe/lifecraft/tech/wearable/mech/fighter
	id = "tech_mech_fighter"
	label = "Fighter"
	model_key = "TV_Robot09"

/datum/craft_recipe/lifecraft/tech/wearable/mech/cross
	id = "tech_mech_cross"
	label = "Cross"
	model_key = "TV_Robot10_01"

/datum/craft_recipe/lifecraft/tech/wearable/mech/lancer
	id = "tech_mech_lancer"
	label = "Lancer"
	model_key = "TV_Robot10_02"

/datum/craft_recipe/lifecraft/tech/wearable/mech/strider
	id = "tech_mech_strider"
	label = "Strider"
	model_key = "TV_Robot06"

/datum/craft_recipe/lifecraft/tech/wearable/mech/overseer
	id = "tech_mech_overseer"
	label = "Overseer"
	model_key = "TV_Robot07"

/datum/craft_recipe/lifecraft/tech/handheld/mech_kit
	tier = MECH_TIER_LIGHT
	knowledge_req = "Mech Fabrication"
	drop_slots = list("Casing", "Wiring", "Board", "Optic")
	add_slots = list(\
		list("Casing", MECH_KIT_CASING, TECH_MAT_CASING, 1),\
		list("Servo", MECH_KIT_SERVO, TECH_MAT_SERVO, 1),\
		list("Wiring", MECH_KIT_WIRING, TECH_MAT_WIRING, 1))

/datum/craft_recipe/lifecraft/tech/handheld/mech_kit/speed
	id = "tech_mech_kit_speed"
	label = "Speed Frame Kit"
	result_type = /obj/Items/MechKit/Speed

/datum/craft_recipe/lifecraft/tech/handheld/mech_kit/tank
	id = "tech_mech_kit_tank"
	label = "Tank Frame Kit"
	result_type = /obj/Items/MechKit/Tank

/datum/craft_recipe/lifecraft/tech/handheld/mech_kit/assault
	id = "tech_mech_kit_assault"
	label = "Assault Frame Kit"
	result_type = /obj/Items/MechKit/Assault

/datum/craft_recipe/lifecraft/tech/handheld/mech_kit/mobile_fighter
	id = "tech_mech_kit_mobile_fighter"
	label = "Mobile Fighter Frame Kit"
	result_type = /obj/Items/MechKit/Mobile_Fighter

/datum/craft_recipe/lifecraft/tech/placed/mech_bay
	id = "tech_mech_bay"
	label = "Mech Bay"
	tier = MECH_TIER_LIGHT
	knowledge_req = "Mech Fabrication"
	result_type = /obj/LifeSkills/Station/MechBay
	metal_n = MECH_BAY_METAL
	drop_slots = list("Casing", "Board", "Cell")
	add_slots = list(\
		list("Casing", MECH_BAY_CASING, TECH_MAT_CASING, 1),\
		list("Servo", MECH_BAY_SERVO, TECH_MAT_SERVO, 1),\
		list("Board", MECH_BAY_BOARD, TECH_MAT_BOARD, 1))

	MakeResult(mob/M, q, perf, list/picks)
		if(!M || !isturf(M.loc)) return null
		var/obj/LifeSkills/Station/MechBay/B = new(M.loc)
		spawn(0)
			if(M) M << "The Mech Bay stands where you worked. Only an admin can move it."
		return B

/datum/craft_recipe/lifecraft/tech/handheld/mech_capsule
	id = "tech_mech_capsule"
	label = "Capsule"
	tier = MECH_TIER_LIGHT
	knowledge_req = "Mech Fabrication"
	result_type = /obj/Items/Capsule
	drop_slots = list("Casing", "Wiring", "Board", "Optic")
	add_slots = list(\
		list("Casing", MECH_CAPSULE_CASING, TECH_MAT_CASING, 1),\
		list("Board", MECH_CAPSULE_BOARD, TECH_MAT_BOARD, 1),\
		list("Lens", MECH_CAPSULE_LENS, TECH_MAT_LENS, 1))

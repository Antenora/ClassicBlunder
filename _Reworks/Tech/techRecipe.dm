// QUAL_* tier defines live in _1CodeFolder\__Defines.dm so early files can see them

var/list/QUALITY_NAMES  = list("Poor", "Normal", "Good", "Epic", "Legendary")
var/list/QUALITY_COLORS = list("#9aa3b2", "#dfe7f0", "#5bd75b", "#b46bff", "#ffb020")

/proc/QualityClamp(q)
	return clamp(round(q), QUAL_POOR, QUAL_LEGENDARY)

/proc/QualityName(q)
	return QUALITY_NAMES[QualityClamp(q)]

/proc/QualityColor(q)
	return QUALITY_COLORS[QualityClamp(q)]

/obj/Items/var/CraftQuality = QUAL_NORMAL

/obj/Items/Material
	var/MaterialClass = "Scrap"   // "Iron", "Gold", "Wood"...
	// reuses /obj/Items/CraftQuality as the material's own quality
	Stackable = 1

// materials live in the Collection Log now
/proc/CountMaterial(mob/m, material_class, min_quality = QUAL_POOR)
	return m ? m.MatLogCount(material_class, min_quality) : 0

/proc/ConsumeMaterial(mob/m, material_class, amount, min_quality = QUAL_POOR)
	if(!m || amount <= 0) return
	for(var/q = QualityClamp(min_quality) to QUAL_LEGENDARY)   // spend the lowest eligible quality first
		if(amount <= 0) break
		amount -= m.MatLogTakeQ(material_class, q, amount)

// a fixed material requirement
/datum/craft_ingredient
	var/material_class = "Iron"
	var/amount = 1
	var/min_quality = QUAL_POOR

// a choice slot
/datum/craft_slot
	var/name = "Material"
	var/list/options = list()   // accepted material classes
	var/amount = 1
	proc/ApplyEffect(obj/Items/result, chosen_class)
		return // override per concrete recipe

// the recipe itself
/datum/craft_recipe
	var/result_type                 // typepath produced (informational; craft uses the catalog item's type)
	var/money_override = -1         // -1 => derive from catalog.Cost * EconomyCost
	var/list/material_reqs = list() // list(/datum/craft_ingredient)
	var/list/material_slots = list()// list(/datum/craft_slot)
	var/base_quality = QUAL_NORMAL

	proc/MoneyCost(mob/m, obj/Items/catalog)
		if(money_override >= 0)
			return round(money_override * glob.progress.EconomyCost)
		return Technology_Price(m, catalog)   // legacy money formula, untouched

	// a one-line summary for the craft UI later
	proc/MaterialSummary(mob/m)
		if(!material_reqs.len && !material_slots.len) return ""
		var/list/parts = list()
		for(var/datum/craft_ingredient/ing in material_reqs)
			parts += "[ing.amount]x [ing.material_class]"
		for(var/datum/craft_slot/s in material_slots)
			parts += "[s.amount]x [jointext(s.options, "/")]"
		return jointext(parts, ", ")

	proc/HasMaterials(mob/m, list/chosen)
		for(var/datum/craft_ingredient/ing in material_reqs)
			if(CountMaterial(m, ing.material_class, ing.min_quality) < ing.amount)
				return 0
		return 1   // slot satisfaction is validated against `chosen` by the caller later

	proc/CanCraft(mob/m, obj/Items/catalog, list/chosen)
		if(!Can_Afford_Technology(m, catalog) && money_override < 0)
			return 0
		if(money_override >= 0)
			var/cost = MoneyCost(m, catalog)
			var/have = 0
			for(var/obj/Money/mo in m) have += mo.Level
			if(have < cost) return 0
		return HasMaterials(m, chosen)

	proc/OutputQuality(list/chosen)
		if(!chosen || !chosen.len) return base_quality
		var/sum = 0, n = 0
		for(var/obj/Items/Material/mat in chosen)
			sum += mat.CraftQuality ; n++
		return n ? QualityClamp(sum / n) : base_quality

	// spend money (+ materials, later)
	proc/Consume(mob/m, obj/Items/catalog, list/chosen)
		if(!CanCraft(m, catalog, chosen)) return 0
		m.TakeMoney(MoneyCost(m, catalog))
		for(var/datum/craft_ingredient/ing in material_reqs)
			ConsumeMaterial(m, ing.material_class, ing.amount, ing.min_quality)
		return 1

	// stamp quality + run any chosen-slot effects on a freshly made item
	proc/Finish(obj/Items/result, list/chosen)
		if(!result) return
		result.CraftQuality = OutputQuality(chosen)
		// future: for(slot in material_slots) slot.ApplyEffect(result, chosen[slot])

var/list/TechRecipeRegistry = list()

/proc/RegisterTechRecipe(item_type, datum/craft_recipe/r)
	TechRecipeRegistry[item_type] = r

/proc/GetTechRecipe(obj/Items/catalog)
	if(!catalog) return null
	var/datum/craft_recipe/r = TechRecipeRegistry[catalog.type]
	if(r) return r
	r = new /datum/craft_recipe   // default: money-only, cost tracks catalog.Cost
	r.result_type = catalog.type
	return r

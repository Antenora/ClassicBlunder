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

// the recipe itself
/datum/craft_recipe
	var/result_type                 // typepath produced (informational; craft uses the catalog item's type)

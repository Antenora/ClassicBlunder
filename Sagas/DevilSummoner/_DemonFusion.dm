/proc/InitFusionData()
	// 0=Omega, 1=Megami, 2=Deity, 3=Vile, 4=Snake, 5=Dragon,
	// 6=Divine, 7=Avian, 8=Fallen, 9=Avatar, 10=Beast, 11=Wilder,
	// 12=Genma, 13=Fairy, 14=Tyrant, 15=Kishin, 16=Touki, 17=Jaki,
	// 18=Femme, 19=Ghost, 20=Fiend, 21=Hero

	var/list/tbl = list(
		list("Flaemis"),
		list("Vile",   "Aquans"),
		list("Tyrant", "Kishin", "Flaemis"),
		list("Dragon", "Omega",  "Tyrant", "Aeros"),
		list("Kishin", "Fairy",  "Omega",  "Deity",  "Aquans"),
		list("Touki",  "Jaki",   "Vile",   "Tyrant", "Wilder", "Flaemis"),
		list("Deity",  "Avatar", "Megami", "Avian",  "Megami", "Fallen", "Aeros"),
		list("Kishin", "Divine", "Femme",  "Jaki",   "Vile",   "Femme",  "Snake",  "Aeros"),
		list("Vile",   "Femme",  "Kishin", "Avian",  "Megami", "Beast",  "Tyrant", "Megami", "Erthys"),
		list("Wilder", "Snake",  "Jaki",   "Tyrant", "Deity",  "Ghost",  "Megami", "Divine", "Touki",  "Aquans"),
		list("Avatar", "Genma",  "Avian",  "Dragon", "Avatar", "Jaki",   "Avatar", "Genma",  "Femme",  "Divine", "Flaemis"),
		list("Fallen", "Fairy",  "Touki",  "Fallen", "Touki",  "Genma",  "Avatar", "Snake",  "Dragon", "Jaki",   "Ghost",  "Erthys"),
		list("Megami", "Beast",  "Wilder", "Kishin", "Deity",  "Fallen", "Dragon", "Divine", "Tyrant", "Snake",  "Jaki",   "Vile",   "Aeros"),
		list("Ghost",  "Wilder", "Snake",  "Touki",  "Beast",  "Fallen", "Avatar", "Snake",  "Divine", "Megami", "Femme",  "Avian",  "Beast",  "Aeros"),
		list("Deity",  "Omega",  "Vile",   "Deity",  "Dragon", "Ghost",  "Deity",  "Avatar", "Omega",  "Fallen", "Dragon", "Jaki",   "Vile",   "Wilder", "Erthys"),
		list("Megami", "Touki",  "Fairy",  "Jaki",   "Divine", "Genma",  "Femme",  "Deity",  "Jaki",   "Deity",  "Avian",  "Ghost",  "Snake",  "Vile",   "Fallen", "Aquans"),
		list("Femme",  "Avian",  "Kishin", "Genma",  "Kishin", "Wilder", "Beast",  "Beast",  "Avian",  "Kishin", "Fairy",  "Snake",  "Avatar", "Beast",  "Snake",  "Omega",  "Flaemis"),
		list("Kishin", "Femme",  "Tyrant", "Genma",  "Divine", "Avian",  "Kishin", "Avatar", "Beast",  "Fairy",  "Touki",  "Dragon", "Avian",  "Ghost",  "Femme",  "Genma",  "Wilder", "Erthys"),
		list("Megami", "Divine", "Dragon", "Tyrant", "Fallen", "Ghost",  "Megami", "Divine", "Dragon", "Genma",  "Fairy",  "Avatar", "Touki",  "Fallen", "Wilder", "Genma",  "Fairy",  "Beast",  "Aquans"),
		list("Touki",  "Vile",   "Fairy",  "Deity",  "Dragon", "Wilder", "Avian",  "Beast",  "Fairy",  "Snake",  "Wilder", "Touki",  "Divine", "Jaki",   "Femme",  "Vile",   "Genma",  "Fallen", "Fairy",  "Erthys"),
		list("Vile",   "Omega",  "Tyrant", "Kishin", "Megami", "Snake",  "Vile",   "Megami", "Genma",  "Vile",   "Snake",  "Dragon", "Deity",  "Femme",  "Omega",  "Vile",   "Kishin", "Genma",  "Megami", "Fairy",  "Aquans"),
		list("Megami", "Tyrant", "Kishin", "Omega",  "Deity",  "Divine", "Megami", "Divine", "Tyrant", "Deity",  "Snake",  "Avatar", "Deity",  "Genma",  "Snake",  "Omega",  "Kishin", "Genma",  "Megami", "Femme",  "Ghost",  "Flaemis")
	)
	DEMON_FUSION_CHART = tbl

	// Special fusions
	DEMON_SPECIAL_FUSIONS = list(
		"Alice"        = list("Belial", "Nebiros"),
		"Billiken"     = list("Mothman", "Silky"),
		"Ghost Q"      = list("Ogun", "Jack Frost"),
		"Guan Yu"      = list("Nata Taishi", "Murmur"),
		"Hagen"        = list("Berserker", "Ictinike"),
		"Jeanne D'Arc" = list("Hecate", "Scathach"),
		"Lucifer"      = list("Metatron", "Loki"),
		"Masakado"     = list("Amaterasu", "Yoshitsune"),
		"Neko Shogun"  = list("Nekomata", "Thor"),
		"Sage of Time" = list("Odin", "Orthrus"),
		"Shiva"        = list("Rangda", "Barong"),
		"Trumpeter"    = list("Tzitzimitl", "Remiel"),
		"Yoshitsune"   = list("Osiris", "Take-Mikazuchi")
	)

/proc/GetRaceIndex(race)
	var/list/DEMON_RACES = list("Omega","Megami","Deity","Vile","Snake","Dragon","Divine","Avian","Fallen","Avatar","Beast","Wilder","Genma","Fairy","Tyrant","Kishin","Touki","Jaki","Femme","Ghost","Fiend","Hero")
	var/rlen = length(DEMON_RACES)
	for(var/i = 1, i <= rlen, i++)
		if(DEMON_RACES[i] == race)
			return i - 1  // 0-based
	return -1

// Element races
#define DEMON_ELEMENT_RACES list("Erthys","Aeros","Aquans","Flaemis")

/proc/GetFusionResult(name_a, name_b)
	if(!name_a || !name_b || name_a == name_b)
		return ""

	for(var/result in DEMON_SPECIAL_FUSIONS)
		var/list/ingredients = DEMON_SPECIAL_FUSIONS[result]
		if((name_a in ingredients) && (name_b in ingredients))
			return result

	var/datum/demon_data/da = DEMON_DB[name_a]
	var/datum/demon_data/db = DEMON_DB[name_b]
	if(!da || !db) return ""

	var/race_a = da.demon_race
	var/race_b = db.demon_race
	var/lvl_a  = da.demon_lvl
	var/lvl_b  = db.demon_lvl

	var/i = GetRaceIndex(race_a)
	var/j = GetRaceIndex(race_b)
	if(i < 0 || j < 0) return ""

	var/hi = max(i, j)
	var/lo = min(i, j)
	var/result_race = DEMON_FUSION_CHART[hi + 1][lo + 1]

	// requires Tier 6+
	if(result_race in DEMON_ELEMENT_RACES)
		return "_ELEMENT_[result_race]_[race_a]_[race_b]"

	var/target_lvl = floor((lvl_a + lvl_b) / 2) + 1

	return FindDemonInRace(result_race, target_lvl)

/proc/GetFusionResultByLevel(name_a, lvl_a, name_b, lvl_b)
	if(!name_a || !name_b || name_a == name_b) return ""

	for(var/result in DEMON_SPECIAL_FUSIONS)
		var/list/ingredients = DEMON_SPECIAL_FUSIONS[result]
		if((name_a in ingredients) && (name_b in ingredients))
			return result

	var/datum/demon_data/da = DEMON_DB[name_a]
	var/datum/demon_data/db = DEMON_DB[name_b]
	if(!da || !db) return ""

	var/i = GetRaceIndex(da.demon_race)
	var/j = GetRaceIndex(db.demon_race)
	if(i < 0 || j < 0) return ""

	var/hi = max(i, j)
	var/lo = min(i, j)
	var/result_race = DEMON_FUSION_CHART[hi + 1][lo + 1]

	if(result_race in DEMON_ELEMENT_RACES)
		return "_ELEMENT_[result_race]_[da.demon_race]_[db.demon_race]"

	var/target_lvl = floor((lvl_a + lvl_b) / 2) + 1
	return FindDemonInRace(result_race, target_lvl)

/proc/FindDemonInRace(result_race, target_lvl)
	var/list/candidates = list()
	for(var/dname in DEMON_DB)
		var/datum/demon_data/d = DEMON_DB[dname]
		if(d.demon_race == result_race)
			candidates[dname] = d.demon_lvl

	if(!candidates.len) return ""

	var/best_name = ""
	var/best_lvl  = 9999
	var/fallback_name = ""
	var/fallback_lvl  = 0

	for(var/dname in candidates)
		var/lvl = candidates[dname]
		// Track highest as fallback
		if(lvl > fallback_lvl)
			fallback_lvl = lvl
			fallback_name = dname
		// Track lowest at-or-above target
		if(lvl >= target_lvl && lvl < best_lvl)
			best_lvl = lvl
			best_name = dname

	return best_name ? best_name : fallback_name

// elemental fusion: rank up/down within same race

/proc/GetElementFusionResult(element_race, demon_name, shift_up)
	var/datum/demon_data/d = DEMON_DB[demon_name]
	if(!d) return ""
	var/target_race = d.demon_race

	var/list/same_race = list()
	for(var/dname in DEMON_DB)
		var/datum/demon_data/dd = DEMON_DB[dname]
		if(dd.demon_race == target_race)
			same_race[dname] = dd.demon_lvl

	if(same_race.len < 2) return ""

	var/list/sorted_names = list()
	for(var/dname in same_race)
		sorted_names += dname
	var/slen = length(sorted_names)
	for(var/a = 1, a <= slen, a++)
		for(var/b = a+1, b <= slen, b++)
			if(same_race[sorted_names[a]] > same_race[sorted_names[b]])
				var/tmp = sorted_names[a]
				sorted_names[a] = sorted_names[b]
				sorted_names[b] = tmp

	var/pos = sorted_names.Find(demon_name)
	if(!pos) return ""

	var/new_pos = shift_up ? pos + 1 : pos - 1
	if(new_pos < 1 || new_pos > sorted_names.len) return ""
	return sorted_names[new_pos]

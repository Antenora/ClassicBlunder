// Collection Log, materials live here, not in the inventory grid.
/datum/collectionlog
	var/list/have = list()      // have[matclass] = list(q1,q2,q3,q4,q5) current counts
	var/list/lifetime = list()  // lifetime[matclass] = total ever gathered (uncapped)
	var/list/best = list()      // best[matclass] = highest quality ever obtained

mob/var/datum/collectionlog/matlog

mob/proc/InitMatLog()
	if(!matlog) matlog = new

mob/proc/MatLogAdd(matclass, quality, amount)
	if(!matclass || amount <= 0) return 0
	InitMatLog()
	quality = QualityClamp(quality)
	if(!matlog.have[matclass]) matlog.have[matclass] = list(0, 0, 0, 0, 0)
	var/list/buckets = matlog.have[matclass]
	var/room = INV_STACK_MAX - buckets[quality]
	var/banked = min(amount, max(0, room))
	buckets[quality] += banked
	matlog.lifetime[matclass] = (matlog.lifetime[matclass] ? matlog.lifetime[matclass] : 0) + amount
	if(!matlog.best[matclass] || quality > matlog.best[matclass]) matlog.best[matclass] = quality
	return banked

// total current holdings at or above min_quality
mob/proc/MatLogCount(matclass, min_quality = QUAL_POOR)
	InitMatLog()
	var/list/buckets = matlog.have[matclass]
	if(!buckets) return 0
	. = 0
	for(var/q = QualityClamp(min_quality) to QUAL_LEGENDARY)
		. += buckets[q]

mob/proc/MatLogCountQ(matclass, quality)
	InitMatLog()
	var/list/buckets = matlog.have[matclass]
	if(!buckets) return 0
	return buckets[QualityClamp(quality)]

// pull up to n from one quality bucket. returns the amount removed.
mob/proc/MatLogTakeQ(matclass, quality, n)
	if(n <= 0) return 0
	InitMatLog()
	var/list/buckets = matlog.have[matclass]
	if(!buckets) return 0
	quality = QualityClamp(quality)
	var/take = min(n, buckets[quality])
	buckets[quality] -= take
	return take

mob/proc/MatLogLifetime(matclass)
	InitMatLog()
	return matlog.lifetime[matclass] ? matlog.lifetime[matclass] : 0

mob/proc/MatLogBest(matclass)
	InitMatLog()
	return matlog.best[matclass] ? matlog.best[matclass] : 0

var/list/LifeMatRegistry = list()       // matclass -> /datum/matdef, in display order
var/list/LifeMatClassByType = list()    // material type path -> matclass
var/list/LifeMatCategories = list("Ores", "Ingots", "Gems", "Fuel", "Monster Parts", "Flora", "Wood", "Fruit", "Fish", "Other")

/datum/matdef
	var/matclass
	var/name
	var/icon
	var/icon_state
	var/mtype           // the /obj/Items/Material subtype
	var/category

proc/LifeMatReg(mtype, category)
	var/obj/Items/Material/m = new mtype
	if(!m.MaterialClass || m.MaterialClass == "Scrap")
		del m
		return
	var/datum/matdef/d = new
	d.matclass = m.MaterialClass
	d.name = m.name
	d.icon = m.icon
	d.icon_state = m.icon_state
	d.mtype = mtype
	d.category = category
	LifeMatRegistry[d.matclass] = d
	LifeMatClassByType[mtype] = d.matclass
	del m

proc/RegisterLifeMaterials()
	if(LifeMatRegistry.len) return
	for(var/T in typesof(/obj/Items/Material/Ore) - /obj/Items/Material/Ore)
		LifeMatReg(T, "Ores")
	for(var/T in typesof(/obj/Items/Material/Ingot) - /obj/Items/Material/Ingot)
		LifeMatReg(T, "Ingots")
	for(var/T in typesof(/obj/Items/Material/Gem) - /obj/Items/Material/Gem)
		LifeMatReg(T, "Gems")
	LifeMatReg(/obj/Items/Material/coal, "Fuel")
	LifeMatReg(/obj/Items/Material/clay, "Other")
	LifeMatReg(/obj/Items/Material/stone, "Other")
	// Hunting adds leaf MonsterPart subtypes later
	for(var/T in typesof(/obj/Items/Material/MonsterPart) - /obj/Items/Material/MonsterPart)
		LifeMatReg(T, "Monster Parts")
	for(var/T in typesof(/obj/Items/Material/Flora) - /obj/Items/Material/Flora)
		LifeMatReg(T, "Flora")
	for(var/T in typesof(/obj/Items/Material/Wood) - /obj/Items/Material/Wood)
		LifeMatReg(T, "Wood")
	for(var/T in typesof(/obj/Items/Material/Fruit) - /obj/Items/Material/Fruit)
		LifeMatReg(T, "Fruit")
	for(var/T in typesof(/obj/Items/Material/Fish) - /obj/Items/Material/Fish)
		LifeMatReg(T, "Fish")

proc/LifeMatDef(matclass)
	RegisterLifeMaterials()
	return LifeMatRegistry[matclass]

proc/LifeMatClassOf(mtype)
	RegisterLifeMaterials()
	return LifeMatClassByType[mtype]

proc/LifeMatName(matclass)
	var/datum/matdef/d = LifeMatDef(matclass)
	return d ? d.name : matclass

// list of matclasses in one category, display order
proc/LifeMatsInCategory(category)
	RegisterLifeMaterials()
	. = list()
	for(var/mc in LifeMatRegistry)
		var/datum/matdef/d = LifeMatRegistry[mc]
		if(d.category == category) . += mc

mob/proc/MigrateMaterialsToLog()
	RegisterLifeMaterials()
	for(var/obj/Items/Material/m in src)
		if(!m.MaterialClass || m.MaterialClass == "Scrap") continue
		MatLogAdd(m.MaterialClass, m.CraftQuality, m.TotalStack)
		del m
	if(client) client.BuildInvPage()

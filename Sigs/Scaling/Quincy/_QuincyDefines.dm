#define QUINCY_LEVEL_MAX 7
#define QUINCY_PFEIL_MANA 1
#define QUINCY_GLOVE_MASTERY 10800
#define QUINCY_HOLLOW_MOD 0.15
#define QUINCY_SML3_POT 35
#define QUINCY_CALM_TIME 30
#define QUINCY_SENSE_RANGE 20

mob
	var
		QuincyLevel = 0
		QuincyWeapon
		QuincyWeaponClass
		QuincyGloveMastery = 0
		QuincyGloveBroken = 0
		QuincyHeritage
		QuincySchrift
		QuincyRank
		QuincyAdminPermission = 0
		QuincyVollstandigBlockedUntil = 0
		GintoTubes = 0
		GintoRefillStamp = 0
		tmp
			QuincyLetztActive = 0
			obj/Items/Gun/QuincyWeaponItem
			HaloBroken = 0
			QuincyConvergenceOn = 0

globalTracker
	var
		list/QuincyKaiser = list()
		list/SchriftHolders = list()
		QuincyAuswahlenAt = 0

/mob/proc/QuincyIsQuincy()
	return src.QuincyLevel > 0

/proc/QuincyReishiRich(turf/T)
	if(!T)
		return 0
	var/atom/A = T
	while(A && !isarea(A))
		A = A.loc
	if(!A)
		return 0
	var/n = "[A.name]"
	if(findtext(n, "Hueco") || findtext(n, "Seireitei") || findtext(n, "Soul Society"))
		return 1
	return 0

/proc/QuincyWeaponClasses(weapon)
	switch(weapon)
		if("Bow")
			return list("Short", "Recurve", "Long")
		if("Gun")
			return list("Pistol", "Repeater")
		if("Sword")
			return list("Saber", "Longsword", "Claws")
	return list()

/proc/QuincyDirName(d)
	switch(d)
		if(NORTH)
			return "north"
		if(SOUTH)
			return "south"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
		if(NORTHEAST)
			return "northeast"
		if(NORTHWEST)
			return "northwest"
		if(SOUTHEAST)
			return "southeast"
		if(SOUTHWEST)
			return "southwest"
	return "near"

/proc/QuincySkillTable()
	return list(\
		list("/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon", 1, null, null),\
		list("/obj/Skills/Projectile/Quincy/Heilig_Pfeil_Blade", 1, "Sword", null),\
		list("/obj/Skills/Quincy/Hollow_Sense", 1, null, null),\
		list("/obj/Skills/Hoho/Hirenkyaku", 2, null, null),\
		list("/obj/Skills/Ginto/Heizen", 2, null, null),\
		list("/obj/Skills/Ginto/Wolke", 2, null, null),\
		list("/obj/Skills/Projectile/Quincy/Seele_Schneider", 2, null, null),\
		list("/obj/Skills/Ginto/Gritz", 3, null, null),\
		list("/obj/Skills/Projectile/Quincy/Licht_Regen", 3, "Bow", null),\
		list("/obj/Skills/Projectile/Quincy/Klavier", 3, "Gun", null),\
		list("/obj/Skills/Queue/Quincy/Schneider_Dance", 3, "Sword", null),\
		list("/obj/Skills/Buffs/SlotlessBuffs/Sanrei_Glove", 3, null, null),\
		list("/obj/Skills/Buffs/SlotlessBuffs/Letzt_Stil", 4, null, null),\
		list("/obj/Skills/Quincy/Ransotengai", 5, null, null),\
		list("/obj/Skills/Buffs/SlotlessBuffs/Blut", 5, null, "Echt"),\
		list("/obj/Skills/Ginto/Sprenger", 5, null, "Gemischt"))

/proc/QuincyManagedSkillTypes()
	var/list/out = list()
	for(var/list/row in QuincySkillTable())
		var/p = text2path(row[1])
		if(!ispath(p, /obj/Skills))
			continue
		out[p] = row
	return out

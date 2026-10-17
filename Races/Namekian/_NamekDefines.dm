#ifndef NAMEKIAN
#define NAMEKIAN /race/namekian
#endif

#define NAMEK_CLAN_WARRIOR "Warrior"
#define NAMEK_CLAN_DRAGON "Dragon"
#define NAMEK_CLAN_DEMON "Demon"

#define NAMEK_PATH_DARK_WARRIOR "Dark Warrior"
#define NAMEK_PATH_SHADOW_KNIGHT "Shadow Knight"
#define NAMEK_PATH_DENDE_PRIEST "Dende Priest"
#define NAMEK_PATH_POKO_PRIEST "Poko Priest"
#define NAMEK_PATH_DEMON_KING "Demon King"
#define NAMEK_PATH_CONQUEROR "Conqueror"

#define NAMEK_STATS_WARRIOR list(1.25, 1.25, 0.75, 1, 1, 0.75)
#define NAMEK_STATS_DRAGON list(0.5, 1, 1.5, 0.75, 1, 1.25)
#define NAMEK_STATS_DEMON list(1, 0.75, 1.25, 1.25, 0.75, 1)

#define NAMEK_ASC1_WARRIOR list(0.2, 0.2, 0, 0.2, 0, 0)
#define NAMEK_ASC1_DRAGON list(0, 0.15, 0.3, 0, 0, 0.15)
#define NAMEK_ASC1_DEMON list(0.2, 0, 0.2, 0.2, 0, 0)
#define NAMEK_ASC2_WARRIOR list(0.25, 0.25, 0.1, 0.2, 0.2, 0)
#define NAMEK_ASC2_DRAGON list(0, 0.2, 0.35, 0, 0.2, 0.25)
#define NAMEK_ASC2_DEMON list(0.25, 0, 0.3, 0.25, 0, 0.2)
#define NAMEK_ASC3_WARRIOR list(0.4, 0.4, 0.2, 0.2, 0, 0)
#define NAMEK_ASC3_DRAGON list(0, 0.3, 0.5, 0, 0.2, 0.2)
#define NAMEK_ASC3_DEMON list(0.4, 0, 0.4, 0.2, 0, 0.2)
#define NAMEK_ASC_ANGER 0.25

#define NAMEK_POKO_SHARE 0.65
#define NAMEK_FORM_POTENTIAL 25

#define NAMEK_RECONSTITUTE_COOLDOWN 3000
#define NAMEK_RECONSTITUTE_ENERGY_PCT 20
#define NAMEK_RECONSTITUTE_HEALTH_PCT 5

#define NAMEK_SOUND_MULT 1.5
#define NAMEK_SOUND_GIANT_MULT 3

#define NAMEK_FEAR_MOVE_DELAY 4

#define NAMEK_FUSION_STEPS list(0.20, 0.15, 0.10)

/globalTracker/var/NamekFusionCap = 3

/proc/NamekLadderBody(potential)
	if(potential >= 90)
		return 3.19
	if(potential >= 80)
		return 2.03
	if(potential >= 65)
		return 0.80
	if(potential >= 55)
		return 0.40
	if(potential >= 25)
		return 0.15
	return 0

/proc/NamekLadderForm(potential)
	if(potential >= 90)
		return 1.37
	if(potential >= 80)
		return 0.87
	if(potential >= 65)
		return 0.35
	if(potential >= 55)
		return 0.25
	if(potential >= 25)
		return 0.15
	return 0

/proc/NamekShare(mob/m)
	if(!m)
		return 0
	if(m.NamekPath == NAMEK_PATH_POKO_PRIEST)
		return NAMEK_POKO_SHARE
	return 1

/proc/NamekClanStats(clan)
	switch(clan)
		if(NAMEK_CLAN_WARRIOR)
			return NAMEK_STATS_WARRIOR
		if(NAMEK_CLAN_DRAGON)
			return NAMEK_STATS_DRAGON
		if(NAMEK_CLAN_DEMON)
			return NAMEK_STATS_DEMON
	return null

/proc/NamekAscensionAdds(clan, asc)
	switch(asc)
		if(1)
			switch(clan)
				if(NAMEK_CLAN_WARRIOR)
					return NAMEK_ASC1_WARRIOR
				if(NAMEK_CLAN_DRAGON)
					return NAMEK_ASC1_DRAGON
				if(NAMEK_CLAN_DEMON)
					return NAMEK_ASC1_DEMON
		if(2)
			switch(clan)
				if(NAMEK_CLAN_WARRIOR)
					return NAMEK_ASC2_WARRIOR
				if(NAMEK_CLAN_DRAGON)
					return NAMEK_ASC2_DRAGON
				if(NAMEK_CLAN_DEMON)
					return NAMEK_ASC2_DEMON
		if(3)
			switch(clan)
				if(NAMEK_CLAN_WARRIOR)
					return NAMEK_ASC3_WARRIOR
				if(NAMEK_CLAN_DRAGON)
					return NAMEK_ASC3_DRAGON
				if(NAMEK_CLAN_DEMON)
					return NAMEK_ASC3_DEMON
	return null

/proc/NamekClanPaths(clan)
	switch(clan)
		if(NAMEK_CLAN_WARRIOR)
			return list(NAMEK_PATH_DARK_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT)
		if(NAMEK_CLAN_DRAGON)
			return list(NAMEK_PATH_DENDE_PRIEST, NAMEK_PATH_POKO_PRIEST)
		if(NAMEK_CLAN_DEMON)
			return list(NAMEK_PATH_DEMON_KING, NAMEK_PATH_CONQUEROR)
	return list()

/proc/NamekPathClan(path)
	switch(path)
		if(NAMEK_PATH_DARK_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT)
			return NAMEK_CLAN_WARRIOR
		if(NAMEK_PATH_DENDE_PRIEST, NAMEK_PATH_POKO_PRIEST)
			return NAMEK_CLAN_DRAGON
		if(NAMEK_PATH_DEMON_KING, NAMEK_PATH_CONQUEROR)
			return NAMEK_CLAN_DEMON
	return null

/proc/NamekPathBlurb(path)
	switch(path)
		if(NAMEK_PATH_DARK_WARRIOR)
			return "A sturdy bruiser with area damage and a lifesteal strike."
		if(NAMEK_PATH_SHADOW_KNIGHT)
			return "The tank, with a taunt, Fear, a big health line and body-blocking."
		if(NAMEK_PATH_DENDE_PRIEST)
			return "Healer and party support, with revival and the elder's gift."
		if(NAMEK_PATH_POKO_PRIEST)
			return "The egg summoner, with Hearthstone attacks and buffs for your hatchlings."
		if(NAMEK_PATH_DEMON_KING)
			return "The line of King Piccolo: the Explosive Demon Wave, the Makosen feint, the demon mark and the reincarnation egg."
		if(NAMEK_PATH_CONQUEROR)
			return "The line of Lord Slug: the Darkness Eye Beam, Psycho Pull, mind reading and the strongest Giant Form."
	return ""

/proc/NamekPathPassives(path, asc)
	switch(path)
		if(NAMEK_PATH_DARK_WARRIOR)
			switch(asc)
				if(1)
					return list("Momentum" = 1)
				if(3)
					return list("Momentum" = 1)
				if(5)
					return list("Fury" = 1)
		if(NAMEK_PATH_SHADOW_KNIGHT)
			switch(asc)
				if(1)
					return list("Harden" = 1)
				if(3)
					return list("Juggernaut" = 1)
				if(5)
					return list("MeleeResist" = 1)
				if(6)
					return list("Tenacity" = 2)
		if(NAMEK_PATH_DENDE_PRIEST)
			switch(asc)
				if(1)
					return list("QuickCast" = 1)
				if(2)
					return list("ManaGeneration" = 2)
				if(4)
					return list("ManaPU" = 1)
		if(NAMEK_PATH_POKO_PRIEST)
			switch(asc)
				if(1)
					return list("QuickCast" = 1)
				if(2)
					return list("ManaGeneration" = 1)
		if(NAMEK_PATH_DEMON_KING)
			switch(asc)
				if(1)
					return list("Fury" = 1)
				if(3)
					return list("Momentum" = 1)
				if(5)
					return list("Flicker" = 1)
		if(NAMEK_PATH_CONQUEROR)
			switch(asc)
				if(1)
					return list("Harden" = 1)
				if(3)
					return list("RangedResist" = 1)
				if(5)
					return list("Juggernaut" = 1)
	return list()

/proc/NamekFormForClan(clan)
	switch(clan)
		if(NAMEK_CLAN_WARRIOR)
			return "/transformation/namekian/super_namekian"
		if(NAMEK_CLAN_DEMON)
			return "/transformation/namekian/demon_clan_release"
		if(NAMEK_CLAN_DRAGON)
			return "/transformation/namekian/dragon_awakening"
	return null

var/list/NamekSkillRows = list(\
	list(null, null, 0, "/obj/Skills/Projectile/Namekian/Mystic_Attack"),\
	list(null, null, 0, "/obj/Skills/AutoHit/Namekian/Antenna_Beam"),\
	list(null, null, 0, "/obj/Skills/Projectile/Namekian/Mouth_Energy_Wave"),\
	list(null, null, 0, "/obj/Skills/Utility/Namekian/Regrow"),\
	list(null, null, 0, "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Regeneration"),\
	list(null, null, 2, "/obj/Skills/Utility/Namekian/Namekian_Fusion"),\
	list(NAMEK_CLAN_WARRIOR, null, 0, "/obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form"),\
	list(NAMEK_CLAN_DEMON, null, 0, "/obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form"),\
	list(NAMEK_CLAN_WARRIOR, null, 0, "/obj/Skills/Projectile/Namekian/Masenko"),\
	list(NAMEK_CLAN_WARRIOR, null, 0, "/obj/Skills/Queue/Namekian/Charging_Fist"),\
	list(NAMEK_CLAN_WARRIOR, null, 0, "/obj/Skills/Buffs/SlotlessBuffs/Namekian/Draconic_Protection"),\
	list(NAMEK_CLAN_WARRIOR, null, 1, "/obj/Skills/Projectile/Beams/Big/Namekian/Charged_Masenko"),\
	list(NAMEK_CLAN_WARRIOR, null, 1, "/obj/Skills/Queue/Namekian/Draconic_Overpowering"),\
	list(NAMEK_CLAN_WARRIOR, null, 2, "/obj/Skills/Projectile/Beams/Big/Namekian/Special_Beam_Cannon"),\
	list(NAMEK_CLAN_WARRIOR, null, 2, "/obj/Skills/Projectile/Namekian/Draconic_Curse"),\
	list(NAMEK_CLAN_WARRIOR, null, 3, "/obj/Skills/Projectile/Namekian/Hellzone_Grenade"),\
	list(NAMEK_CLAN_WARRIOR, null, 3, "/obj/Skills/Feva/Splitform"),\
	list(NAMEK_CLAN_WARRIOR, null, 4, "/obj/Skills/Projectile/Namekian/Light_Grenade"),\
	list(NAMEK_CLAN_WARRIOR, null, 6, "/obj/Skills/Projectile/Beams/Big/Namekian/Masenko_Beam_Cannon"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 1, "/obj/Skills/AutoHit/Namekian/Whirlwind"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 1, "/obj/Skills/Queue/Namekian/Deep_Strike"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 2, "/obj/Skills/AutoHit/Namekian/Dragons_Punishment"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 2, "/obj/Skills/AutoHit/Namekian/Cyclone"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 3, "/obj/Skills/Buffs/SlotlessBuffs/Namekian/Dragons_Pledge"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 3, "/obj/Skills/Projectile/Namekian/Demon_Wave"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 4, "/obj/Skills/Queue/Namekian/Dragon_Strike"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_DARK_WARRIOR, 5, "/obj/Skills/Projectile/Namekian/Energy_Siege"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 1, "/obj/Skills/Utility/Namekian/Draconic_Taunt"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 1, "/obj/Skills/Queue/Namekian/Bold_Strike"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 1, "/obj/Skills/Buffs/SlotlessBuffs/Namekian/Intense_Concentration"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 2, "/obj/Skills/AutoHit/Namekian/Deception"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 2, "/obj/Skills/Utility/Namekian/Curse"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 2, "/obj/Skills/AutoHit/Namekian/Self_Destruction_Wave"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 3, "/obj/Skills/Utility/Namekian/Fear"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 3, "/obj/Skills/Queue/Namekian/Violent_Slice"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 3, "/obj/Skills/Utility/Namekian/Dragons_Oath"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 4, "/obj/Skills/Utility/Namekian/Steal_Life"),\
	list(NAMEK_CLAN_WARRIOR, NAMEK_PATH_SHADOW_KNIGHT, 5, "/obj/Skills/Queue/Namekian/Cleave"),\
	list(NAMEK_CLAN_DRAGON, null, 0, "/obj/Skills/Projectile/Namekian/Energy_Cannon"),\
	list(NAMEK_CLAN_DRAGON, null, 0, "/obj/Skills/Utility/Namekian/Healing_Wave"),\
	list(NAMEK_CLAN_DRAGON, null, 0, "/obj/Skills/Utility/Namekian/Kamis_Blessing"),\
	list(NAMEK_CLAN_DRAGON, null, 1, "/obj/Skills/Utility/Namekian/Kamis_Hope"),\
	list(NAMEK_CLAN_DRAGON, null, 1, "/obj/Skills/Utility/Namekian/Kamis_Barrier"),\
	list(NAMEK_CLAN_DRAGON, null, 1, "/obj/Skills/Projectile/Namekian/Energy_Bullets"),\
	list(NAMEK_CLAN_DRAGON, null, 2, "/obj/Skills/Utility/Namekian/Kamis_Desire"),\
	list(NAMEK_CLAN_DRAGON, null, 2, "/obj/Skills/Projectile/Namekian/Ignite"),\
	list(NAMEK_CLAN_DRAGON, null, 3, "/obj/Skills/Projectile/Namekian/Super_Energy_Bullets"),\
	list(NAMEK_CLAN_DRAGON, null, 3, "/obj/Skills/Utility/Namekian/Kamis_Will"),\
	list(NAMEK_CLAN_DRAGON, null, 4, "/obj/Skills/Utility/Namekian/Forge_Dragon_Balls"),\
	list(NAMEK_CLAN_DRAGON, null, 4, "/obj/Skills/Utility/Namekian/Name_a_Successor"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 1, "/obj/Skills/Utility/Namekian/Super_Healing_Wave"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 1, "/obj/Skills/Utility/Namekian/Kamis_Mercy"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 1, "/obj/Skills/Utility/Namekian/Divine_Cure"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 2, "/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Healing_Technique"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 2, "/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Aurora"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 2, "/obj/Skills/Utility/Namekian/Kamis_Energy"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 3, "/obj/Skills/Utility/Namekian/Unleashed_Spirit"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 3, "/obj/Skills/Utility/Namekian/Instantaneous_Movement"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 4, "/obj/Skills/Utility/Namekian/Kamis_Revival"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 4, "/obj/Skills/Utility/Namekian/Draw_Out_Potential"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_DENDE_PRIEST, 5, "/obj/Skills/Utility/Namekian/Final_Healing_Wave"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/Companion/Namekian/Hatchling_Commands"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/Companion/Namekian/Hatchling/land_dragon"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/Companion/Namekian/Hatchling/sky_dragon"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 2, "/obj/Skills/Companion/Namekian/Hatchling/tambourine"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 3, "/obj/Skills/Companion/Namekian/Hatchling/cymbal"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 4, "/obj/Skills/Companion/Namekian/Hatchling/drum"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/Projectile/Namekian/First_Law_of_the_Hearthstone"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/AutoHit/Namekian/Hearthstone_Flash"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/Utility/Namekian/Kamis_Escort"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 1, "/obj/Skills/Utility/Namekian/Kamis_Epoch"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 2, "/obj/Skills/AutoHit/Namekian/Second_Law_of_the_Hearthstone"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 2, "/obj/Skills/Utility/Namekian/Kamis_Blitz"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 2, "/obj/Skills/Utility/Namekian/Kamis_Determination"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 3, "/obj/Skills/Utility/Namekian/Poko_Curse"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 3, "/obj/Skills/AutoHit/Namekian/Poko_Frenzy"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 3, "/obj/Skills/Utility/Namekian/Kamis_Awakening"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 4, "/obj/Skills/Utility/Namekian/Kamis_Protection"),\
	list(NAMEK_CLAN_DRAGON, NAMEK_PATH_POKO_PRIEST, 4, "/obj/Skills/Utility/Namekian/Kamis_Retreat"),\
	list(NAMEK_CLAN_DEMON, null, 0, "/obj/Skills/Projectile/Namekian/Explosive_Demon_Wave"),\
	list(NAMEK_CLAN_DEMON, null, 0, "/obj/Skills/Projectile/Namekian/Eye_Laser"),\
	list(NAMEK_CLAN_DEMON, null, 1, "/obj/Skills/Projectile/Namekian/Finger_Beam"),\
	list(NAMEK_CLAN_DEMON, null, 2, "/obj/Skills/AutoHit/Namekian/Exploding_Wave"),\
	list(NAMEK_CLAN_DEMON, null, 2, "/obj/Skills/Utility/Namekian/Medas"),\
	list(NAMEK_CLAN_DEMON, null, 3, "/obj/Skills/AutoHit/Namekian/Hyper_Explosive_Demon_Wave"),\
	list(NAMEK_CLAN_DEMON, null, 4, "/obj/Skills/Projectile/Namekian/Darkness_Twin_Star"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_DEMON_KING, 1, "/obj/Skills/Utility/Namekian/Demon_Mark"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_DEMON_KING, 1, "/obj/Skills/Projectile/Namekian/Makosen"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_DEMON_KING, 2, "/obj/Skills/AutoHit/Namekian/Dont_Get_Cocky"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_DEMON_KING, 2, "/obj/Skills/Utility/Namekian/Dragon_Ball_Sense"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_DEMON_KING, 5, "/obj/Skills/Projectile/Namekian/Soumasen"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 1, "/obj/Skills/Projectile/Namekian/Darkness_Eye_Beam"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 1, "/obj/Skills/Utility/Namekian/Psycho_Pull"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 2, "/obj/Skills/Utility/Namekian/Mind_Read"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 2, "/obj/Skills/Buffs/SlotlessBuffs/Namekian/Energy_Shield"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 3, "/obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form/Conqueror", "/obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 4, "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Power_of_Darkness"),\
	list(NAMEK_CLAN_DEMON, NAMEK_PATH_CONQUEROR, 5, "/obj/Skills/Projectile/Beams/Big/Namekian/Darkness_Blaster"))

/proc/NamekManagedSkillTypes()
	var/list/out = list()
	for(var/list/row in NamekSkillRows)
		for(var/i = 4, i <= row.len, i++)
			if(!row[i])
				continue
			var/T = text2path(row[i])
			if(ispath(T))
				out |= T
	return out

transformation/namekian

globalTracker
	var
		list/NamekDragonSets = list()
		NamekDragonSetLimit = 2
		NamekDragonZ = 0
		tmp/list/NamekDragonWishes = list("Restore" = "NamekWishRestore", "Fortune" = "NamekWishFortune", "Revive" = "NamekWishRevive", "Shelter" = "NamekWishShelter", "Awaken" = "NamekWishAwaken")

mob
	var
		NamekPath
		NamekEvoApplied = 0
		NamekReconstituteAt = 0
		NamekReincarnationAt = 0
		NamekDarknessApplied = 0
		list/NamekFusions
		NamekFusionSteps = 0
		NamekAssimilated = 0
		NamekAssimilatedInto
		NamekPotentialGiven = 0
		NamekPotentialReceived = 0
		NamekDragonSetId
		NamekDragonSuccessor
		tmp
			mob/NamekHatchling
			NamekUntargetableUntil = 0
			NamekTargetLockUntil = 0
			mob/NamekTargetLockTo
			NamekTargetLockImmuneUntil = 0
			NamekFearUntil = 0
			mob/NamekFearFrom
			NamekOathUntil = 0
			NamekCurseUntil = 0
			NamekCursePaidAt = 0
			NamekStealLifeUntil = 0
			NamekPledgeReadyAt = 0

/mob/proc/NamekIsNamek()
	return src.race && src.isRace(NAMEKIAN)

/mob/proc/NamekTargetLockRefuses(atom/target)
	if(src.NamekTargetLockUntil <= world.time)
		return 0
	var/mob/L = src.NamekTargetLockTo
	if(!ismob(L) || L.z != src.z || L.KO)
		src.NamekTargetLockUntil = 0
		src.NamekTargetLockTo = null
		return 0
	return target != L

/mob/proc/NamekFeared()
	if(src.NamekFearUntil <= world.time)
		return 0
	var/mob/F = src.NamekFearFrom
	if(!ismob(F) || F.z != src.z)
		return 0
	return 1

/mob/proc/NamekFearMoveMult()
	if(NamekFeared())
		return NAMEK_FEAR_MOVE_DELAY
	return 1

/mob/proc/NamekFearRefusesStep(D)
	if(!D || !NamekFeared())
		return 0
	var/turf/next = get_step(src, D)
	if(!next)
		return 0
	return get_dist(next, src.NamekFearFrom) < get_dist(src, src.NamekFearFrom)

/mob/proc/NamekFearRefusesDash()
	if(!NamekFeared() || !ismob(src.Target))
		return 0
	return get_dist(src.Target, src.NamekFearFrom) < get_dist(src, src.NamekFearFrom)

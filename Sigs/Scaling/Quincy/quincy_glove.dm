#define QUINCY_GLOVE_REPORT 600
#define QUINCY_GLOVE_COMBAT_RANGE 15
#define QUINCY_GLOVE_COMBAT_WINDOW 100

mob/var/tmp/QuincyGloveLoopOn = 0

/obj/Skills/Buffs/SlotlessBuffs/Sanrei_Glove
	name = "Sanrei Glove"
	BuffName = "Sanrei Glove"
	Slotless = 1
	passives = list("Reishi Convergence" = -0.5)
	ActiveMessage = "pulls on the Sanrei Glove; the Reishi scatters from their hand."
	OffMessage = "takes off the training glove."

	verb/Sanrei_Glove()
		set name = "Sanrei Glove"
		set category = "Skills"
		if(!src.SlotlessOn && !usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		src.Trigger(usr)

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Sanrei_Glove))
		QuincyGloveLoop(B)

/mob/proc/QuincyGloveInCombat()
	var/mob/t = src.Target
	if(!ismob(t) || t == src || t.z != src.z || get_dist(src, t) > QUINCY_GLOVE_COMBAT_RANGE)
		return 0
	if(!FightingSeriously(src, t))
		return 0
	if(t.last_attacker == src && world.time - t.last_damaged_time <= QUINCY_GLOVE_COMBAT_WINDOW)
		return 1
	if(src.last_attacker == t && world.time - src.last_damaged_time <= QUINCY_GLOVE_COMBAT_WINDOW)
		return 1
	return 0

/mob/proc/QuincyGloveLoop(obj/Skills/Buffs/G)
	set waitfor = 0
	if(src.QuincyGloveLoopOn)
		return
	src.QuincyGloveLoopOn = 1
	while(src && G && G.SlotlessOn)
		sleep(10)
		if(!src || !G || !G.SlotlessOn)
			break
		if(!QuincyGloveInCombat())
			continue
		var/was = src.QuincyGloveMastery
		src.QuincyGloveMastery++
		if(was < QUINCY_GLOVE_MASTERY && src.QuincyGloveMastery >= QUINCY_GLOVE_MASTERY)
			src << "<font color=#9fd8ff><b>Your hands bleed, but your weapon holds. You have mastered the Sanrei Glove.</b></font>"
			QuincyGloveApply()
		else if(src.QuincyGloveMastery < QUINCY_GLOVE_MASTERY && src.QuincyGloveMastery % QUINCY_GLOVE_REPORT == 0)
			src << "<font color=#9fd8ff>Sanrei Glove training: [round(src.QuincyGloveMastery / 60)] of [round(QUINCY_GLOVE_MASTERY / 60)] minutes.</font>"
	if(src)
		src.QuincyGloveLoopOn = 0

/mob/proc/QuincyGloveApply()
	var/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/W = locate(/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon) in src
	if(W)
		W.adjust(src)
	if(src.QuincyWeaponItem)
		src.QuincyWeaponItem.ConjureShape(src)
	QuincySyncSkills()

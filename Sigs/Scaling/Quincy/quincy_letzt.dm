#define QUINCY_LETZT_IDLE 10
#define QUINCY_LETZT_DRAIN 5
#define QUINCY_LETZT_DRAIN_RANGE 5
#define QUINCY_LETZT_END_EFF 0.5
#define QUINCY_RESTORE_MULT 1.15
#define QUINCY_RESTORE_RANGE 3

mob/var/tmp/QuincyLetztLoopOn = 0
obj/Skills/Projectile/var/tmp/QuincyLetztStamped = 0

/obj/Skills/Buffs/SlotlessBuffs/Letzt_Stil
	name = "Letzt Stil"
	BuffName = "Letzt Stil"
	Slotless = 1
	StrMult = 1.5
	EndMult = 1.5
	ForMult = 1.5
	OffMult = 1.5
	DefMult = 1.5
	SpdMult = 1.5
	TimerLimit = 90
	ActiveMessage = "tears off the Sanrei Glove. The Reishi floods in."

	Trigger(mob/User, Override = 0)
		var/wasOn = src.SlotlessOn
		. = ..()
		if(!wasOn && src.SlotlessOn)
			User.QuincyLetztStart(src)
		else if(wasOn && !src.SlotlessOn)
			User.QuincyLetztEnd()

	verb/Remove_the_Glove()
		set name = "Remove the Glove"
		set category = "Skills"
		if(src.SlotlessOn)
			src.Trigger(usr)
			return
		if(usr.QuincyLevel < 4)
			usr << "You have not reached the mastery to remove the glove."
			return
		if(usr.QuincyGloveBroken)
			usr << "The glove is already broken. Its power is spent."
			return
		if(usr.QuincyGloveMastery < QUINCY_GLOVE_MASTERY)
			usr << "You have not mastered the Sanrei Glove yet."
			return
		if(locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal) in usr)
			usr << "Your body has sealed itself off from the Reishi."
			return
		if(!usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal
	name = "Sealed Quincy Powers"
	BuffName = "Sealed Quincy Powers"
	AlwaysOn = 1
	doNotDelete = 1
	Cooldown = 0
	Copyable = 0
	StrMult = 0.7
	EndMult = 0.7
	ForMult = 0.7
	SpdMult = 0.5
	OffMult = 0.5
	DefMult = 0.5
	passives = list("ManaLeak" = 5)
	UICustomDescription = "Your body has sealed itself off from the Reishi. The next level of mastery restores it."

/mob/proc/QuincyLetztStart(obj/Skills/Buffs/B)
	src.QuincyLetztActive = 1
	QuincyLetztLoop(B)

/mob/proc/QuincyLetztLoop(obj/Skills/Buffs/B)
	set waitfor = 0
	if(src.QuincyLetztLoopOn)
		return
	src.QuincyLetztLoopOn = 1
	var/idle = 0
	while(src && B && B.SlotlessOn)
		sleep(10)
		if(!src || !B || !B.SlotlessOn)
			break
		QuincyLetztDrain()
		if(QuincyGloveInCombat())
			idle = 0
			continue
		idle++
		if(idle >= QUINCY_LETZT_IDLE)
			B.Trigger(src, 1)
			break
	if(src)
		src.QuincyLetztLoopOn = 0

/mob/proc/QuincyLetztDrain()
	for(var/mob/m in range(QUINCY_LETZT_DRAIN_RANGE, src))
		if(m == src)
			continue
		if(src.inParty(m.ckey))
			continue
		var/before = m.ManaAmount
		m.LoseMana(QUINCY_LETZT_DRAIN)
		var/took = before - m.ManaAmount
		if(took > 0)
			src.HealMana(min(took, QUINCY_LETZT_DRAIN))

/mob/proc/QuincyLetztEnd()
	src.QuincyLetztActive = 0
	src.QuincyGloveBroken = 1
	var/obj/Skills/Buffs/G = QuincyOwnedSkill(/obj/Skills/Buffs/SlotlessBuffs/Sanrei_Glove)
	if(G)
		if(BuffOn(G))
			G.Trigger(src, 1)
		DeleteSkill(G)
	if(QuincyWeaponDrawn())
		src.SpecialBuff.Trigger(src, 1)
	OMsg(src, "<font color=#9fd8ff>The flame burns out. [src]'s body seals itself away from the Reishi.</font>")
	QuincyApplySeal()

/mob/proc/QuincyApplySeal()
	var/obj/Skills/Buffs/S = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal)
	if(S && !BuffOn(S))
		S.Trigger(src, 1)

/mob/proc/QuincyRestore()
	var/obj/Skills/Buffs/S = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal) in src
	if(!S)
		return
	if(BuffOn(S))
		S.Trigger(src, 1)
	DeleteSkill(S)
	src << "<font color=#9fd8ff>You fight on past exhaustion, to the very limit of your body.</font>"
	src << "<font color=#9fd8ff>A single arrow pierces you 19 mm to the right of the heart, and the sealed paths of Reishi tear open.</font>"
	src << "<font color=#9fd8ff><b>The wound closes into a pentacle scar. Your Quincy Cross is a pentacle now. Draw your Spirit Weapon again to feel its new strength.</b></font>"

/mob/Players/QuincySyncSkills()
	..()
	if(src.QuincyLevel >= 5 && (locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal) in src))
		QuincyRestore()

/mob/Players/QuincyWantsSkill(list/row)
	. = ..()
	if(. && src.QuincyGloveBroken && text2path(row[1]) == /obj/Skills/Buffs/SlotlessBuffs/Sanrei_Glove)
		return 0

/mob/Players/Login()
	..()
	spawn(10)
		if(src)
			var/obj/Skills/Buffs/L = locate(/obj/Skills/Buffs/SlotlessBuffs/Letzt_Stil) in src
			if(L && BuffOn(L))
				L.Trigger(src, 1)

/strikeHook/QuincyLetztKO
	stage = "ko"

	fire(strike/S)
		var/mob/M = S ? S.defender : null
		if(!M)
			return
		var/obj/Skills/Buffs/L = locate(/obj/Skills/Buffs/SlotlessBuffs/Letzt_Stil) in M
		if(L && M.BuffOn(L))
			L.Trigger(M, TRUE)

/mob/Players/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	if(!S)
		return
	if(src.QuincyLetztActive && istype(g, /obj/Items/Gun/Quincy))
		S.EndEffectiveness = QUINCY_LETZT_END_EFF
		S.ShieldPierce = 1
		S.QuincyLetztStamped = 1
	else if(S.QuincyLetztStamped)
		S.ShieldPierce = initial(S.ShieldPierce)
		S.QuincyLetztStamped = 0

obj/Items/Gun/Quincy/Heilig_Bogen/ConjureShape(mob/p)
	..()
	if(p && p.QuincyLevel >= 5)
		ModelDamage *= QUINCY_RESTORE_MULT
		setStatLine()

obj/Items/Gun/Quincy/Reishi_Pistol/ClassRange()
	. = ..()
	var/mob/m = src.loc
	if(ismob(m) && m.QuincyLevel >= 5)
		. += QUINCY_RESTORE_RANGE

#define QUINCY_IRON_MELEE_TAKEN 0.2
#define QUINCY_IRON_SPD 0.7
#define QUINCY_IRON_HOLLOW_MOD 0.5
#define QUINCY_IRON_ARM_TIME 50
#define QUINCY_IRON_NAG 10

mob/var/tmp/IronArmUntil = 0
mob/var/tmp/IronNagAt = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/I_The_Iron/New()
	..()
	kit_skills = list(/obj/Skills/Buffs/SlotlessBuffs/Iron_Skin, /obj/Skills/Quincy/Iron_Arm, /obj/Skills/Projectile/Quincy/She_Jin_Zhao)

/obj/Skills/Buffs/SlotlessBuffs/Iron_Skin
	name = "Iron Skin"
	BuffName = "Iron Skin"
	desc = "Turn your skin to iron: melee lands at a fifth, energy is untouched, you move slower, cannot dodge and cannot shoot."
	Slotless = 1
	Copyable = 0
	SpdMult = QUINCY_IRON_SPD
	passives = list("NoDodge" = 1)
	ActiveMessage = "hardens their skin into iron."
	OffMessage = "lets the iron fade from their skin."

	verb/Iron_Skin()
		set name = "Iron Skin"
		set category = "Skills"
		if(src.SlotlessOn)
			src.Trigger(usr)
			return
		if(!usr.SchriftNeeded("I"))
			usr << "Only the bearer of The Iron can harden their skin."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Iron_Arm_Guard
	name = "Iron Arm"
	BuffName = "Iron Arm Guard"
	Slotless = 1
	Copyable = 0
	Cooldown = 0
	TimerLimit = 5

/mob/proc/IronSkinOnNow()
	if(!src.SlotlessBuffs)
		return 0
	var/obj/Skills/Buffs/B = src.SlotlessBuffs["Iron Skin"]
	return istype(B, /obj/Skills/Buffs/SlotlessBuffs/Iron_Skin) && B.SlotlessOn

/mob/proc/IronArmGuardNow()
	return src.IronArmUntil > world.time

/mob/proc/IronArmGuardBuffOff()
	if(!src.SlotlessBuffs)
		return
	var/obj/Skills/Buffs/B = src.SlotlessBuffs["Iron Arm Guard"]
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Iron_Arm_Guard) && B.SlotlessOn)
		B.Trigger(src, 1)

/mob/proc/IronArmRaise(ds)
	src.IronArmUntil = world.time + ds
	var/obj/Skills/Buffs/SlotlessBuffs/Iron_Arm_Guard/B = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Iron_Arm_Guard)
	if(B && !B.SlotlessOn)
		B.Trigger(src, 1)

/mob/proc/IronArmSpend()
	src.IronArmUntil = 0
	IronArmGuardBuffOff()
	OMsg(src, "[src]'s arm of iron turns the blow aside!")

/mob/proc/IronRefuse()
	if(src.IronNagAt > world.time)
		return
	src.IronNagAt = world.time + QUINCY_IRON_NAG
	src << "Iron does not shoot."

/mob/proc/IronShatterBinds()
	var/n = 0
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/sn = locate() in src
	if(sn && BuffOn(sn))
		sn.Trigger(src, 1)
		n++
	if(src.Stunned)
		StunClear(src)
		n++
	if(n)
		OMsg(src, "[src]'s iron body shatters every bind upon it!")
	return n

/mob/proc/IronWeaponResync()
	var/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/W = locate() in src
	if(!W || !src.BuffOn(W))
		return 0
	var/want = src.SchriftNeeded("I") ? 1 : 0
	var/have = (W.MakesSword && W.MakesSecondSword && W.SwordName == "Reishi Claw") ? 1 : 0
	if(want == have)
		return 0
	W.Trigger(src, 1)
	src << "Your Spirit Weapon comes apart in your hands. Draw it again."
	return 1

/mob/Players/getMeleeResistValue()
	. = ..()
	if(IronArmGuardNow())
		IronArmSpend()
		return 0
	if(IronSkinOnNow())
		. *= QUINCY_IRON_MELEE_TAKEN

/proc/QuincyBalanceForcedNow(mob/a, mob/d)
	if(!ismob(a) || !ismob(d))
		return 0
	return a.BalanceForcedCritNow && a.BalanceForcedCrit == d

/strikeHook/quincyIronBalance
	stage = "crit"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || !S.melee || S.dealt <= 0)
			return
		if(!d.IronSkinOnNow() || !QuincyBalanceForcedNow(a, d))
			return
		d.LoseHealth(S.dealt * (1 / QUINCY_IRON_MELEE_TAKEN - 1))

/mob/Players/attackModifiers(mob/defender, list/forcedDmgList=list())
	. = ..()
	if(ismob(defender) && HollowIsHollow() && defender.IronSkinOnNow())
		. += QUINCY_IRON_HOLLOW_MOD

/mob/Players/FireGun(obj/Items/Gun/g)
	if(IronSkinOnNow())
		IronRefuse()
		return 0
	return ..()

/mob/Players/UseProjectile(var/obj/Skills/Projectile/Z, noGCD = FALSE)
	if(IronSkinOnNow())
		IronRefuse()
		return 0
	return ..()

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(B && B.IsVollstandig && SchriftNeeded("I"))
		IronShatterBinds()

/mob/Players/QuincySyncSkills()
	..()
	IronWeaponResync()
	if(!SchriftNeeded("I"))
		if(src.IronArmUntil)
			src.IronArmUntil = 0
		IronArmGuardBuffOff()
		for(var/obj/Skills/S in src)
			if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/Iron_Arm_Guard) || istype(S, /obj/Skills/Projectile/Quincy/Serpent_Head))
				QuincyDropSkill(S)

/obj/Skills/Quincy/Iron_Arm
	name = "Iron Arm"
	desc = "For 5 seconds, the next melee hit you take lands for nothing."
	Cooldown = 15
	Copyable = 0
	var/seconds = QUINCY_IRON_ARM_TIME

	verb/Iron_Arm()
		set name = "Iron Arm"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		ArmFire(User)

	proc/ArmFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("I"))
			User << "Only the bearer of The Iron can raise an arm of iron."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		User.IronArmRaise(src.seconds)
		OMsg(User, "[User] raises an arm of iron.")
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Projectile/Quincy/She_Jin_Zhao
	name = "She Jin Zhao"
	desc = "Two blasts that merge into a serpent's head."
	Blasts = 2
	SpreadArc = 20
	DamageMult = 0.9
	Distance = 10
	FollowUp = "/obj/Skills/Projectile/Quincy/Serpent_Head"
	FollowUpDelay = 5
	Cooldown = 20
	ManaCost = 6
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ActiveMessage = "looses two coiling blasts: She Jin Zhao!"

	verb/She_Jin_Zhao()
		set name = "She Jin Zhao"
		set category = "Skills"
		if(!usr.SchriftNeeded("I"))
			usr << "Only the bearer of The Iron can loose She Jin Zhao."
			return
		usr.UseProjectile(src)

/obj/Skills/Projectile/Quincy/Serpent_Head
	name = "Serpent Head"
	DamageMult = 1.8
	Explode = 1
	Distance = 10
	Cooldown = 1
	NoGCD = 1
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 2
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ActiveMessage = "merges the blasts into a serpent's head!"

/proc/QuincyTestStepsI()
	return list("Iron Skin", "Iron Arm", "Shatter binds", "She Jin Zhao", "Resync the weapon")

/mob/proc/QuincyTestI(step, mob/t)
	switch(step)
		if("Iron Skin")
			var/obj/Skills/Buffs/SlotlessBuffs/Iron_Skin/B = locate() in src
			if(!B)
				return "no Iron Skin"
			B.Trigger(src, 1)
			return "ironed [IronSkinOnNow()]"
		if("Iron Arm")
			IronArmRaise(QUINCY_IRON_ARM_TIME)
			return "guard until [src.IronArmUntil]"
		if("Shatter binds")
			applySnare(5, null, TRUE)
			return "shattered [IronShatterBinds()]"
		if("She Jin Zhao")
			var/obj/Skills/Projectile/Quincy/She_Jin_Zhao/S = locate() in src
			if(!S)
				S = new
			return "fired [UseProjectile(S)]"
		if("Resync the weapon")
			return "resynced [IronWeaponResync()]"
	return "unknown step"

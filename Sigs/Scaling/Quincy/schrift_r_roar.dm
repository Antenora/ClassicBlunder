#define QUINCY_R_DEAFEN 60
#define QUINCY_R_STUN_BASE 0.5
#define QUINCY_R_STUN_POT 100
#define QUINCY_R_STUN_STEP 25
#define QUINCY_R_FODDER_POT 25
#define QUINCY_R_FODDER_MULT 2

mob/var/tmp/DeafenedUntil = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/R_The_Roar/New()
	..()
	kit_skills = list(/obj/Skills/Buffs/SlotlessBuffs/Feral_Form, /obj/Skills/AutoHit/Quincy/Roar)

/obj/Skills/Buffs/SlotlessBuffs/Feral_Form
	name = "Feral Form"
	BuffName = "Feral Form"
	desc = "Let the beast out: your body grows a size and your Strength rises by 30 percent, while your Mana bleeds away."
	Slotless = 1
	Copyable = 0
	StrMult = 1.3
	Enlarge = 1.25
	passives = list("ManaLeak" = 1)
	ActiveMessage = "lets the beast out. Their body swells with a feral growl."
	OffMessage = "reins the beast back in."

	verb/Feral_Form()
		set name = "Feral Form"
		set category = "Skills"
		if(src.SlotlessOn)
			src.Trigger(usr)
			return
		if(!usr.SchriftNeeded("R"))
			usr << "Only the bearer of The Roar can go feral."
			return
		src.Trigger(usr)

/obj/Skills/AutoHit/Quincy

/obj/Skills/AutoHit/Quincy/Roar
	name = "Roar"
	desc = "In Feral Form only: roar in a cone 5 tiles long. Everyone caught is shoved back, deafened for 6 seconds (a held charge fizzles, and The Question cannot object to them) and stunned for half a second for every 25 Potential they lack below 100. The weak freeze; the strong shrug it off."
	Area = "Arc"
	Distance = 5
	DamageMult = 1.4
	Knockback = 3
	Cooldown = 15
	ManaCost = 6
	Copyable = 0
	ActiveMessage = "lets out a deafening roar!"

	verb/Roar()
		set name = "Roar"
		set category = "Skills"
		if(!usr.SchriftNeeded("R"))
			usr << "Only the bearer of The Roar can roar like this."
			return
		if(!usr.RoarFeralOn())
			usr << "The Roar answers only in Feral Form."
			return
		usr.Activate(src)

/mob/proc/RoarFeralOn()
	var/obj/Skills/Buffs/SlotlessBuffs/Feral_Form/F = locate() in src
	return F && F.SlotlessOn

/mob/proc/DeafenedNow()
	return src.DeafenedUntil > world.time

/proc/RoarStunFor(mob/m)
	if(!ismob(m))
		return 0
	return QUINCY_R_STUN_BASE * max(0, (QUINCY_R_STUN_POT - m.Potential) / QUINCY_R_STUN_STEP)

/mob/proc/RoarStruck(mob/a)
	src.DeafenedUntil = world.time + QUINCY_R_DEAFEN
	if(src.held_skill)
		FizzleHeldSkill(src.held_skill)
	src << "<font color=#ff9a6b>The roar leaves your ears ringing.</font>"
	var/secs = RoarStunFor(src)
	if(secs > 0)
		Stun(src, secs)
	return secs

/strikeHook/quincyRoar
	stage = "post"
	fire(strike/S)
		if(!istype(S.skill, /obj/Skills/AutoHit/Quincy/Roar))
			return
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d)
			return
		d.RoarStruck(a)

/mob/Player/AI/QuincyDamageTakenMult(skilltype)
	. = ..()
	if(ispath(skilltype, /obj/Skills/AutoHit/Quincy/Roar) && src.Potential < QUINCY_R_FODDER_POT)
		. *= QUINCY_R_FODDER_MULT

/proc/QuincyTestStepsR()
	return list("Feral on or off", "Roar now", "Deafen the target", "Read the target")

/mob/proc/QuincyTestR(step, mob/t)
	switch(step)
		if("Feral on or off")
			var/obj/Skills/Buffs/SlotlessBuffs/Feral_Form/F = locate() in src
			if(!F)
				return "no Feral Form (engrave R first)"
			F.Trigger(src)
			return "feral [RoarFeralOn() ? "on" : "off"]"
		if("Roar now")
			var/obj/Skills/AutoHit/Quincy/Roar/R = locate() in src
			if(!R)
				return "no Roar (engrave R first)"
			if(!RoarFeralOn())
				return "go feral first"
			var/stamp = R.cooldown_start_wt
			src.Activate(R)
			return "roared [(R.Using || R.cooldown_start_wt != stamp) ? "yes" : "no"]"
		if("Deafen the target")
			if(!t)
				return "no target"
			return "stun [t.RoarStruck(src)] s, deafened [t.DeafenedNow()]"
		if("Read the target")
			if(!t)
				return "no target"
			return "Potential [t.Potential], roar stun [RoarStunFor(t)] s, deafened [t.DeafenedNow()], stunned [t.Stunned ? 1 : 0]"
	return "unknown step"

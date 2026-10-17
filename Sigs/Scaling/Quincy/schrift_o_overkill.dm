#define QUINCY_O_KO_STEP 0.05
#define QUINCY_O_KILL_STEP 0.1

mob/var/OverkillKills = 0
mob/var/OverkillApplied = 0
mob/var/OverkillStacks = 0
mob/var/tmp/OverkillGen = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/O_The_Overkill/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/Javelin_Pfeil)

/proc/QuincyOverkillPassives()
	return list("MagnifiedStr", "MagnifiedFor", "MagnifiedSpd")

/mob/proc/OverkillShift(amount)
	if(!amount || !src.passive_handler)
		return
	for(var/p in QuincyOverkillPassives())
		if(amount > 0)
			src.passive_handler.Increase(p, amount)
		else
			src.passive_handler.Decrease(p, -amount)

/mob/proc/OverkillHolds()
	return src.QuincySchrift == "O" && SchriftNeeded("O")

/mob/proc/OverkillSync()
	var/want = OverkillHolds() ? max(0, src.OverkillKills) : 0
	var/diff = want - src.OverkillApplied
	if(!diff)
		return 0
	OverkillShift(QUINCY_O_KILL_STEP * diff)
	src.OverkillApplied = want
	return diff

/mob/proc/OverkillKillAdd(mob/victim)
	src.OverkillKills++
	OverkillSync()
	src << "<font color=#ff5a3c>The Overkill drinks [victim]'s death. [src.OverkillKills] kill[src.OverkillKills == 1 ? "" : "s"]: +[src.OverkillKills * QUINCY_O_KILL_STEP * 100] percent Strength, Force and Speed, for good.</font>"

/mob/proc/OverkillKOAdd()
	src.OverkillStacks++
	OverkillShift(QUINCY_O_KO_STEP)
	src << "<font color=#ff5a3c>The Overkill: [src.OverkillStacks] knockout[src.OverkillStacks == 1 ? "" : "s"] this fight, +[src.OverkillStacks * QUINCY_O_KO_STEP * 100] percent Strength, Force and Speed.</font>"
	OverkillWatch()

/mob/proc/OverkillKOClear(quiet = 0)
	src.OverkillGen++
	if(src.OverkillStacks <= 0)
		src.OverkillStacks = 0
		return 0
	var/n = src.OverkillStacks
	OverkillShift(-QUINCY_O_KO_STEP * n)
	src.OverkillStacks = 0
	if(!quiet)
		src << "<font color=yellow>The heat of your knockouts settles.</font>"
	return n

/mob/proc/OverkillWatch()
	set waitfor = 0
	var/gen = ++src.OverkillGen
	while(src && src.OverkillGen == gen && src.OverkillStacks > 0)
		sleep(10)
		if(!src || src.OverkillGen != gen)
			return
		if(QuincyFightIdle())
			OverkillKOClear()
			return

/mob/proc/OverkillLoginSweep()
	if(src.OverkillStacks > 0)
		OverkillKOClear(1)
	OverkillSync()

/strikeHook/quincyOverkillKO
	stage = "ko"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(d && d.OverkillStacks > 0)
			d.OverkillKOClear()
		if(!a || !d || a == d || !a.OverkillHolds() || !QuincyAreaFoe(d, a))
			return
		a.OverkillKOAdd()

/strikeHook/quincyOverkillKill
	stage = "kill"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(d && d.OverkillStacks > 0)
			d.OverkillKOClear(1)
		if(!a || !d || a == d || !istype(d, /mob/Players) || !d.key)
			return
		if(!a.OverkillHolds() || !QuincyAreaFoe(d, a))
			return
		a.OverkillKillAdd(d)

/mob/Players/CinderTollReset()
	..()
	if(src.OverkillStacks > 0)
		OverkillKOClear()

/mob/Players/Logout()
	OverkillKOClear(1)
	..()

/mob/Players/Login()
	..()
	spawn(45)
		if(src)
			OverkillLoginSweep()

/mob/Players/QuincySyncSkills()
	..()
	OverkillSync()
	if(src.OverkillStacks > 0 && !OverkillHolds())
		OverkillKOClear(1)

/mob/Players/QuincyFreeRegistry()
	..()
	OverkillKOClear(1)
	if(src.OverkillApplied)
		OverkillShift(-QUINCY_O_KILL_STEP * src.OverkillApplied)
		src.OverkillApplied = 0

/obj/Skills/Projectile/Quincy/Javelin_Pfeil
	name = "Javelin Pfeil"
	desc = "A huge arrow of Reishi that carries its target away."
	DamageMult = 1.5
	Piercing = 1
	Knockback = 10
	Speed = 0.2
	Distance = 12
	Cooldown = 10
	ManaCost = 5
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ActiveMessage = "hurls a Javelin Pfeil!"

	verb/Javelin_Pfeil()
		set name = "Javelin Pfeil"
		set category = "Skills"
		if(!usr.SchriftNeeded("O"))
			usr << "Only the bearer of The Overkill can hurl the Javelin Pfeil."
			return
		usr.UseProjectile(src)

/proc/QuincyTestStepsO()
	return list("Count a knockout", "Count a kill", "Meditate reset", "Fight end", "Show")

/mob/proc/QuincyOverkillLine()
	var/list/p = list()
	for(var/k in QuincyOverkillPassives())
		p += "[k] [src.passive_handler ? src.passive_handler.Get(k) : 0]"
	return "kills [src.OverkillKills] applied [src.OverkillApplied] knockouts [src.OverkillStacks] ([jointext(p, ", ")])"

/mob/proc/QuincyTestO(step, mob/t)
	switch(step)
		if("Count a knockout")
			if(OverkillHolds())
				OverkillKOAdd()
			return QuincyOverkillLine()
		if("Count a kill")
			if(OverkillHolds())
				OverkillKillAdd(t ? t : src)
			return QuincyOverkillLine()
		if("Meditate reset")
			CinderTollReset()
			return QuincyOverkillLine()
		if("Fight end")
			OverkillKOClear()
			return QuincyOverkillLine()
		if("Show")
			return QuincyOverkillLine()
	return "unknown step"

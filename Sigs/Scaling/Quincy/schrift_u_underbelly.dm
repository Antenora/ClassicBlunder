#define QUINCY_U_TICK 20
#define QUINCY_U_MAX 5
#define QUINCY_U_PIERCE 0.2
#define QUINCY_U_DRAIN 0.1
#define QUINCY_U_COLLAPSE 3

mob/var/tmp/mob/UnderbellyTarget
mob/var/tmp/UnderbellyStacks = 0
mob/var/tmp/UnderbellyGen = 0
mob/var/tmp/obj/Effects/Quincy_Morphine/UnderbellyGrid

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/U_The_Underbelly/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Analyze, /obj/Skills/Projectile/Quincy/Nine_Arrows)

/obj/Skills/Quincy/Analyze
	name = "Analyze"
	desc = "Read your target's Reiatsu while they stay in sight: one reading every 2 seconds, up to 5. Each reading makes your attacks on them ignore 20 percent of their defense; at 5 the Morphine Pattern opens and every hit drains a tenth of their Mana and Energy, and a target drained dry collapses. Lose sight of them, or stop, and the reading is lost."
	Copyable = 0

	verb/Analyze()
		set name = "Analyze"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(User.UnderbellyTarget)
			User.UnderbellyEnd("You stop reading [User.UnderbellyTarget]. The reading is lost.")
			return
		if(User.KO)
			return
		if(!User.SchriftNeeded("U"))
			User << "Only the bearer of The Underbelly can read Reiatsu like this."
			return
		var/mob/t = User.UnderbellyFoe()
		if(!t)
			User << "Analyze needs a target in sight."
			return
		User.UnderbellyStart(t)

/obj/Effects/Quincy_Morphine
	Lifetime = -1
	icon = 'Icons/Effects/SparkleArcane.dmi'
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	var/grid_step = 12
	var/grid_x = 0
	var/grid_y = 0

	New(loc)
		..()
		appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		pixel_x = grid_x
		pixel_y = grid_y
		for(var/gx = -1 to 1)
			for(var/gy = -1 to 1)
				if(!gx && !gy)
					continue
				overlays += image(icon, pixel_x = gx * grid_step, pixel_y = gy * grid_step)

/mob/proc/UnderbellySees(mob/t)
	if(!ismob(t) || t == src || t.z != src.z)
		return 0
	return (t in view(src.client ? src.client.view : world.view, src)) ? 1 : 0

/mob/proc/UnderbellyFoe()
	var/mob/t = src.Target
	if(!UnderbellySees(t))
		return null
	return t

/mob/proc/UnderbellyStart(mob/t)
	UnderbellyEnd(null)
	src.UnderbellyTarget = t
	src.UnderbellyStacks = 0
	src << "<font color=#9fd8ff>You begin reading [t]'s Reiatsu.</font>"
	UnderbellyLoop(t)

/mob/proc/UnderbellyLoop(mob/t)
	set waitfor = 0
	var/gen = ++src.UnderbellyGen
	while(src && src.UnderbellyGen == gen)
		sleep(QUINCY_U_TICK)
		if(!src || src.UnderbellyGen != gen)
			return
		if(!t || src.UnderbellyTarget != t || src.KO || !SchriftNeeded("U"))
			UnderbellyEnd("The reading is lost.")
			return
		if(!UnderbellySees(t))
			UnderbellyEnd("You lose sight of [t]. The reading is lost.")
			return
		if(src.UnderbellyStacks < QUINCY_U_MAX)
			UnderbellyRead(t)

/mob/proc/UnderbellyRead(mob/t)
	src.UnderbellyStacks = min(QUINCY_U_MAX, src.UnderbellyStacks + 1)
	if(src.UnderbellyStacks >= QUINCY_U_MAX)
		UnderbellyGridOn(t)
		OMsg(src, "[src] has read every hole in [t]'s Reiatsu. The Morphine Pattern opens.")
	else
		src << "<font color=#9fd8ff>Reading [t]: [src.UnderbellyStacks] of [QUINCY_U_MAX].</font>"
	return src.UnderbellyStacks

/mob/proc/UnderbellyGridOn(mob/t)
	UnderbellyGridOff()
	if(!t)
		return
	var/obj/Effects/Quincy_Morphine/g = new(null)
	t.vis_contents += g
	src.UnderbellyGrid = g

/mob/proc/UnderbellyGridOff()
	var/obj/Effects/Quincy_Morphine/g = src.UnderbellyGrid
	src.UnderbellyGrid = null
	if(!g)
		return
	var/mob/t = src.UnderbellyTarget
	if(t)
		t.vis_contents -= g
	del g

/mob/proc/UnderbellyEnd(msg)
	src.UnderbellyGen++
	var/had = src.UnderbellyTarget
	UnderbellyGridOff()
	src.UnderbellyTarget = null
	src.UnderbellyStacks = 0
	if(had && msg)
		src << "<font color=#9fd8ff>[msg]</font>"

/mob/proc/UnderbellyPierce(mob/m)
	if(!ismob(m) || m != src.UnderbellyTarget || src.UnderbellyStacks <= 0)
		return 1
	if(src.QuincySchrift != "U" || !SchriftNeeded("U"))
		return 1
	return max(0, 1 - QUINCY_U_PIERCE * src.UnderbellyStacks)

/mob/Players/MeleeEndMult(mob/enemy)
	. = ..()
	if(!src.UnderbellyTarget || enemy != src.UnderbellyTarget)
		return
	var/p = UnderbellyPierce(enemy)
	if(p >= 1)
		return
	var/q = src.AttackQueue ? src.AttackQueue.EndEffectiveness : 1
	if(q > 0)
		. *= min(1, p / q)

/mob/proc/UnderbellyDrained(mob/a)
	var/k = max(0.01, src.EnergyExpenditure * src.Power_Multiplier)
	if(src.ManaAmount > 0)
		src.LoseMana(QUINCY_U_DRAIN * src.ManaCap() / k)
	if(src.Energy > 0)
		src.LoseEnergy(QUINCY_U_DRAIN * src.EnergyMax, TRUE)
	if(src.ManaAmount <= 0 && src.Energy <= 0 && !src.KO)
		OMsg(src, "[src] collapses, their Reiatsu spent.")
		Stun(src, QUINCY_U_COLLAPSE)
		return 1
	return 0

/strikeHook/quincyUnderbellyDrain
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		if(d != a.UnderbellyTarget || a.UnderbellyStacks < QUINCY_U_MAX || !a.SchriftNeeded("U"))
			return
		d.UnderbellyDrained(a)

/mob/Players/QuincySyncSkills()
	..()
	if(src.UnderbellyTarget && !SchriftNeeded("U"))
		UnderbellyEnd(null)

/obj/Skills/Projectile/Quincy/Nine_Arrows
	name = "Nine Arrows"
	desc = "Draw the three-ring bow and loose nine arrows, one after another."
	Blasts = 9
	Delay = 1
	DamageMult = 0.3
	Cooldown = 20
	ManaCost = 6
	Distance = 12
	Speed = 0.3
	Variation = 0
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	ActiveMessage = "draws the three-ring bow and looses nine arrows!"

	verb/Nine_Arrows()
		set name = "Nine Arrows"
		set category = "Skills"
		if(!usr.SchriftNeeded("U"))
			usr << "Only the bearer of The Underbelly can draw the three-ring bow."
			return
		usr.UseProjectile(src)

/proc/QuincyTestStepsU()
	return list("Five readings", "Read the holes", "Drain once", "End the reading")

/mob/proc/QuincyTestU(step, mob/t)
	switch(step)
		if("Five readings")
			if(!t)
				return "no target"
			if(src.UnderbellyTarget != t)
				UnderbellyStart(t)
			while(src.UnderbellyStacks < QUINCY_U_MAX)
				UnderbellyRead(t)
			return "stacks [src.UnderbellyStacks] on [t], grid [src.UnderbellyGrid ? 1 : 0]"
		if("Read the holes")
			if(!t)
				return "no target"
			return "stacks [t == src.UnderbellyTarget ? src.UnderbellyStacks : 0], defense counted [round(UnderbellyPierce(t) * 100)] percent"
		if("Drain once")
			if(!t)
				return "no target"
			var/collapsed = t.UnderbellyDrained(src)
			return "Mana [round(t.ManaAmount, 0.1)], Energy [round(t.Energy, 0.1)], collapsed [collapsed]"
		if("End the reading")
			UnderbellyEnd("The reading is lost.")
			return "reading ended"
	return "unknown step"

#define QUINCY_JAIL_TIME 80
#define QUINCY_JAIL_BREAK_PCT 30
#define QUINCY_GATE_RANGE 5
#define QUINCY_GATE_NAG 10
#define QUINCY_PISKIEL_HEAL 2
#define QUINCY_PISKIEL_DRAIN 2
#define QUINCY_PISKIEL_TICK 20
#define QUINCY_PISKIEL_MANA 2

mob/var/tmp/mob/JailedBy
mob/var/tmp/JailedUntil = 0
mob/var/tmp/JailSerial = 0
mob/var/tmp/obj/Effects/Quincy_Jail_Cage/JailCage
mob/var/tmp/JailNagAt = 0
mob/var/tmp/GateNagAt = 0
mob/var/tmp/PiskielGen = 0

var/list/QuincyGateSealers = list()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/J_The_Jail/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Jail)

/obj/Effects/Quincy_Jail_Cage
	name = "Jail"
	icon = 'Icons/Effects/SparkleArcane.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	density = 0
	var/spark_icon = 'Icons/Effects/KenShockwave.dmi'
	var/spark_size = 0.5

	New(loc)
		..()
		appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/proc/QuincyJailSeals(mob/a, mob/d)
	if(!ismob(a) || !ismob(d) || a == d)
		return 0
	if(d.JailedUntil > world.time && d.JailedBy != a)
		return 1
	if(a.JailedUntil > world.time && a.JailedBy != d)
		return 1
	return 0

/proc/QuincyJailWatch(mob/t, until, serial, obj/Effects/Quincy_Jail_Cage/c)
	set waitfor = 0
	sleep(max(1, until - world.time))
	if(t)
		if(t.JailSerial == serial)
			t.JailRelease()
	else if(c)
		del c

/proc/QuincyJailBars(obj/Skills/Projectile/_Projectile/P, mob/m)
	if(m)
		var/obj/Effects/Quincy_Jail_Cage/C = /obj/Effects/Quincy_Jail_Cage
		KenShockwave(m, icon = initial(C.spark_icon), Size = initial(C.spark_size), Blend = 2, Time = 4)
	if(P.Area == "Beam")
		P.Distance = 0
		P.endLife()
	else
		P.Killed = 1
		P.ProjectileFinish()

/mob/proc/JailHolds()
	return src.QuincySchrift == "J" && SchriftNeeded("J")

/mob/proc/JailHidesFrom(mob/seeker)
	return src.JailedUntil > world.time && seeker != src.JailedBy && seeker != src

/mob/proc/JailPut(mob/t, ds)
	if(!ismob(t) || t == src)
		return 0
	t.JailRelease(null, 1)
	t.JailedBy = src
	t.JailedUntil = world.time + ds
	var/serial = ++t.JailSerial
	t.applySnare(ds / 10, null, 1)
	var/cc = t.cc_immune_until
	var/lockImmune = t.NamekTargetLockImmuneUntil
	t.cc_immune_until = 0
	t.NamekTargetLockImmuneUntil = 0
	t.NamekTargetLock(src, ds / 10)
	t.cc_immune_until = cc
	t.NamekTargetLockImmuneUntil = max(lockImmune, t.NamekTargetLockImmuneUntil)
	var/list/bt = t.BeingTargetted
	if(islist(bt))
		for(var/mob/m in bt.Copy())
			if(m != src && m != t && m.Target == t)
				m.RemoveTarget()
				m << "You cannot find [t]."
	var/turf/T = get_turf(t)
	if(T)
		var/obj/Effects/Quincy_Jail_Cage/c = new(T)
		c.step_x = t.step_x
		c.step_y = t.step_y
		t.JailCage = c
	OMsg(src, "[src] cages [t]! Nothing reaches them now but [src].")
	QuincyJailWatch(t, t.JailedUntil, serial, t.JailCage)
	return 1

/mob/proc/JailRelease(msg, quiet = 0)
	var/mob/by = src.JailedBy
	var/was = src.JailedUntil
	src.JailedBy = null
	src.JailedUntil = 0
	src.JailSerial++
	if(src.JailCage)
		var/obj/Effects/Quincy_Jail_Cage/c = src.JailCage
		src.JailCage = null
		del c
	if(!was)
		return 0
	if(by && src.NamekTargetLockTo == by)
		src.NamekTargetLockTo = null
		src.NamekTargetLockUntil = 0
		var/obj/Skills/Buffs/L = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Target_Lock) in src
		if(L && src.BuffOn(L))
			L.Trigger(src, 1)
	var/obj/Skills/Buffs/S = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare) in src
	if(S && src.BuffOn(S))
		S.Trigger(src, 1)
	if(!quiet)
		OMsg(src, msg ? msg : "The cage around [src] dissolves.")
	return 1

/mob/proc/JailNag(mob/t)
	if(src.JailNagAt > world.time)
		return
	src.JailNagAt = world.time + QUINCY_GATE_NAG
	src << "You cannot find them."

/mob/proc/GateSealSync()
	if(JailHolds())
		QuincyGateSealers |= src
	else
		QuincyGateSealers -= src

/proc/QuincyGateSealer(mob/u, atom/dest)
	for(var/mob/h in QuincyGateSealers)
		if(h == u || h.QuincySchrift != "J")
			continue
		if(u && u.z == h.z && get_dist(u, h) <= QUINCY_GATE_RANGE)
			return h
		if(dest && dest.z == h.z && get_dist(dest, h) <= QUINCY_GATE_RANGE)
			return h
	return null

/mob/proc/GateRefuses(atom/dest)
	if(!QuincyGateSealers.len)
		return 0
	var/mob/h = QuincyGateSealer(src, dest)
	if(!h || !h.JailHolds())
		return 0
	if(src.GateNagAt <= world.time)
		src.GateNagAt = world.time + QUINCY_GATE_NAG
		src << "The gateway is closed."
	return 1

/mob/proc/PiskielOn()
	return src.QuincySchrift == "J" && QuincyVollstandigOnNow() && SchriftNeeded("J")

/mob/proc/PiskielDrink(mob/o)
	if(!PiskielOn())
		return 0
	HealPct(QUINCY_PISKIEL_HEAL)
	MaxHealth()
	if(ismob(o) && o != src && o.ManaAmount > 0)
		var/before = o.ManaAmount
		o.LoseMana(QUINCY_PISKIEL_DRAIN)
		var/got = max(0, before - o.ManaAmount)
		if(got)
			QuincyVollstandigGainMana(got)
	return 1

/mob/proc/PiskielLoop()
	set waitfor = 0
	var/gen = ++src.PiskielGen
	while(src && src.PiskielGen == gen)
		sleep(QUINCY_PISKIEL_TICK)
		if(!src || src.PiskielGen != gen || !PiskielOn())
			return
		if(!src.HaloBroken)
			QuincyVollstandigGainMana(QUINCY_PISKIEL_MANA)

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig) && src.QuincySchrift == "J")
		PiskielLoop()

/mob/Players/SetTarget(atom/target)
	if(ismob(target))
		var/mob/m = target
		if(m.JailHidesFrom(src))
			JailNag(m)
			return
	return ..()

/mob/Player/AI/SetTarget(atom/target)
	if(ismob(target))
		var/mob/m = target
		if(m.JailHidesFrom(src))
			return
	return ..()

/mob/Players/SkillX(var/Wut,var/obj/Skills/Z,var/bypass=0,var/noGCD=0,var/TempoBypass=FALSE)
	if(Wut == "Zanzoken" && GateRefuses(ismob(src.Target) ? src.Target : null))
		return FALSE
	return ..()

/mob/Player/AI/SkillX(var/Wut,var/obj/Skills/Z,var/bypass=0,var/noGCD=0,var/TempoBypass=FALSE)
	if(Wut == "Zanzoken" && GateRefuses(ismob(src.Target) ? src.Target : null))
		return FALSE
	return ..()

/mob/proc/JailBarsCatch(obj/Skills/Projectile/_Projectile/P)
	if(!P || src.JailedUntil <= world.time)
		return 0
	var/mob/o = P.Owner
	if(o == src.JailedBy || o == src)
		return 0
	QuincyJailBars(P, src)
	return 1

/mob/Players/GunIntercept(obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(!. && JailBarsCatch(P))
		return 1

/mob/Player/AI/GunIntercept(obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(!. && JailBarsCatch(P))
		return 1

/mob/getEnemies(forcehit = null)
	var/list/L = ..()
	if(!islist(L) || !L.len)
		return L
	for(var/mob/m in L.Copy())
		if(QuincyJailSeals(src, m))
			L -= m
	return L

/mob/QuincyDamageTakenMult(skilltype)
	. = ..()
	if(. && QuincyJailSeals(src.last_struck_by, src))
		. = 0

/mob/Players/QuincySyncSkills()
	..()
	GateSealSync()

/mob/Players/Login()
	..()
	spawn(40)
		if(src)
			GateSealSync()

/mob/Players/Logout()
	QuincyGateSealers -= src
	..()

/strikeHook/quincyJailBreak
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		if(a.JailedUntil <= world.time || a.JailedBy != d)
			return
		if(a.HPToPct(S.dealt) <= QUINCY_JAIL_BREAK_PCT)
			return
		a.JailRelease("The cage shatters!")

/obj/Skills/Quincy/Jail
	name = "Jail"
	desc = "Cage your target for 8 seconds. They cannot move, nobody else can find or reach them, shots stop at the bars, and their attacks reach only you. A single hit on you above 30 percent of their own health shatters it. A Quincy walks out of any cage."
	Cooldown = 30
	ManaCost = 8
	Copyable = 0
	var/seconds = QUINCY_JAIL_TIME

	verb/Jail()
		set name = "Jail"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		JailFire(User)

	proc/JailCost(mob/User)
		if(User.HasDrainlessMana())
			return 0
		var/c = src.ManaCost * User.ChakraCostMult(src) * User.SpellCostMult(src)
		if(c <= 0)
			c = 0.5
		return c

	proc/JailFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.JailHolds())
			User << "Only the bearer of The Jail can build a cage."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.XAxisTarget()
		if(!t || !(t in view(User.QuincyViewReach(), User)))
			User << "You need a target in view."
			return 0
		if(t.QuincyIsQuincy())
			User << "Only a Quincy walks out of a cage."
			return 0
		if(t.KO)
			User << "[t] is in no state to be caged."
			return 0
		if(t.JailedUntil > world.time)
			User << "[t] is already caged."
			return 0
		var/cost = JailCost(User)
		if(cost && User.ManaAmount < cost)
			User << "You don't have enough mana to use [src]."
			return 0
		if(cost)
			User.LoseMana(cost)
		if(!User.JailPut(t, src.seconds))
			return 0
		src.Cooldown(1, null, User)
		return 1

/proc/QuincyTestStepsJ()
	return list("Jail target", "Release target", "Gate Seal here", "Piskiel drink")

/mob/proc/QuincyTestJ(step, mob/t)
	switch(step)
		if("Jail target")
			if(!t)
				return "no target"
			return "jailed [JailPut(t, QUINCY_JAIL_TIME)] until [t.JailedUntil]"
		if("Release target")
			if(!t)
				return "no target"
			return "released [t.JailRelease()]"
		if("Gate Seal here")
			GateSealSync()
			var/mob/h = QuincyGateSealer(src, null)
			return "sealers [QuincyGateSealers.len], sealing you: [h ? h : "nobody"]"
		if("Piskiel drink")
			return "drank [PiskielDrink(t)]"
	return "unknown step"

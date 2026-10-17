#define QUINCY_G_BITE_PCT 15
#define QUINCY_G_HEAL_PCT 15
#define QUINCY_G_WINDUP 20
#define QUINCY_G_FED_FOR 600
#define QUINCY_G_HUNGER_MANA 1
#define QUINCY_G_HUNGER_NAG 300
#define QUINCY_G_TASTE_KEEP 100
#define QUINCY_G_TASTE_QUEUE_MAX 500
#define QUINCY_G_TRAP_TIME 100
#define QUINCY_G_TRAP_SNARE 3

mob/var/tmp/GluttonFedAt = 0
mob/var/tmp/GluttonHungerGen = 0
mob/var/tmp/GluttonNagAt = 0
mob/var/tmp/GluttonBiting = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/G_The_Glutton/New()
	..()
	kit_skills = list(/obj/Skills/Grapple/Quincy/Devour, /obj/Skills/Projectile/Quincy/Spork, /obj/Skills/AutoHit/Quincy/Spife, /obj/Skills/AutoHit/Quincy/Golden_Crunch)

/mob/proc/GluttonHungerLoop(obj/Skills/Buffs/B)
	set waitfor = 0
	var/gen = ++src.GluttonHungerGen
	while(src && B && B.SlotlessOn && B.loc == src && src.GluttonHungerGen == gen)
		sleep(10)
		if(!src || !B || !B.SlotlessOn || B.loc != src || src.GluttonHungerGen != gen)
			return
		if(src.KO || QuincyFightIdle())
			continue
		if(src.GluttonFedAt && world.time - src.GluttonFedAt < QUINCY_G_FED_FOR)
			continue
		src.LoseMana(QUINCY_G_HUNGER_MANA)
		if(src.GluttonNagAt <= world.time)
			src.GluttonNagAt = world.time + QUINCY_G_HUNGER_NAG
			src << "<font color=#e0b050>You are hungry.</font>"

/mob/proc/GluttonFeed(mob/t)
	src.GluttonFedAt = world.time
	src.GluttonNagAt = 0
	src.QuincyFightAt = world.time
	if(t)
		t.QuincyFightAt = world.time

/proc/GluttonVarSet(datum/d, v, val)
	if(d && (v in d.vars))
		d.vars[v] = val

/proc/GluttonVarGet(datum/d, v)
	if(d && (v in d.vars))
		return d.vars[v]
	return null

/proc/GluttonTasteable(T)
	if(!ispath(T, /obj/Skills))
		return 0
	if(ispath(T, /obj/Skills/Projectile/Gunfire) || ispath(T, /obj/Skills/Grapple) || ispath(T, /obj/Skills/Projectile/Beams))
		return 0
	if(!ispath(T, /obj/Skills/AutoHit) && !ispath(T, /obj/Skills/Projectile) && !ispath(T, /obj/Skills/Queue))
		return 0
	var/obj/Skills/S = T
	if(initial(S.HeldSkill))
		return 0
	if(ispath(T, /obj/Skills/AutoHit))
		var/obj/Skills/AutoHit/A = T
		if(initial(A.Grapple) || initial(A.IsSnowgrave) || initial(A.HahaWhoops) || initial(A.AwakeningSkill))
			return 0
		if(ispath(T, /obj/Skills/AutoHit/I_Want_To_Be_Like_You))
			return 0
	return 1

/mob/proc/GluttonFreeSkill(obj/Skills/S)
	S.Copied = TRUE
	S.copiedBy = "The Glutton"
	S.Cooldown = -1
	S.Using = 0
	for(var/v in list("ManaCost", "EnergyCost", "FatigueCost", "HealthCost", "WoundCost", "ManaCostAll", "CorruptionCost", "CapacityCost", "NeedsHealth", "GateNeeded", "RequiresWill"))
		GluttonVarSet(S, v, 0)
	for(var/v in list("ResourceCost", "ABuffNeeded", "SBuffNeeded", "StanceNeeded", "StyleNeeded", "ClassNeeded"))
		GluttonVarSet(S, v, null)
	if(GluttonVarGet(S, "NeedsSword") && !src.EquippedSword() && !src.HasBladeFisting() && !src.UsingBattleMage())
		GluttonVarSet(S, "NeedsSword", 0)
	if(GluttonVarGet(S, "UnarmedOnly") && (src.UsingBattleMage() || (src.EquippedSword() && !src.HasBladeFisting())))
		GluttonVarSet(S, "UnarmedOnly", 0)
	if(GluttonVarGet(S, "NeedsGun") && !src.EquippedGun())
		GluttonVarSet(S, "NeedsGun", 0)
	if(GluttonVarGet(S, "NoGun") && src.EquippedGun())
		GluttonVarSet(S, "NoGun", 0)
	if(GluttonVarGet(S, "MagicNeeded") && !src.HasLimitlessMagic() && (src.HasMechanized() || src.HasMagicTaken() || !src.HasSpellFocus(S)))
		GluttonVarSet(S, "MagicNeeded", 0)

/mob/proc/GluttonTaste(mob/t)
	var/list/types = QuincyLastSkillTypes(t)
	for(var/T in types)
		if(!GluttonTasteable(T))
			continue
		var/obj/Skills/S = new T
		GluttonFreeSkill(S)
		GluttonGrantTaste(S)
		src << "<font color=#e0b050>You taste [S.name]. You can use it once, before the fight ends.</font>"
		return S
	src << "<font color=#e0b050>[t] tastes of nothing you can use.</font>"
	return null

/mob/proc/GluttonGrantTaste(obj/Skills/S)
	var/obj/Skills/Quincy/Glutton_Taste/h = locate() in src
	if(h)
		var/obj/Skills/old = h.tasted
		h.tasted = null
		if(old)
			del old
	else
		h = new
		src.AddSkill(h)
	h.tasted = S
	h.name = "Taste: [S.name]"
	h.TasteWatch(src)
	return h

/mob/proc/GluttonTasteDrop(obj/Skills/Quincy/Glutton_Taste/h)
	if(!h)
		return
	var/obj/Skills/old = h.tasted
	h.tasted = null
	h.watch_gen++
	if(old)
		del old
	src.DeleteSkill(h)

/mob/proc/GluttonTasteDropAll()
	for(var/obj/Skills/Quincy/Glutton_Taste/h in src)
		GluttonTasteDrop(h)

/mob/proc/GluttonTasteUse(obj/Skills/Quincy/Glutton_Taste/h)
	if(!h)
		return 0
	var/obj/Skills/S = h.tasted
	if(!S)
		GluttonTasteDrop(h)
		return 0
	if(src.KO)
		return 0
	S.Using = 0
	var/queued = 0
	if(istype(S, /obj/Skills/AutoHit))
		src.Activate(S, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE, noAdjust = TRUE)
	else if(istype(S, /obj/Skills/Projectile))
		src.UseProjectile(S, noGCD = TRUE)
	else if(istype(S, /obj/Skills/Queue))
		src.SetQueue(S, noGCD = TRUE)
		queued = src.AttackQueue == S
	if(!S || !h || h.tasted != S)
		return 0
	if(!S.Using && !queued)
		return 0
	h.tasted = null
	h.watch_gen++
	GluttonTasteSpent(S)
	src.DeleteSkill(h)
	return 1

/mob/proc/GluttonTasteSpent(obj/Skills/S)
	set waitfor = 0
	sleep(QUINCY_G_TASTE_KEEP)
	var/waited = 0
	while(src && S && src.AttackQueue == S && waited < QUINCY_G_TASTE_QUEUE_MAX)
		sleep(10)
		waited += 10
	if(S)
		del S

/mob/Players/attackModifiers(mob/defender, list/forcedDmgList=list())
	. = ..()
	if(ismob(defender) && HollowIsHollow() && defender.SchriftNeeded("G"))
		. -= QUINCY_HOLLOW_MOD / 2

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/G_The_Glutton))
		GluttonHungerLoop(B)

/mob/Players/Login()
	..()
	spawn(40)
		if(src)
			GluttonTasteDropAll()
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/G_The_Glutton/G = locate() in src
			if(G && G.SlotlessOn)
				GluttonHungerLoop(G)

/mob/Players/QuincySyncSkills()
	..()
	if(!SchriftNeeded("G"))
		src.GluttonHungerGen++
		GluttonTasteDropAll()

/mob/Players/QuincyFreeRegistry()
	..()
	src.GluttonHungerGen++
	GluttonTasteDropAll()

/obj/Skills/Quincy/Glutton_Taste
	name = "Taste"
	desc = "A skill you tasted with Devour. It works once, and the taste fades when the fight ends."
	Cooldown = 0
	Copyable = 0
	var/tmp/obj/Skills/tasted
	var/tmp/watch_gen = 0

	verb/Tasted_Skill()
		set name = "Tasted Skill"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		User.GluttonTasteUse(src)

	proc/TasteWatch(mob/User)
		set waitfor = 0
		var/gen = ++src.watch_gen
		while(src && User && src.loc == User && src.watch_gen == gen && src.tasted)
			sleep(10)
			if(!src || !User || src.watch_gen != gen || !src.tasted)
				return
			if(User.QuincyFightIdle())
				User << "<font color=#e0b050>The taste of [src.tasted] fades.</font>"
				User.GluttonTasteDrop(src)
				return

/obj/Skills/Grapple/Quincy/Devour
	name = "Devour"
	desc = "A 2 second bite on an adjacent target: they lose 15 percent of their health, you heal 15 percent and you are fed for a minute, and you taste one of their last skills to use once. Being suspended, stunned, launched or knocked back breaks the bite."
	UnarmedOnly = 0
	NeedsSword = 0
	DamageMult = 0
	MultiHit = 1
	ThrowMult = 0
	ThrowAdd = 0
	TriggerMessage = "sinks the maw into"
	Effect = "Strike"
	EffectMult = 1
	Cooldown = 20
	ManaCost = 5
	Copyable = 0
	var/windup = QUINCY_G_WINDUP
	var/bite_pct = QUINCY_G_BITE_PCT
	var/heal_pct = QUINCY_G_HEAL_PCT

	verb/Devour()
		set name = "Devour"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		DevourStart(User)

	proc/DevourTarget(mob/User)
		var/mob/t = User.XAxisTarget()
		if(!t || t.Dead || get_dist(User, t) > 1)
			return null
		return t

	proc/DevourBroken(mob/User)
		return User.KO || User.Suspended || User.Knockbacked || User.Launched || User.Stunned || User.Stasis > 0

	proc/DevourStart(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("G"))
			User << "Only the bearer of The Glutton has the maw."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		if(User.GluttonBiting)
			return 0
		var/mob/t = DevourTarget(User)
		if(!t)
			User << "Devour needs a target right beside you."
			return 0
		if(User.Grab && User.Grab != t)
			User << "Your hands are full."
			return 0
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You need [src.ManaCost] Mana to Devour."
			return 0
		User.GluttonBiting = 1
		OMsg(User, "[User]'s maw opens wide over [t]...")
		var/broke = 0
		for(var/i = 1 to src.windup)
			sleep(1)
			if(!User || DevourBroken(User))
				broke = 1
				break
		if(!User)
			return 0
		User.GluttonBiting = 0
		if(broke)
			OMsg(User, "[User]'s bite is broken!")
			src.Cooldown(1, null, User)
			return 0
		if(!t || DevourTarget(User) != t)
			User << "The maw closes on air."
			src.Cooldown(1, null, User)
			return 0
		return DevourBite(User, t)

	proc/DevourBite(mob/User, mob/t)
		User.Grab_Mob(t, Forced = 1)
		if(User.Grab != t)
			User << "[t] slips out of your jaws."
			src.Cooldown(1, null, User)
			return 0
		var/stamp = src.cooldown_start_wt
		src.Activate(User, noGCD = TRUE)
		if(!User)
			return 0
		if(User.Grab == t)
			User.Grab_Release()
		if(src.cooldown_start_wt == stamp)
			return 0
		if(src.ManaCost)
			User.LoseMana(src.ManaCost)
		User.GluttonFeed(t)
		if(t)
			t.DamageSelf(src.bite_pct)
		User.HealPct(src.heal_pct)
		User.MaxHealth()
		if(t)
			OMsg(User, "[User] tears a mouthful of Reishi out of [t]!")
			User.GluttonTaste(t)
		return 1

/obj/Skills/Projectile/Quincy/Spork
	name = "Spork"
	desc = "In Gagael only: hurl a bracelet that becomes a bear trap where it lands. The first foe to step on it within 10 seconds is snared."
	DamageMult = 0.6
	Distance = 8
	Speed = 0.3
	Cooldown = 20
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	ActiveMessage = "hurls the Spork!"
	var/trap_time = QUINCY_G_TRAP_TIME
	var/trap_snare = QUINCY_G_TRAP_SNARE

	verb/Spork()
		set name = "Spork"
		set category = "Skills"
		if(!usr.SchriftNeeded("G"))
			usr << "Only the bearer of The Glutton can throw this."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "The Spork answers only in Gagael."
			return
		usr.UseProjectile(src)

/obj/Effects/Quincy_Trap
	name = "Spork"
	icon = 'Icons/Effects/SparkleArcane.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	density = 0
	var/tmp/mob/trap_owner
	var/trap_snare = QUINCY_G_TRAP_SNARE

	proc/TrapWatch(ds)
		set waitfor = 0
		var/until = world.time + ds
		while(src && src.loc && world.time < until)
			for(var/mob/m in src.loc)
				if(!m.KO && QuincyAreaFoe(m, src.trap_owner))
					m.applySnare(src.trap_snare)
					OMsg(m, "A Spork snaps shut on [m]!")
					del src
					return
			sleep(2)
		if(src)
			del src

/mob/proc/GluttonTrapPlant(turf/t, obj/Skills/Projectile/Quincy/Spork/S)
	if(!isturf(t))
		return null
	var/obj/Effects/Quincy_Trap/q = new(t)
	q.trap_owner = src
	q.trap_snare = S ? S.trap_snare : QUINCY_G_TRAP_SNARE
	q.TrapWatch(S ? S.trap_time : QUINCY_G_TRAP_TIME)
	return q

/obj/Skills/AutoHit/Quincy/Spife
	name = "Spife"
	desc = "In Gagael only: a bladed whip lashes a straight line 3 tiles long."
	Area = "Strike"
	Distance = 3
	DamageMult = 1.3
	Cooldown = 25
	Copyable = 0
	ActiveMessage = "lashes out with the Spife!"

	verb/Spife()
		set name = "Spife"
		set category = "Skills"
		if(!usr.SchriftNeeded("G"))
			usr << "Only the bearer of The Glutton can lash the Spife."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "The Spife answers only in Gagael."
			return
		usr.Activate(src)

/obj/Skills/AutoHit/Quincy/Golden_Crunch
	name = "Golden Crunch"
	desc = "In Gagael only: the ground around you closes like a jaw on everyone within 2 tiles and snares them."
	Area = "Circle"
	Distance = 2
	DamageMult = 1.5
	Snaring = 3
	Cooldown = 30
	Copyable = 0
	Icon = 'Icons/Effects/SparkleArcane.dmi'
	ActiveMessage = "brings down the Golden Crunch!"

	verb/Golden_Crunch()
		set name = "Golden Crunch"
		set category = "Skills"
		if(!usr.SchriftNeeded("G"))
			usr << "Only the bearer of The Glutton can close the Golden Crunch."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "The Golden Crunch answers only in Gagael."
			return
		usr.Activate(src)

/proc/QuincyTestStepsG()
	return list("Devour target now", "Taste target", "Starve", "Feed", "Plant a Spork trap here")

/mob/proc/QuincyTestG(step, mob/t)
	switch(step)
		if("Devour target now")
			if(!t)
				return "no target"
			var/obj/Skills/Grapple/Quincy/Devour/D = locate() in src
			if(!D)
				D = new
			if(get_dist(src, t) > 1)
				t.loc = get_step(src, src.dir)
			return "bitten [D.DevourBite(src, t)]"
		if("Taste target")
			if(!t)
				return "no target"
			var/obj/Skills/S = GluttonTaste(t)
			return S ? "tasted [S.name]" : "nothing"
		if("Starve")
			src.GluttonFedAt = 0
			src.GluttonNagAt = 0
			src.QuincyFightAt = world.time
			return "hungry"
		if("Feed")
			GluttonFeed(null)
			return "fed"
		if("Plant a Spork trap here")
			return "trap [GluttonTrapPlant(get_step(src, src.dir), null)]"
	return "unknown step"

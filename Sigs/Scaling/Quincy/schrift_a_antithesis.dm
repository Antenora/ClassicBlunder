#define QUINCY_A_LEDGER_TIME 80
#define QUINCY_A_STAMP 600
#define QUINCY_A_FUTURE_TIME 200
#define QUINCY_A_CAGE_TIME 80
#define QUINCY_A_CAGE_SNARE 8

mob/var/tmp/list/AntithesisLedger
mob/var/tmp/AntithesisAt = 0
mob/var/tmp/AntithesisFutureArmed = 0
mob/var/tmp/FederzwingerUntil = 0
mob/var/tmp/FederzwingerGen = 0
mob/var/tmp/obj/Effects/Quincy_Federzwinger/FederzwingerCage

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/A_Antithesis/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Reverse_Wounds, /obj/Skills/Quincy/Reverse_Places, /obj/Skills/Quincy/Reverse_Afflictions, /obj/Skills/Quincy/Reverse_the_Future, /obj/Skills/Quincy/Federzwinger)

/proc/AntithesisTrim(list/L)
	var/list/keep = list()
	if(!islist(L))
		return keep
	for(var/list/e in L)
		if(world.time - e[1] <= QUINCY_A_LEDGER_TIME)
			keep += list(e)
	return keep

/proc/AntithesisAfflictionVars()
	return list("Bleed", "Burn", "Poison", "Shock", "Slow", "SilentBurnAmount", "SilentPoisonAmount")

/mob/proc/AntithesisNote(mob/other, amt, dealt)
	if(!ismob(other) || other == src || amt <= 0)
		return
	var/list/fresh = list()
	if(src.AntithesisLedger)
		for(var/k in src.AntithesisLedger)
			if(!ismob(k) || k == other)
				continue
			var/list/t = AntithesisTrim(src.AntithesisLedger[k])
			if(t.len)
				fresh[k] = t
	var/list/mine = src.AntithesisLedger ? AntithesisTrim(src.AntithesisLedger[other]) : list()
	mine += list(list(world.time, amt, dealt ? 1 : 0))
	fresh[other] = mine
	src.AntithesisLedger = fresh

/mob/proc/AntithesisSums(mob/other)
	var/list/out = list(0, 0)
	if(!src.AntithesisLedger || !ismob(other))
		return out
	var/list/L = AntithesisTrim(src.AntithesisLedger[other])
	if(!L.len)
		src.AntithesisLedger -= other
		return out
	src.AntithesisLedger[other] = L
	for(var/list/e in L)
		if(e[3])
			out[2] += e[2]
		else
			out[1] += e[2]
	return out

/mob/proc/AntithesisLeft()
	if(!src.AntithesisAt)
		return 0
	return max(0, src.AntithesisAt + QUINCY_A_STAMP - world.time)

/mob/proc/AntithesisCooldowns()
	for(var/T in list(/obj/Skills/Quincy/Reverse_Wounds, /obj/Skills/Quincy/Reverse_Places, /obj/Skills/Quincy/Reverse_Afflictions))
		var/obj/Skills/S = QuincyOwnedSkill(T)
		if(S && !S.Using)
			S.Cooldown(1, null, src)

/mob/proc/AntithesisReverse(kind)
	if(src.KO)
		return 0
	if(!SchriftNeeded("A"))
		src << "Only the bearer of Antithesis can reverse what has happened."
		return 0
	var/left = AntithesisLeft()
	if(left > 0)
		src << "Antithesis turns again in [round(left / 10) + 1] seconds."
		return 0
	var/mob/t = XAxisTarget()
	if(!t)
		src << "You need a target."
		return 0
	var/list/sums = AntithesisSums(t)
	if(sums[1] <= 0 && sums[2] <= 0)
		src << "Nothing has happened between you yet."
		return 0
	var/done = 0
	switch(kind)
		if("Wounds")
			done = AntithesisReverseWounds(t, sums[1], sums[2])
		if("Places")
			done = AntithesisReversePlaces(t)
		if("Afflictions")
			done = AntithesisReverseAfflictions(t)
	if(!done)
		return 0
	src.AntithesisAt = world.time
	AntithesisCooldowns()
	return 1

/mob/proc/AntithesisReverseWounds(mob/t, d1, d2)
	if(d1 > 0)
		HealHealth(HPToPct(d1))
		t.WoundSelf(t.HPToPct(d1))
	if(d2 > 0)
		t.HealHealth(t.HPToPct(d2))
		WoundSelf(HPToPct(d2))
	OMsg(src, "[src] reverses the wounds between them and [t]!")
	src << "<font color=#9fd8ff>You take back [round(d1)] and hand over [round(d2)].</font>"
	t << "<font color=#9fd8ff>[src] turns the last exchange inside out.</font>"
	return 1

/mob/proc/AntithesisReversePlaces(mob/t)
	var/turf/a = src.loc
	var/turf/b = t.loc
	if(!isturf(a) || !isturf(b) || a.z != b.z)
		src << "Your places cannot be reversed from here."
		return 0
	if(a.density || b.density)
		src << "Something solid stands where one of you would land."
		return 0
	var/ax = src.step_x
	var/ay = src.step_y
	var/bx = t.step_x
	var/by = t.step_y
	VanishImage(src)
	VanishImage(t)
	src.loc = b
	src.step_x = bx
	src.step_y = by
	t.loc = a
	t.step_x = ax
	t.step_y = ay
	ShadowPrewarm(src)
	ShadowPrewarm(t)
	OMsg(src, "[src] and [t] trade places in the blink of an eye!")
	return 1

/mob/proc/AntithesisReverseAfflictions(mob/t)
	var/any = 0
	for(var/v in AntithesisAfflictionVars())
		if(src.vars[v] || t.vars[v])
			any = 1
			break
	if(!any)
		src << "Neither of you carries an affliction."
		return 0
	for(var/v in AntithesisAfflictionVars())
		var/mine = src.vars[v]
		src.vars[v] = t.vars[v]
		t.vars[v] = mine
	OMsg(src, "[src] hands their afflictions to [t] and takes theirs in return!")
	return 1

/strikeHook/quincyAntithesisLedger
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		if(a.QuincySchrift == "A")
			a.AntithesisNote(d, S.dealt, 1)
		if(d.QuincySchrift == "A")
			d.AntithesisNote(a, S.dealt, 0)

/obj/Skills/Quincy/Reverse_Wounds
	name = "Reverse Wounds"
	desc = "Swap the damage exchanged with your target in the last 8 seconds: you heal what they dealt and it wounds them, they heal what you dealt and it wounds you. Shares one 60 second turn with the other Reverses."
	Cooldown = 60
	CooldownStatic = 1
	Copyable = 0

	verb/Reverse_Wounds()
		set name = "Reverse Wounds"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		User.AntithesisReverse("Wounds")

/obj/Skills/Quincy/Reverse_Places
	name = "Reverse Places"
	desc = "Trade places with your target, once something has happened between you. Shares one 60 second turn with the other Reverses."
	Cooldown = 60
	CooldownStatic = 1
	Copyable = 0

	verb/Reverse_Places()
		set name = "Reverse Places"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		User.AntithesisReverse("Places")

/obj/Skills/Quincy/Reverse_Afflictions
	name = "Reverse Afflictions"
	desc = "Trade your Bleed, Burn, Poison, Shock and Chill with your target's, once something has happened between you. Shares one 60 second turn with the other Reverses."
	Cooldown = 60
	CooldownStatic = 1
	Copyable = 0

	verb/Reverse_Afflictions()
		set name = "Reverse Afflictions"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		User.AntithesisReverse("Afflictions")

/obj/Skills/Quincy/Reverse_the_Future
	name = "Reverse the Future"
	desc = "In Vollstandig only: for 20 seconds, the next time the Kaiser would rewrite the future against you, it swaps back."
	Cooldown = 60
	Copyable = 0
	var/seconds = QUINCY_A_FUTURE_TIME

	verb/Reverse_the_Future()
		set name = "Reverse the Future"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		FutureFire(User)

	proc/FutureFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("A"))
			User << "Only the bearer of Antithesis can reverse the future."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "The future turns only in Vollstandig."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		User.AntithesisFutureArmed = world.time + src.seconds
		OMsg(User, "[User] turns the future inside out. No fate written against them will hold.")
		src.Cooldown(1, null, User)
		return 1

/mob/Players/AlmightyCanRewrite(mob/P)
	. = ..()
	if(!. || !ismob(P) || P.AntithesisFutureArmed <= world.time || !P.SchriftNeeded("A"))
		return
	P.AntithesisFutureArmed = 0
	OMsg(src, "The future swaps back.")
	return 0

/obj/Effects/Quincy_Federzwinger
	name = "Federzwinger"
	icon = 'Icons/Effects/SparkleArcane.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/obj/Skills/Quincy/Federzwinger
	name = "Federzwinger"
	desc = "In Vollstandig only: a pentagonal cage closes on your target for 8 seconds. They cannot move, and no Shikai or Bankai can be released inside it."
	Cooldown = 60
	Copyable = 0
	var/seconds = QUINCY_A_CAGE_TIME
	var/snare = QUINCY_A_CAGE_SNARE
	var/cage_icon = 'Icons/Effects/SparkleArcane.dmi'
	var/cage_x = 0
	var/cage_y = 0

	verb/Federzwinger()
		set name = "Federzwinger"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		CageFire(User)

	proc/CageFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("A"))
			User << "Only the bearer of Antithesis can close the Federzwinger."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "The Federzwinger closes only in Vollstandig."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.XAxisTarget()
		if(!t)
			User << "You need a target."
			return 0
		t.applySnare(src.snare)
		t.FederzwingerOn(src.seconds, src.cage_icon, src.cage_x, src.cage_y)
		OMsg(User, "[User] closes a pentagonal cage around [t]!")
		src.Cooldown(1, null, User)
		return 1

/mob/proc/FederzwingerOn(ds, cicon, cx, cy)
	set waitfor = 0
	src.FederzwingerUntil = world.time + ds
	var/gen = ++src.FederzwingerGen
	if(!src.FederzwingerCage)
		var/obj/Effects/Quincy_Federzwinger/o = new(null)
		src.FederzwingerCage = o
		src.vis_contents += o
	var/obj/Effects/Quincy_Federzwinger/c = src.FederzwingerCage
	c.icon = cicon
	c.pixel_x = cx
	c.pixel_y = cy
	sleep(ds)
	if(src && src.FederzwingerGen == gen)
		FederzwingerOff()

/mob/proc/FederzwingerOff()
	src.FederzwingerUntil = 0
	src.FederzwingerGen++
	var/obj/Effects/Quincy_Federzwinger/c = src.FederzwingerCage
	src.FederzwingerCage = null
	if(c)
		src.vis_contents -= c
		del c

/mob/Players/UseBuff(var/obj/Skills/Buffs/B, var/Override, noGCD = FALSE)
	if(B && !Override && src.FederzwingerUntil > world.time && istype(B, /obj/Skills/Buffs/SlotlessBuffs) && !BuffOn(B))
		var/obj/Skills/Buffs/SlotlessBuffs/S = B
		if(S.IsShikaiForm || S.IsBankaiForm)
			src << "The cage drinks your release."
			return 0
	return ..()

/proc/QuincyTestStepsA()
	return list("Trade blows on the ledger", "Reverse Wounds", "Reverse Places", "Take Bleed 30", "Reverse Afflictions", "Arm Reverse the Future", "Federzwinger on target", "Clear the stamp")

/mob/proc/QuincyTestA(step, mob/t)
	switch(step)
		if("Trade blows on the ledger")
			if(!t)
				return "no target"
			var/mine = PctToHP(10)
			var/theirs = t.PctToHP(5)
			LoseHealth(mine)
			t.LoseHealth(theirs)
			AntithesisNote(t, mine, 0)
			AntithesisNote(t, theirs, 1)
			var/list/s = AntithesisSums(t)
			return "taken [round(s[1])] dealt [round(s[2])]"
		if("Reverse Wounds")
			return "reversed [AntithesisReverse("Wounds")]"
		if("Reverse Places")
			return "reversed [AntithesisReverse("Places")]"
		if("Take Bleed 30")
			src.Bleed = 30
			return "bleed [src.Bleed]"
		if("Reverse Afflictions")
			return "reversed [AntithesisReverse("Afflictions")]"
		if("Arm Reverse the Future")
			src.AntithesisFutureArmed = world.time + QUINCY_A_FUTURE_TIME
			return "armed until [src.AntithesisFutureArmed]"
		if("Federzwinger on target")
			if(!t)
				return "no target"
			t.applySnare(QUINCY_A_CAGE_SNARE)
			t.FederzwingerOn(QUINCY_A_CAGE_TIME, 'Icons/Effects/SparkleArcane.dmi', 0, 0)
			return "caged until [t.FederzwingerUntil]"
		if("Clear the stamp")
			src.AntithesisAt = 0
			return "stamp cleared"
	return "unknown step"

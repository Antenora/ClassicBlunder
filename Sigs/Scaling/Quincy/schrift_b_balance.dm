#define QUINCY_BALANCE_TORN 200
#define QUINCY_BALANCE_REPAY_PCT 20
#define QUINCY_BALANCE_REPAY_DELAY 20

mob/var/tmp/ShieldGoneUntil = 0
mob/var/tmp/ShieldGen = 0
mob/var/tmp/obj/Effects/Quincy_Freund_Schild/ShieldFx
mob/var/tmp/list/BalanceLedger
mob/var/tmp/BalanceGen = 0
mob/var/tmp/mob/BalanceForcedCrit
mob/var/tmp/BalanceForcedCritNow = 0
mob/var/tmp/mob/BalanceForcedCritBy

var/mob/QuincyRollFrom
var/mob/QuincyRollMeleeTo
var/mob/QuincyMeleeFrom
var/mob/QuincyMeleeTo

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/B_The_Balance/New()
	..()
	kit_skills = list()

/obj/Effects/Quincy_Freund_Schild
	name = "Freund Schild"
	icon = 'Icons/Effects/SparkleArcane.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0

	New(loc)
		..()
		appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/mob/proc/BalanceHolds()
	return src.QuincySchrift == "B" && SchriftNeeded("B")

/mob/proc/BalanceShieldUp()
	return src.QuincySchrift == "B" && src.ShieldGoneUntil <= world.time && SchriftNeeded("B")

/mob/proc/BalanceShieldShow()
	var/want = BalanceShieldUp()
	if(want && !src.ShieldFx)
		var/obj/Effects/Quincy_Freund_Schild/f = new(null)
		src.ShieldFx = f
		src.vis_contents += f
	else if(!want && src.ShieldFx)
		var/obj/Effects/Quincy_Freund_Schild/o = src.ShieldFx
		src.vis_contents -= o
		src.ShieldFx = null
		del o

/mob/proc/BalanceTear()
	src.ShieldGoneUntil = world.time + QUINCY_BALANCE_TORN
	BalanceShieldShow()
	OMsg(src, "The Freund Schild is torn from [src]!")
	BalanceShieldReturn(src.ShieldGoneUntil)

/mob/proc/BalanceShieldReturn(until)
	set waitfor = 0
	var/gen = ++src.ShieldGen
	sleep(max(1, until - world.time + 1))
	if(!src || src.ShieldGen != gen)
		return
	BalanceShieldShow()
	if(BalanceShieldUp())
		src << "<font color=#9fd8ff>The Freund Schild settles back over you.</font>"

/mob/proc/BalanceLedgerNow()
	if(src.BalanceLedger && QuincyFightIdle())
		src.BalanceLedger = null
	return src.BalanceLedger

/mob/proc/BalanceOwed(mob/m)
	if(!ismob(m) || m == src || src.QuincySchrift != "B")
		return 0
	var/list/L = BalanceLedgerNow()
	if(!L || !(m in L))
		return 0
	if(!SchriftNeeded("B"))
		return 0
	return L[m]

/mob/proc/BalanceStore(mob/m, why)
	if(!ismob(m) || m == src || !BalanceHolds())
		return 0
	BalanceLedgerNow()
	src.QuincyFightAt = world.time
	if(!src.BalanceLedger)
		src.BalanceLedger = list()
	var/n = src.BalanceLedger[m]
	n = (n ? n : 0) + 1
	src.BalanceLedger[m] = n
	src << "<font color=#9fd8ff>[why] Misfortune against [m]: [n].</font>"
	BalanceWatch()
	return n

/mob/proc/BalanceSpend(mob/m)
	var/list/L = src.BalanceLedger
	if(!L || !(m in L))
		return 0
	var/n = L[m] - 1
	if(n > 0)
		L[m] = n
	else
		L -= m
	if(!L.len)
		src.BalanceLedger = null
	return 1

/mob/proc/BalanceWatch()
	set waitfor = 0
	var/gen = ++src.BalanceGen
	while(src && src.BalanceGen == gen && src.BalanceLedger)
		sleep(10)
		if(!src || src.BalanceGen != gen)
			return
		if(QuincyFightIdle())
			src.BalanceLedger = null
			src << "<font color=#9fd8ff>The fight is over. The ledger of misfortune closes.</font>"
			return

/mob/proc/BalanceForcedClear()
	var/mob/d = src.BalanceForcedCrit
	if(ismob(d) && d.BalanceForcedCritBy == src)
		d.BalanceForcedCritBy = null
	src.BalanceForcedCrit = null
	src.BalanceForcedCritNow = 0

/mob/proc/BalanceForcedMark(mob/d)
	BalanceForcedClear()
	src.BalanceForcedCrit = d
	src.BalanceForcedCritNow = 1
	d.BalanceForcedCritBy = src

/mob/proc/BalanceForcedCritFrom()
	var/mob/a = src.BalanceForcedCritBy
	if(ismob(a) && a.BalanceForcedCritNow && a.BalanceForcedCrit == src)
		return a
	return null

/mob/proc/BalanceForceCheck()
	var/mob/d = src.last_struck
	if(!ismob(d) || d == src || !BalanceOwed(d))
		BalanceForcedClear()
		return 0
	BalanceForcedMark(d)
	src.SureCrit = 1
	BalanceSpend(d)
	return 1

/mob/proc/BalanceRepay(mob/a, hp)
	set waitfor = 0
	sleep(QUINCY_BALANCE_REPAY_DELAY)
	if(!src || !a || a.KO)
		return
	OMsg(src, "The good fortune is repaid.")
	a.WoundSelf(a.HPToPct(hp))

/mob/proc/QuincyEvaded(mob/attacker)
	if(!ismob(attacker) || attacker == src || attacker.QuincySchrift != "B")
		return 0
	if(!attacker.BalanceShieldUp())
		return 0
	return attacker.BalanceStore(src, "[src] evades you, and the misfortune flows into the Freund Schild.")

/mob/proc/QuincyRollDefend(mob/o, melee)
	return 0

/mob/getCritDmg()
	. = ..()
	var/mob/d = src.last_struck
	if(ismob(d) && d != src && d.QuincySchrift == "B" && d.BalanceShieldUp())
		return 1

/mob/getCritChance(critEff = 1, critBonus = 0)
	. = ..()
	if(src.QuincySchrift == "B" || src.BalanceForcedCrit)
		BalanceForceCheck()

/mob/getBlockChance(blockEff = 1)
	. = ..()
	var/mob/a = src.last_struck_by
	if(ismob(a) && a.BalanceForcedCritNow && a.BalanceForcedCrit == src)
		return 0

/mob/HasNoMiss()
	. = ..()
	if(.)
		QuincyRollFrom = null
		QuincyRollMeleeTo = null
	else
		QuincyRollFrom = src
		QuincyRollMeleeTo = QuincyMeleeFrom == src ? QuincyMeleeTo : null
	QuincyMeleeFrom = null
	QuincyMeleeTo = null

/mob/HasNoDodge()
	. = ..()
	var/mob/o = QuincyRollFrom
	var/mob/mt = QuincyRollMeleeTo
	QuincyRollFrom = null
	QuincyRollMeleeTo = null
	if(!ismob(o) || o == src)
		return
	if(o.QuincySchrift == "B" && o.BalanceOwed(src))
		o.BalanceForcedMark(src)
		return 1
	if(!.)
		QuincyRollDefend(o, mt == src)

/mob/Players/QuincySyncSkills()
	..()
	BalanceShieldShow()
	if(!BalanceHolds())
		src.BalanceLedger = null
		BalanceForcedClear()

/mob/Players/Login()
	..()
	spawn(30)
		if(src)
			BalanceShieldShow()

/strikeHook/quincyBalanceCrit
	stage = "crit"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d)
			return
		if(d.QuincySchrift == "B" && d.BalanceShieldUp())
			OMsg(d, "The Freund Schild swallows [a]'s critical hit.")
			d.BalanceStore(a, "The misfortune flows into the Freund Schild.")
		else if(a.BalanceForcedCritNow && a.BalanceForcedCrit == d)
			OMsg(a, "Misfortune comes due. [d] cannot escape it.")

/strikeHook/quincyBalancePost
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(a && a.BalanceForcedCrit)
			a.BalanceForcedClear()
		if(!a || !d || a == d || d.QuincySchrift != "B" || !d.BalanceShieldUp())
			return
		if(S.dealt > 0 && d.HPToPct(S.dealt) > QUINCY_BALANCE_REPAY_PCT)
			d.BalanceRepay(a, S.dealt)
		var/obj/Skills/k = S.skill
		if(istype(k, /obj/Skills) && (istype(k, /obj/Skills/Grapple) || k.Grapple))
			d.BalanceTear()

/proc/QuincyTestStepsB()
	return list("Store 1 Misfortune on target", "Show ledger", "Tear the shield", "Restore the shield", "Clear ledger")

/mob/proc/QuincyTestB(step, mob/t)
	switch(step)
		if("Store 1 Misfortune on target")
			if(!t)
				return "no target"
			return "misfortune [BalanceStore(t, "Test.")]"
		if("Show ledger")
			var/list/L = BalanceLedgerNow()
			if(!L || !L.len)
				return "empty"
			var/out = ""
			for(var/mob/m in L)
				out += "[m] [L[m]]; "
			return out
		if("Tear the shield")
			BalanceTear()
			return "torn until [src.ShieldGoneUntil]"
		if("Restore the shield")
			src.ShieldGoneUntil = 0
			src.ShieldGen++
			BalanceShieldShow()
			return "shield [BalanceShieldUp()]"
		if("Clear ledger")
			src.BalanceLedger = null
			return "cleared"
	return "unknown step"

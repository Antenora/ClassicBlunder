#define QUINCY_M_STEP 10
#define QUINCY_M_MAX 9
#define QUINCY_M_MAGNIFY 0.1
#define QUINCY_M_TIER_ONE 3
#define QUINCY_M_CROSS 6
#define QUINCY_M_TIER_HEAL 10
#define QUINCY_M_RISE_PCT 30
#define QUINCY_M_RISE_STACKS 2
#define QUINCY_M_RISE_COOLDOWN 3000
#define QUINCY_M_CHILL 5
#define QUINCY_M_REGEN 2
#define QUINCY_M_IMPROBABLE 100

mob/var/MiracleStacks = 0
mob/var/tmp/MiracleLost = 0
mob/var/tmp/MiracleEarned = 0
mob/var/tmp/MiracleTier = 0
mob/var/tmp/MiracleRiseAt = 0
mob/var/tmp/MiracleSpent = 0
mob/var/tmp/MiracleGen = 0
mob/var/tmp/MiracleWatchOn = 0
mob/var/tmp/obj/Skills/Buffs/SlotlessBuffs/Miracle_Growth/MiracleGrowthBuff

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/M_The_Miracle/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/Hoffnung_Beam)

/obj/Skills/Buffs/SlotlessBuffs/Miracle_Growth
	name = "Miracle Growth"
	BuffName = "Miracle Growth"
	Slotless = 1
	Copyable = 0
	Cooldown = 0
	Enlarge = 1.25
	var/tier_one = 1.25
	var/tier_two = 1.5

/mob/proc/MiracleSize()
	var/obj/Skills/Buffs/SlotlessBuffs/Miracle_Growth/B = src.MiracleGrowthBuff
	if(B && B.SlotlessOn)
		B.Trigger(src, 1)
	if(!src.MiracleTier)
		if(B)
			src.MiracleGrowthBuff = null
			del B
		return
	if(!B)
		B = new
		src.MiracleGrowthBuff = B
	B.Enlarge = src.MiracleTier >= 2 ? B.tier_two : B.tier_one
	B.Trigger(src, 1)

/mob/proc/MiracleTierFor(n)
	if(n >= QUINCY_M_CROSS)
		return 2
	if(n >= QUINCY_M_TIER_ONE)
		return 1
	return 0

/mob/proc/MiracleAddStacks(n)
	if(n <= 0)
		return 0
	var/added = 0
	while(added < n && src.MiracleStacks < QUINCY_M_MAX)
		src.MiracleStacks++
		src.passive_handler.Increase("MagnifiedStr", QUINCY_M_MAGNIFY)
		src.passive_handler.Increase("MagnifiedEnd", QUINCY_M_MAGNIFY)
		added++
	if(!added)
		return 0
	var/tier = MiracleTierFor(src.MiracleStacks)
	if(tier > src.MiracleTier)
		var/ups = tier - src.MiracleTier
		src.MiracleTier = tier
		MiracleSize()
		HealPct(QUINCY_M_TIER_HEAL * ups)
		MaxHealth()
		if(tier >= 2)
			OMsg(src, "[src] grows again. The cross in their heart burns through their chest.")
		else
			OMsg(src, "[src] grows. Every wound makes them larger.")
	src << "<font color=#ffd23a>The Miracle: [src.MiracleStacks] stack[src.MiracleStacks == 1 ? "" : "s"].</font>"
	MiracleWatch()
	return added

/mob/proc/MiracleGrow(hp)
	if(src.MiracleSpent || hp <= 0)
		return 0
	src.MiracleLost += hp
	var/want = round(HPToPct(src.MiracleLost) / QUINCY_M_STEP)
	if(want <= src.MiracleEarned)
		return 0
	var/n = want - src.MiracleEarned
	src.MiracleEarned = want
	return MiracleAddStacks(n)

/mob/proc/MiracleClear()
	if(src.MiracleStacks > 0)
		for(var/i = 1 to src.MiracleStacks)
			src.passive_handler.Decrease("MagnifiedStr", QUINCY_M_MAGNIFY)
			src.passive_handler.Decrease("MagnifiedEnd", QUINCY_M_MAGNIFY)
	src.MiracleStacks = 0
	src.MiracleLost = 0
	src.MiracleEarned = 0
	if(src.MiracleTier || src.MiracleGrowthBuff)
		src.MiracleTier = 0
		MiracleSize()

/mob/proc/MiracleWatch()
	set waitfor = 0
	if(src.MiracleWatchOn)
		return
	src.MiracleWatchOn = 1
	var/gen = ++src.MiracleGen
	while(src && src.MiracleGen == gen && (src.MiracleStacks > 0 || src.MiracleSpent))
		sleep(10)
		if(!src || src.MiracleGen != gen)
			return
		if(QuincyFightIdle())
			MiracleClear()
			src.MiracleSpent = 0
			break
		if(src.MiracleStacks >= QUINCY_M_CROSS && !src.KO && QuincyVollstandigOnNow())
			HealPct(QUINCY_M_REGEN)
			MaxHealth()
	if(src && src.MiracleGen == gen)
		src.MiracleWatchOn = 0

/mob/proc/MiracleChilled()
	return src.Slow >= QUINCY_M_CHILL

/mob/proc/MiracleHope(mob/a, hp)
	set waitfor = 0
	sleep(1)
	if(!src || !a || a.KO)
		return
	OMsg(src, "Hope reflects! [a] bleeds what [src] endured.")
	a.DamageSelf(a.HPToPct(hp))

/mob/proc/MiracleCross(pct)
	set waitfor = 0
	sleep(1)
	if(!src || src.KO)
		return
	OMsg(src, "The blow finds the cross in [src]'s heart!")
	DamageSelf(pct)

/mob/proc/MiracleCanRise(mob/P)
	if(src.QuincySchrift != "M" || !SchriftNeeded("M"))
		return 0
	if(src.MiracleSpent || src.MiracleStacks >= QUINCY_M_CROSS)
		return 0
	if(ismob(P) && P != src && P.Lethal)
		return 0
	if(src.NoVoid)
		return 0
	return !src.MiracleRiseAt || src.MiracleRiseAt + QUINCY_M_RISE_COOLDOWN <= world.time

/mob/proc/MiracleRise()
	src.MiracleRiseAt = world.time
	src.SetHealthPct(QUINCY_M_RISE_PCT)
	src.MaxHealth()
	src.OMessage(15, "...but [src] rises again. A miracle.", "<font color=red>[src]([src.key]) rises through The Miracle.")
	MiracleAddStacks(QUINCY_M_RISE_STACKS)

/mob/proc/MiracleBreak()
	src.MiracleSpent = 1
	MiracleClear()
	OMsg(src, "The cross in [src]'s heart breaks. The Miracle is over for this fight.")
	MiracleWatch()

/mob/proc/MiracleLoginSweep()
	if(QuincyFightIdle() && src.MiracleStacks)
		MiracleClear()
	for(var/k in src.SlotlessBuffs.Copy())
		var/obj/Skills/Buffs/B = src.SlotlessBuffs[k]
		if(!istype(B, /obj/Skills/Buffs/SlotlessBuffs/Miracle_Growth) || B == src.MiracleGrowthBuff)
			continue
		if(B.SlotlessOn)
			B.Trigger(src, 1)
		src.SlotlessBuffs -= k
		del B

/mob/Players/getCritChance(critEff = 1, critBonus = 0)
	. = ..()
	if(src.QuincySchrift == "M" && SchriftNeeded("M"))
		. = max(., QUINCY_M_IMPROBABLE - HealthPct())

/mob/Players/Unconscious(mob/P, text)
	if(MiracleCanRise(P))
		MiracleRise()
		return
	if(src.QuincySchrift == "M" && src.MiracleStacks >= QUINCY_M_CROSS && !src.MiracleSpent)
		MiracleBreak()
	return ..()

/mob/Players/QuincySyncSkills()
	..()
	if(src.MiracleStacks && !SchriftNeeded("M"))
		MiracleClear()

/mob/Players/Login()
	..()
	spawn(40)
		if(src)
			MiracleLoginSweep()

/strikeHook/quincyMiracle
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0 || d.QuincySchrift != "M" || !d.SchriftNeeded("M"))
			return
		if(d.IsGuarding() && !d.MiracleChilled())
			d.MiracleHope(a, S.dealt)
		d.MiracleGrow(S.dealt)

/strikeHook/quincyMiracleCross
	stage = "crit"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d == S.attacker || S.dealt <= 0 || d.MiracleStacks < QUINCY_M_CROSS || !d.SchriftNeeded("M"))
			return
		d.MiracleCross(d.HPToPct(S.dealt))

/obj/Skills/Projectile/Quincy/Hoffnung_Beam
	name = "Hoffnung"
	desc = "In Aschtonig, at six stacks of The Miracle: a beam of hope."
	Cooldown = 20
	DamageMult = 2
	Distance = 15
	Speed = 0.2
	Variation = 0
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 2
	LockX = 0
	LockY = 0
	ActiveMessage = "fires a beam of hope!"

	verb/Hoffnung()
		set name = "Hoffnung"
		set category = "Skills"
		if(!usr.SchriftNeeded("M"))
			usr << "Only the bearer of The Miracle can fire Hoffnung."
			return
		if(!usr.QuincyVollstandigOnNow() || usr.MiracleStacks < QUINCY_M_CROSS)
			usr << "Hoffnung answers only in Aschtonig, at six stacks."
			return
		var/mob/t = usr.XAxisTarget()
		if(t)
			FlightAngle = QuincyAimAngle(usr, t)
			DirOverride = GunAngleDir(FlightAngle)
		usr.UseProjectile(src)
		FlightAngle = null
		DirOverride = 0

/proc/QuincyTestStepsM()
	return list("Take 10 percent", "Add a stack", "Six stacks", "Rise test", "Clear")

/mob/proc/QuincyTestM(step, mob/t)
	switch(step)
		if("Take 10 percent")
			var/hp = PctToHP(10)
			LoseHealth(hp)
			MiracleGrow(hp)
			return "stacks [src.MiracleStacks]"
		if("Add a stack")
			MiracleAddStacks(1)
			return "stacks [src.MiracleStacks]"
		if("Six stacks")
			MiracleAddStacks(QUINCY_M_CROSS - src.MiracleStacks)
			return "stacks [src.MiracleStacks]"
		if("Rise test")
			if(!MiracleCanRise(null))
				return "no rise is ready (hold The Miracle, under six stacks, once per 5 minutes)"
			SetHealthPct(0)
			Unconscious(null, "testing The Miracle")
			return "health [round(HealthPct())] KO [src.KO]"
		if("Clear")
			MiracleClear()
			return "stacks [src.MiracleStacks]"
	return "unknown step"

#define QUINCY_FEAR_MAX 5
#define QUINCY_FEAR_LIFE 30
#define QUINCY_FEAR_TERROR_TIME 2
#define QUINCY_FEAR_TERROR_KEEP 2
#define QUINCY_FEAR_DROP_STEP 10
#define QUINCY_FEAR_LOW_HP 20
#define QUINCY_FEAR_TICK 10
#define QUINCY_FEAR_SPREAD_EVERY 30
#define QUINCY_FEAR_GAZE_EVERY 20
#define QUINCY_FEAR_GAZE_RANGE 5

mob/var/tmp/list/FearStamps
mob/var/tmp/mob/FearBy
mob/var/tmp/FearSerial = 0
mob/var/tmp/FearLevel = 0
mob/var/tmp/obj/Effects/Quincy_Fear_Mark/FearMarker
mob/var/tmp/list/FearVictims
mob/var/tmp/FearHolderGen = 0
mob/var/tmp/FearHolderOn = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/F_The_Fear/New()
	..()
	kit_skills = list()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear
	name = "Fear"
	BuffName = "Quincy Fear"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 0
	Cooldown = 0
	Copyable = 0
	var/fear_level = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear1
	BuffName = "Quincy Fear 1"
	fear_level = 1
	SpdMult = 0.95
	OffMult = 0.95

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear2
	BuffName = "Quincy Fear 2"
	fear_level = 2
	SpdMult = 0.9
	OffMult = 0.9

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear3
	BuffName = "Quincy Fear 3"
	fear_level = 3
	SpdMult = 0.85
	OffMult = 0.85

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear4
	BuffName = "Quincy Fear 4"
	fear_level = 4
	SpdMult = 0.8
	OffMult = 0.8

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear5
	BuffName = "Quincy Fear 5"
	fear_level = 5
	SpdMult = 0.75
	OffMult = 0.75

/obj/Effects/Quincy_Fear_Mark
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	maptext_width = 64
	maptext_height = 16
	maptext_x = -16
	maptext_y = 60
	var/text_color = "#b47cff"

/proc/QuincyFearBuffType(n)
	switch(n)
		if(1)
			return /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear1
		if(2)
			return /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear2
		if(3)
			return /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear3
		if(4)
			return /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear4
		if(5)
			return /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/Fear5
	return null

/proc/QuincyFearDeterminationKeys()
	return list("Determination", "Determination(White)", "Determination(Green)", "Determination(Purple)", "Determination(Red)", "Determination(Orange)", "Determination(Yellow)", "Determination(Black)")

/mob/proc/FearHolds()
	return src.QuincySchrift == "F" && SchriftNeeded("F")

/mob/proc/FearImmune(mob/by)
	if(src.KO || src.Dead)
		return 1
	if(!QuincyAreaFoe(src, by))
		return 1
	if(HealthPct() < QUINCY_FEAR_LOW_HP)
		return 1
	if(HasUnstoppable())
		return 1
	for(var/k in QuincyFearDeterminationKeys())
		if(src.passive_handler.Get(k))
			return 1
	return 0

/mob/proc/FearFrozen()
	var/mob/by = src.FearBy
	return ismob(by) && by.QuincySchrift == "F" && by.QuincyVollstandigOnNow()

/mob/proc/FearStacksNow()
	if(!src.FearStamps || !src.FearStamps.len)
		return 0
	var/mob/by = src.FearBy
	if(!ismob(by) || !by.FearHolds() || src.KO)
		FearClear()
		return 0
	if(FearFrozen())
		for(var/i = 1 to src.FearStamps.len)
			src.FearStamps[i] = world.time
	else
		var/list/keep = list()
		for(var/s in src.FearStamps)
			if(world.time - s < QUINCY_FEAR_LIFE)
				keep += s
		src.FearStamps = keep
	if(!src.FearStamps.len)
		FearClear()
		return 0
	return src.FearStamps.len

/mob/proc/FearAdd(mob/by, n = 1)
	if(!ismob(by) || by == src || n <= 0)
		return 0
	if(FearImmune(by))
		return 0
	var/cur = FearStacksNow()
	if(src.FearBy != by)
		FearClear()
		cur = 0
	if(!cur)
		src.FearStamps = list()
	src.FearBy = by
	for(var/i = 1 to n)
		src.FearStamps += world.time
	while(src.FearStamps.len > QUINCY_FEAR_MAX)
		src.FearStamps.Cut(1, 2)
	if(!by.FearVictims)
		by.FearVictims = list()
	by.FearVictims |= src
	if(src.FearStamps.len >= QUINCY_FEAR_MAX)
		FearTerror(by)
	FearApply()
	FearWatch()
	by.FearHolderLoop()
	return src.FearStamps.len

/mob/proc/FearTerror(mob/by)
	OMsg(src, "[src] freezes in terror!")
	NamekFear(by, QUINCY_FEAR_TERROR_TIME)
	Stun(src, QUINCY_FEAR_TERROR_TIME)
	src.FearStamps = list()
	for(var/i = 1 to QUINCY_FEAR_TERROR_KEEP)
		src.FearStamps += world.time

/mob/proc/FearApply()
	var/n = src.FearStamps ? min(QUINCY_FEAR_MAX, src.FearStamps.len) : 0
	src.FearLevel = n
	FearBuffSet(n)
	FearMarkShow()

/mob/proc/FearBuffSet(n)
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/F in src)
		if(F.fear_level != n && src.BuffOn(F))
			F.Trigger(src, 1)
	var/T = QuincyFearBuffType(n)
	if(!T)
		return
	var/obj/Skills/Buffs/B = src.findOrAddSkill(T)
	if(B && !src.BuffOn(B))
		B.Trigger(src, 1)

/mob/proc/FearMarkShow()
	if(!src.FearStamps || !src.FearStamps.len)
		FearMarkDrop()
		return
	if(!src.FearMarker)
		src.FearMarker = new /obj/Effects/Quincy_Fear_Mark(null)
		src.vis_contents += src.FearMarker
	var/obj/Effects/Quincy_Fear_Mark/o = src.FearMarker
	o.maptext = "<span style='text-align:center;color:[o.text_color]'>F x[src.FearStamps.len]</span>"

/mob/proc/FearMarkDrop()
	if(!src.FearMarker)
		return
	var/obj/Effects/Quincy_Fear_Mark/o = src.FearMarker
	src.vis_contents -= o
	src.FearMarker = null
	del o

/mob/proc/FearBuffsDrop()
	var/list/drop = list()
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/F in src)
		drop += F
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Quincy_Fear/F in drop)
		if(src.BuffOn(F))
			F.Trigger(src, 1)
		src.DeleteSkill(F)

/mob/proc/FearClear()
	var/mob/by = src.FearBy
	src.FearStamps = null
	src.FearBy = null
	src.FearSerial++
	src.FearLevel = 0
	if(by && by.FearVictims)
		by.FearVictims -= src
	FearBuffsDrop()
	FearMarkDrop()

/mob/proc/FearWatch()
	set waitfor = 0
	var/serial = ++src.FearSerial
	while(src && src.FearSerial == serial)
		sleep(QUINCY_FEAR_TICK)
		if(!src || src.FearSerial != serial)
			return
		var/n = FearStacksNow()
		if(!n)
			return
		FearApply()
		if(src.AttackQueue && prob(QUINCY_FEAR_DROP_STEP * n))
			src.ClearQueue()
			OMsg(src, "[src] drops their attack in fear!")

/mob/proc/FearHolderLoop()
	set waitfor = 0
	if(src.FearHolderOn)
		return
	src.FearHolderOn = 1
	var/gen = ++src.FearHolderGen
	var/t = 0
	while(src && src.FearHolderGen == gen && FearHolds())
		sleep(QUINCY_FEAR_TICK)
		if(!src || src.FearHolderGen != gen)
			return
		t += QUINCY_FEAR_TICK
		if(t % QUINCY_FEAR_SPREAD_EVERY == 0)
			FearSpread()
		if(t % QUINCY_FEAR_GAZE_EVERY == 0 && QuincyVollstandigOnNow() && !src.KO)
			FearGaze()
	if(src && src.FearHolderGen == gen)
		src.FearHolderOn = 0

/mob/proc/FearHolderStop()
	src.FearHolderGen++
	src.FearHolderOn = 0
	if(src.FearVictims)
		for(var/mob/v in src.FearVictims.Copy())
			if(v && v.FearBy == src)
				v.FearClear()
	src.FearVictims = null

/mob/proc/FearSpread()
	if(!src.FearVictims || !src.FearVictims.len)
		return 0
	var/list/gain = list()
	for(var/mob/v in src.FearVictims.Copy())
		if(!v || v.FearBy != src || v.FearStacksNow() <= 0)
			continue
		for(var/mob/m in orange(1, v))
			if(m == src || m == v || !QuincyAreaFoe(m, src))
				continue
			var/g = gain[m]
			gain[m] = (g ? g : 0) + 1
	var/n = 0
	for(var/mob/m in gain)
		if(m.FearAdd(src, gain[m]))
			n++
	return n

/mob/proc/FearGaze()
	var/n = 0
	for(var/mob/m in view(QUINCY_FEAR_GAZE_RANGE, src))
		if(m == src || !QuincyAreaFoe(m, src))
			continue
		if(m.FearAdd(src, 1))
			n++
	return n

/mob/proc/FearLoginSweep()
	if(src.FearStamps)
		return
	FearBuffsDrop()
	FearMarkDrop()

/mob/Players/QuincySyncSkills()
	..()
	if(FearHolds())
		FearHolderLoop()
	else if(src.FearVictims || src.FearHolderOn)
		FearHolderStop()

/mob/Players/Login()
	..()
	spawn(40)
		if(src)
			FearLoginSweep()
			if(FearHolds())
				FearHolderLoop()

/strikeHook/quincyFear
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0 || a.QuincySchrift != "F")
			return
		if(!S.melee && !a.QuincyBombShot(S.skill))
			return
		if(!a.SchriftNeeded("F"))
			return
		d.FearAdd(a, 1)

/proc/QuincyTestStepsF()
	return list("Add 1 Fear to target", "Add 5 Fear to target", "Spread now", "Gaze now", "Clear target")

/mob/proc/QuincyTestF(step, mob/t)
	switch(step)
		if("Add 1 Fear to target")
			if(!t)
				return "no target"
			return "fear [t.FearAdd(src, 1)]"
		if("Add 5 Fear to target")
			if(!t)
				return "no target"
			return "fear [t.FearAdd(src, QUINCY_FEAR_MAX)] stunned [t.Stunned ? 1 : 0]"
		if("Spread now")
			return "spread to [FearSpread()]"
		if("Gaze now")
			return "gazed at [FearGaze()]"
		if("Clear target")
			if(!t)
				return "no target"
			t.FearClear()
			return "cleared"
	return "unknown step"

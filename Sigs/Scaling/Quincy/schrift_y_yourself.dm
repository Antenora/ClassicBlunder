#define QUINCY_Y_TIME 600
#define QUINCY_Y_ROYD_SHARE 0.7
#define QUINCY_Y_MIN_SLOPE 0.0001
#define QUINCY_Y_MIN_TRANS 0.05
#define QUINCY_Y_COPY_KEEP 100
#define QUINCY_Y_WATCH 5
#define QUINCY_Y_COPIED_BY "The Yourself"

mob/var/list/YourselfDeltas
mob/var/YourselfRealName
mob/var/YourselfRealIcon
mob/var/YourselfRealState
mob/var/tmp/YourselfMode
mob/var/tmp/YourselfUntil = 0
mob/var/tmp/YourselfGen = 0
mob/var/tmp/list/YourselfLook
mob/var/tmp/list/YourselfCopies
mob/var/tmp/obj/Skills/Quincy/Yourself/YourselfSkill

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself/Loyd/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Yourself/Imitate)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself/Royd/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Yourself/Become)

/obj/Skills/Quincy/Yourself
	Cooldown = 120
	Copyable = 0
	var/mode
	var/twin
	var/seconds = QUINCY_Y_TIME

	proc/YourselfCast(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(User.YourselfMode)
			if(User.YourselfSkill == src)
				User.YourselfEnd()
				return 1
			User << "You are already wearing someone else."
			return 0
		if(!User.SchriftNeeded("Y") || User.QuincySchriftTwin != src.twin)
			User << "Only [src.twin] of The Yourself can do this."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.YourselfTarget()
		if(!t)
			User << "The Yourself needs a target in sight."
			return 0
		if(src.mode == "Become" && User.YourselfDisguised())
			User << "You cannot become someone else while you are disguised."
			return 0
		return User.YourselfStart(src, t)

/obj/Skills/Quincy/Yourself/Imitate
	name = "Imitate"
	desc = "Loyd: for 60 seconds your Strength, Endurance, Speed, Force, Offense and Defense become exactly your target's, as they stand right now, and their last three techniques are yours to use once each. The copy never grows: it can be surpassed. Ends early if you are knocked out."
	mode = "Imitate"
	twin = "Loyd"

	verb/Loyd_Imitate()
		set name = "Loyd Imitate"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		YourselfCast(User)

/obj/Skills/Quincy/Yourself/Become
	name = "Become"
	desc = "Royd: for 60 seconds you become your target: their name, their face, their clothes, and 70 percent of their Strength, Endurance, Speed, Force, Offense and Defense as they stand right now. Their forms are copied as a look, never as power. Ends early if you are knocked out."
	mode = "Become"
	twin = "Royd"

	verb/Royd_Become()
		set name = "Royd Become"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		YourselfCast(User)

/proc/YourselfStats()
	return list("Str", "End", "Spd", "For", "Off", "Def")

/mob/proc/YourselfStatNow(stat)
	switch(stat)
		if("Str")
			return GetStr()
		if("End")
			return GetEnd()
		if("Spd")
			return GetSpd()
		if("For")
			return GetFor()
		if("Off")
			return GetOff()
		if("Def")
			return GetDef()
	return 0

/mob/proc/YourselfTransNow(stat)
	switch(stat)
		if("Str")
			return GetStrTransMult()
		if("End")
			return GetEndTransMult()
		if("Spd")
			return GetSpdTransMult()
		if("For")
			return GetForTransMult()
		if("Off")
			return GetOffTransMult()
		if("Def")
			return GetDefTransMult()
	return 1

/mob/proc/YourselfAim(stat, want)
	var/p = "Magnified[stat]"
	var/now = YourselfStatNow(stat)
	src.passive_handler.Increase(p, 1)
	var/slope = YourselfStatNow(stat) - now
	src.passive_handler.Decrease(p, 1)
	if(slope <= QUINCY_Y_MIN_SLOPE)
		return 0
	var/d = (want - now) / slope
	var/tm = YourselfTransNow(stat)
	if(tm + d < QUINCY_Y_MIN_TRANS)
		d = QUINCY_Y_MIN_TRANS - tm
	if(!d)
		return 0
	src.passive_handler.Increase(p, d)
	if(!src.YourselfDeltas)
		src.YourselfDeltas = list()
	src.YourselfDeltas[p] = (src.YourselfDeltas[p] || 0) + d
	return d

/mob/proc/YourselfUndoDeltas()
	if(!src.YourselfDeltas)
		return
	for(var/p in src.YourselfDeltas)
		var/d = src.YourselfDeltas[p]
		if(isnum(d) && d)
			src.passive_handler.Decrease(p, d)
	src.YourselfDeltas = null

/mob/proc/YourselfTarget()
	var/mob/t = src.Target
	if(!ismob(t) || t == src || t.z != src.z)
		return null
	if(!(t in view(src.client ? src.client.view : world.view, src)))
		return null
	return t

/mob/proc/YourselfDisguised()
	if(src.Imitating)
		return 1
	for(var/obj/Skills/Buffs/B in src)
		if((B.NameFake || B.Imitate) && src.BuffOn(B))
			return 1
	return 0

/mob/proc/YourselfStart(obj/Skills/Quincy/Yourself/S, mob/t)
	if(!S || !t)
		return 0
	var/share = S.mode == "Become" ? QUINCY_Y_ROYD_SHARE : 1
	var/list/want = list()
	for(var/stat in YourselfStats())
		want[stat] = t.YourselfStatNow(stat) * share
	src.YourselfMode = S.mode
	src.YourselfSkill = S
	src.YourselfDeltas = list()
	for(var/stat in YourselfStats())
		YourselfAim(stat, want[stat])
	if(S.mode == "Become")
		OMsg(src, "[src]'s outline blurs and reshapes itself into [t].")
		YourselfWearStart(t)
	else
		OMsg(src, "[src] mirrors [t]. For a minute, [t]'s power is theirs.")
		YourselfGrantCopies(t)
	src.YourselfUntil = world.time + S.seconds
	YourselfWatch()
	return 1

/mob/proc/YourselfWearStart(mob/t)
	src.YourselfRealName = src.name
	src.YourselfRealIcon = src.icon
	src.YourselfRealState = src.icon_state
	var/list/ov = list()
	for(var/O in t.overlays)
		ov += O
	var/list/un = list()
	for(var/U in t.underlays)
		un += U
	src.YourselfLook = list("icon" = t.icon, "state" = t.icon_state, "color" = t.color, "over" = ov, "under" = un)
	src.name = t.name
	src.icon_state = t.icon_state
	YourselfWear()

/mob/proc/YourselfWear()
	var/list/L = src.YourselfLook
	if(!L)
		return
	src.icon = L["icon"]
	src.color = L["color"]
	src.overlays = null
	for(var/O in L["over"])
		src.overlays += O
	src.underlays = null
	for(var/U in L["under"])
		src.underlays += U

/mob/proc/YourselfRestoreLook()
	if(isnull(src.YourselfRealName))
		src.YourselfLook = null
		return 0
	var/list/L = src.YourselfLook
	src.YourselfLook = null
	src.name = src.YourselfRealName
	src.icon = src.YourselfRealIcon
	if(L && src.icon_state == L["state"])
		src.icon_state = src.YourselfRealState
	src.YourselfRealName = null
	src.YourselfRealIcon = null
	src.YourselfRealState = null
	return 1

/mob/proc/YourselfFreeCosts(obj/Skills/S)
	S.ManaCost = 0
	S.EnergyCost = 0
	S.FatigueCost = 0
	S.HealthCost = 0
	S.WoundCost = 0
	S.CapacityCost = 0
	S.CorruptionCost = 0
	if("ManaCostAll" in S.vars)
		S.vars["ManaCostAll"] = 0
	if("ResourceCost" in S.vars)
		S.vars["ResourceCost"] = null

/mob/proc/YourselfGrantCopies(mob/t)
	src.YourselfCopies = list()
	var/list/names = list()
	for(var/T in QuincyLastSkillTypes(t))
		if(!ispath(T, /obj/Skills) || ispath(T, /obj/Skills/Projectile/Gunfire))
			continue
		if(locate(T) in src)
			continue
		var/obj/Skills/S = new T
		S.Copied = TRUE
		S.copiedBy = QUINCY_Y_COPIED_BY
		YourselfFreeCosts(S)
		src.AddSkill(S)
		src.YourselfCopies[S] = S.cooldown_start_wt
		names += "[S.name]"
	if(names.len)
		src << "<font color=#9fd8ff>You can use these once each: [jointext(names, ", ")].</font>"
	return names.len

/mob/proc/YourselfCopyUsed(obj/Skills/S)
	if(!S)
		return
	if(src.YourselfCopies)
		src.YourselfCopies -= S
	if(S.loc == src)
		src.DeleteSkill(S, FALSE)
	YourselfCopyDrop(S)

/mob/proc/YourselfCopyDrop(obj/Skills/S)
	set waitfor = 0
	sleep(QUINCY_Y_COPY_KEEP)
	if(S)
		del S

/mob/proc/YourselfCopyCheck()
	if(!src.YourselfCopies)
		return
	for(var/obj/Skills/S in src.YourselfCopies.Copy())
		if(S.loc != src)
			src.YourselfCopies -= S
			continue
		var/stamp = src.YourselfCopies[S]
		if(S.Using || S.cooldown_start_wt != stamp || (S.MaxCharges > 0 && S.Charges < S.MaxCharges))
			YourselfCopyUsed(S)

/mob/proc/YourselfDropCopies()
	if(src.YourselfCopies)
		for(var/obj/Skills/S in src.YourselfCopies.Copy())
			if(S.loc == src)
				src.DeleteSkill(S, FALSE)
			YourselfCopyDrop(S)
	src.YourselfCopies = null
	var/list/stray = list()
	for(var/obj/Skills/S in src)
		if(S.copiedBy == QUINCY_Y_COPIED_BY)
			stray += S
	for(var/obj/Skills/S in stray)
		src.DeleteSkill(S)

/mob/proc/YourselfWatch()
	set waitfor = 0
	var/gen = ++src.YourselfGen
	while(src && src.YourselfGen == gen && src.YourselfMode)
		sleep(QUINCY_Y_WATCH)
		if(!src || src.YourselfGen != gen || !src.YourselfMode)
			return
		if(world.time >= src.YourselfUntil)
			YourselfEnd()
			return
		YourselfCopyCheck()

/mob/proc/YourselfEnd(quiet = 0)
	var/was = src.YourselfMode
	var/obj/Skills/S = src.YourselfSkill
	if(!was && !src.YourselfDeltas && isnull(src.YourselfRealName) && !src.YourselfCopies)
		return 0
	src.YourselfGen++
	src.YourselfMode = null
	src.YourselfSkill = null
	src.YourselfUntil = 0
	if(!quiet && was == "Become")
		OMsg(src, "[src]'s borrowed face slides away.")
	YourselfUndoDeltas()
	YourselfDropCopies()
	if(YourselfRestoreLook())
		src.AppearanceOff()
		src.AppearanceOn()
	if(!quiet && was == "Imitate")
		OMsg(src, "[src]'s borrowed power fades.")
	if(S && S.loc == src && was)
		S.Cooldown(1, null, src)
	return 1

/mob/proc/YourselfLoginSweep()
	var/fixed = 0
	src.YourselfMode = null
	if(src.YourselfDeltas)
		YourselfUndoDeltas()
		fixed = 1
	if(!isnull(src.YourselfRealName))
		YourselfRestoreLook()
		fixed = 2
	var/list/stray = list()
	for(var/obj/Skills/S in src)
		if(S.copiedBy == QUINCY_Y_COPIED_BY)
			stray += S
	for(var/obj/Skills/S in stray)
		src.DeleteSkill(S)
	return fixed

/mob/Players/Login()
	var/fixed = YourselfLoginSweep()
	..()
	if(fixed == 2)
		spawn(10)
			if(src)
				src.AppearanceOff()
				src.AppearanceOn()

/mob/Players/Logout()
	YourselfEnd(1)
	..()

/mob/Players/AppearanceOn()
	..()
	if(src.YourselfMode == "Become" && src.YourselfLook)
		YourselfWear()

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	if(B && src.YourselfMode == "Become" && (B.NameFake || B.Imitate))
		YourselfEnd()
	. = ..()

/mob/Players/QuincySyncSkills()
	..()
	if(src.YourselfMode && !SchriftNeeded("Y"))
		YourselfEnd(1)

/obj/Skills/Utility/Imitate/Imitate()
	set category = "Roleplay"
	set hidden = 1
	if(ismob(usr) && usr.YourselfMode == "Become" && !usr.Imitating)
		usr.YourselfEnd()
	..()

/strikeHook/quincyYourselfKO
	stage = "ko"
	fire(strike/S)
		var/mob/d = S ? S.defender : null
		if(d && d.YourselfMode)
			d.YourselfEnd()

/strikeHook/quincyYourselfCopyUsed
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		if(!a || !a.YourselfCopies || !istype(S.skill, /obj/Skills))
			return
		if(S.skill.copiedBy == QUINCY_Y_COPIED_BY && (S.skill in a.YourselfCopies))
			a.YourselfCopyUsed(S.skill)

/proc/QuincyTestStepsY()
	return list("Copy the target", "End the copy", "Read the deltas")

/mob/proc/QuincyTestY(step, mob/t)
	switch(step)
		if("Copy the target")
			if(!t)
				return "no target"
			if(src.YourselfMode)
				return "already copying; end the copy first"
			var/obj/Skills/Quincy/Yourself/S = locate() in src
			if(!S)
				return "no Imitate or Become (engrave Y first)"
			YourselfStart(S, t)
			return "[S.mode] on [t]: [YourselfReadout(t)]"
		if("End the copy")
			return "ended [YourselfEnd()]"
		if("Read the deltas")
			return YourselfReadout(t)
	return "unknown step"

/mob/proc/YourselfReadout(mob/t)
	var/list/rows = list()
	for(var/stat in YourselfStats())
		var/mine = round(YourselfStatNow(stat), 0.01)
		var/theirs = ismob(t) ? round(t.YourselfStatNow(stat), 0.01) : "-"
		var/d = src.YourselfDeltas ? src.YourselfDeltas["Magnified[stat]"] : 0
		rows += "[stat] [mine] vs [theirs] (delta [round(d || 0, 0.001)])"
	return "mode [src.YourselfMode ? src.YourselfMode : "none"], name [src.name]; [jointext(rows, ", ")]"

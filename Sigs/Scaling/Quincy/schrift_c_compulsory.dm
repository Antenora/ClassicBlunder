#define QUINCY_NERVE_MAX 5
#define QUINCY_NERVE_LIFE 30
#define QUINCY_PULL_NEED 3
#define QUINCY_PULL_TIME 20
#define QUINCY_TEAR_NEED 5
#define QUINCY_TEAR_PER_STR 2
#define QUINCY_EVOLVE_HITS 3
#define QUINCY_EVOLVE_MULT 0.85
#define QUINCY_FINGER_COUNT 2
#define QUINCY_FINGER_TIME 200
#define QUINCY_FINGER_STAT 0.5
#define QUINCY_FINGER_POWER 0.5
#define QUINCY_FINGER_SCALE 0.5
#define QUINCY_FINGER_LEASH 12

mob/var/tmp/list/NerveStamps
mob/var/tmp/mob/NerveBy
mob/var/tmp/NerveTrans = 0
mob/var/tmp/NerveSerial = 0
mob/var/tmp/obj/Effects/Quincy_Nerve_Mark/NerveMarker
mob/var/tmp/list/NervePlanted
mob/var/tmp/mob/PullingTarget
mob/var/tmp/PullUntil = 0
mob/var/tmp/mob/PulledBy
mob/var/tmp/PulledUntil = 0
mob/var/tmp/CompulsoryDriving = 0
mob/var/tmp/list/CompulsoryHits
mob/var/tmp/list/CompulsoryKnown
mob/var/tmp/CompulsoryGen = 0
mob/var/tmp/list/QuincyFingers

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/C_The_Compulsory/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Compulsory_Pull, /obj/Skills/Quincy/Compulsory_Tear, /obj/Skills/Quincy/Compulsory_Fingers)

/obj/Effects/Quincy_Nerve_Mark
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	maptext_width = 64
	maptext_height = 16
	maptext_x = -16
	maptext_y = 48
	var/text_color = "#ff8ad8"

/mob/proc/NerveStacksNow()
	if(!src.NerveStamps || !src.NerveStamps.len)
		return 0
	if(src.NerveTrans != src.transActive)
		NerveClear(1)
		return 0
	var/list/keep = list()
	for(var/s in src.NerveStamps)
		if(world.time - s < QUINCY_NERVE_LIFE)
			keep += s
	src.NerveStamps = keep
	if(!keep.len)
		NerveClear()
		return 0
	NerveMarkShow()
	return keep.len

/mob/proc/NervePlant(mob/by)
	if(!ismob(by))
		return 0
	var/n = NerveStacksNow()
	if(src.NerveBy != by)
		NerveClear()
		n = 0
	if(!n)
		src.NerveStamps = list()
		src.NerveTrans = src.transActive
	src.NerveBy = by
	src.NerveStamps += world.time
	while(src.NerveStamps.len > QUINCY_NERVE_MAX)
		src.NerveStamps.Cut(1, 2)
	if(!by.NervePlanted)
		by.NervePlanted = list()
	by.NervePlanted |= src
	NerveMarkShow()
	NerveWatch()
	return src.NerveStamps.len

/mob/proc/NerveMarkShow()
	if(!src.NerveMarker)
		src.NerveMarker = new /obj/Effects/Quincy_Nerve_Mark(null)
		src.vis_contents += src.NerveMarker
	var/obj/Effects/Quincy_Nerve_Mark/o = src.NerveMarker
	o.maptext = "<span style='text-align:center;color:[o.text_color]'>x[src.NerveStamps ? src.NerveStamps.len : 0]</span>"

/mob/proc/NerveClear(unlink = 0)
	var/mob/by = src.NerveBy
	src.NerveStamps = null
	src.NerveBy = null
	src.NerveSerial++
	if(by && by.NervePlanted)
		by.NervePlanted -= src
	if(src.NerveMarker)
		var/obj/Effects/Quincy_Nerve_Mark/o = src.NerveMarker
		src.vis_contents -= o
		src.NerveMarker = null
		del o
	if(unlink && src.PulledBy)
		var/mob/p = src.PulledBy
		p.CompulsoryUnlink()

/mob/proc/NerveWatch()
	set waitfor = 0
	var/serial = ++src.NerveSerial
	while(src && src.NerveSerial == serial && src.NerveStamps && src.NerveStamps.len)
		var/oldest = src.NerveStamps[1]
		sleep(max(1, oldest + QUINCY_NERVE_LIFE - world.time + 1))
		if(!src || src.NerveSerial != serial)
			return
		NerveStacksNow()

/mob/proc/NerveSnapAll()
	var/n = 0
	if(src.PullingTarget)
		CompulsoryUnlink()
		n++
	if(src.NervePlanted)
		for(var/mob/m in src.NervePlanted.Copy())
			if(m.NerveBy == src)
				m.NerveClear(1)
				n++
	src.NervePlanted = null
	if(n)
		OMsg(src, "[src]'s threads of nerve snap!")
	return n

/mob/proc/CompulsoryPullingNow()
	if(!src.PullingTarget)
		return 0
	var/mob/t = src.PullingTarget
	if(src.PullUntil <= world.time || !t || t.z != src.z || t.PulledBy != src)
		CompulsoryUnlink()
		return 0
	return 1

/mob/proc/CompulsoryPulledNow()
	if(!src.PulledBy)
		return 0
	if(src.PulledUntil <= world.time)
		src.PulledBy = null
		src.PulledUntil = 0
		return 0
	return 1

/mob/proc/CompulsoryLink(mob/t, ds)
	if(!ismob(t) || t == src)
		return 0
	CompulsoryUnlink()
	if(t.PulledBy)
		var/mob/o = t.PulledBy
		o.CompulsoryUnlink()
	src.PullingTarget = t
	src.PullUntil = world.time + ds
	t.PulledBy = src
	t.PulledUntil = src.PullUntil
	src << "<font color=#ff8ad8>Your nerves take hold of [t]. Your steps are theirs.</font>"
	t << "<font color=#ff8ad8>Your body moves against your will!</font>"
	CompulsoryLinkEnd(t, src.PullUntil)
	return 1

/mob/proc/CompulsoryLinkEnd(mob/t, until)
	set waitfor = 0
	sleep(max(1, until - world.time))
	if(src && src.PullingTarget == t && src.PullUntil == until)
		CompulsoryUnlink()

/mob/proc/CompulsoryUnlink()
	var/mob/t = src.PullingTarget
	src.PullingTarget = null
	src.PullUntil = 0
	if(t && t.PulledBy == src)
		t.PulledBy = null
		t.PulledUntil = 0

/mob/proc/CompulsoryOwnStep()
	return !src.Knockback && !src.Knockbacked && !src.Launched && !src.is_dashing

/mob/proc/CompulsoryDrive(Dir)
	var/mob/t = src.PullingTarget
	if(!t || !t.Move_Requirements())
		return 0
	var/old = t.step_size
	t.step_size = src.step_size
	t.CompulsoryDriving = 1
	. = step(t, Dir)
	if(t)
		t.CompulsoryDriving = 0
		t.step_size = old

/mob/proc/CompulsoryTear(mob/t)
	if(!ismob(t) || t.NerveBy != src || t.NerveStacksNow() < QUINCY_TEAR_NEED)
		return 0
	var/pct = max(0, t.GetStr() * QUINCY_TEAR_PER_STR)
	t.NerveClear()
	t.QuincyMaimOnce(src)
	OMsg(src, "[src] tears at the nerves inside [t]!")
	if(pct > 0)
		t.DamageSelf(pct)
	return 1

/mob/proc/QuincyMaimOnce(mob/by)
	var/list/parts = list()
	for(var/p in MAIM_PARTS)
		if(MaimTierOf(p) < MAIM_TIER_MAX)
			parts += p
	if(!parts.len)
		return null
	var/part = pick(parts)
	var/tier = MaimApply(part, 1)
	recordMaim(by, "Combat", "[part] tier [tier]")
	return part

/mob/proc/CompulsoryLearn(t)
	if(!ispath(t))
		return
	if(!src.CompulsoryHits)
		src.CompulsoryHits = list()
	var/n = src.CompulsoryHits[t]
	n = (n ? n : 0) + 1
	src.CompulsoryHits[t] = n
	if(n == QUINCY_EVOLVE_HITS)
		if(!src.CompulsoryKnown)
			src.CompulsoryKnown = list()
		src.CompulsoryKnown |= t
		var/obj/Skills/S = t
		src << "<font color=#ff8ad8>Your body learns [initial(S.name)]. It hurts you less now.</font>"
	CompulsoryWatch()

/mob/proc/CompulsoryWatch()
	set waitfor = 0
	var/gen = ++src.CompulsoryGen
	while(src && src.CompulsoryGen == gen && src.CompulsoryHits)
		sleep(10)
		if(!src || src.CompulsoryGen != gen)
			return
		if(QuincyFightIdle())
			src.CompulsoryHits = null
			src.CompulsoryKnown = null
			return

/mob/proc/CompulsoryKnows(t)
	if(!t || !src.CompulsoryKnown)
		return 0
	if(QuincyFightIdle())
		src.CompulsoryHits = null
		src.CompulsoryKnown = null
		return 0
	return (t in src.CompulsoryKnown) ? 1 : 0

/proc/QuincyFingerSpot(turf/center)
	var/list/spots = list()
	for(var/turf/T in range(1, center))
		if(T != center && !T.density)
			spots += T
	return spots.len ? pick(spots) : center

/mob/proc/QuincyFingersLive()
	var/list/keep = list()
	for(var/mob/Player/AI/Quincy_Finger/f in src.QuincyFingers)
		if(!f.finger_gone && f.loc)
			keep += f
	src.QuincyFingers = keep
	return keep

/mob/proc/QuincyFingersGone()
	for(var/mob/Player/AI/Quincy_Finger/f in QuincyFingersLive())
		f.QuincyFingerVanish()
	src.QuincyFingers = null

/mob/proc/QuincyFingerSpawn(n, ds)
	var/turf/center = get_turf(src)
	if(!center || n <= 0)
		return 0
	if(!src.QuincyFingers)
		src.QuincyFingers = list()
	var/made = 0
	for(var/i = 1 to n)
		var/mob/Player/AI/Quincy_Finger/a = new
		ticking_ai.Remove(a)
		a.loc = QuincyFingerSpot(center)
		a.name = "[src]'s Finger"
		a.icon = src.icon
		a.icon_state = src.icon_state
		a.overlays = src.overlays
		a.color = src.color
		a.transform = matrix() * a.finger_scale
		a.ai_owner = src
		a.ai_follow = 1
		a.ai_hostility = 1
		a.ai_focus_owner_target = 1
		a.ai_protection = 20
		a.companion_def_mode = 0
		a.prev_owner_health = src.Health
		a.Timeless = 1
		a.ai_team_fire = 0
		a.ai_alliances = src.NamekPokoAlliances()
		a.StrMod = round(QUINCY_FINGER_STAT * (src.StrMod + src.StrAscension), 0.001)
		a.EndMod = round(QUINCY_FINGER_STAT * (src.EndMod + src.EndAscension), 0.001)
		a.ForMod = round(QUINCY_FINGER_STAT * (src.ForMod + src.ForAscension), 0.001)
		a.OffMod = round(QUINCY_FINGER_STAT * (src.OffMod + src.OffAscension), 0.001)
		a.DefMod = round(QUINCY_FINGER_STAT * (src.DefMod + src.DefAscension), 0.001)
		a.SpdMod = round(QUINCY_FINGER_STAT * (src.SpdMod + src.SpdAscension), 0.001)
		a.VitMod = a.EndMod
		a.RecovMod = src.RecovMod
		a.AngerMax = src.AngerMax
		a.Potential = src.Potential
		a.finger_until = world.time + ds
		a.SetHealthPct(100)
		src.ai_followers += a
		companion_ais += a
		src.QuincyFingers += a
		a.AIAvailablePower()
		a.last_powercheck = world.time
		a.aiGain()
		var/mob/t = src.Target
		if(ismob(t) && t != src && QuincyAreaFoe(t, src))
			a.SetTarget(t)
		made++
	if(made)
		OMsg(src, "[src]'s fingers tear free and move on their own!")
	return made

/mob/Player/AI/Quincy_Finger
	var/tmp/finger_until = 0
	var/tmp/finger_gone = 0
	var/tmp/finger_power = QUINCY_FINGER_POWER
	var/tmp/finger_scale = QUINCY_FINGER_SCALE

	Update()
		set waitfor = 0
		if(finger_gone)
			return
		if(!QuincyFingerKeeps())
			QuincyFingerVanish()
			return
		QuincyFingerLeash()
		..()

	Del()
		var/mob/P = ai_owner
		if(P)
			P.ai_followers -= src
			if(P.QuincyFingers)
				P.QuincyFingers -= src
		companion_ais -= src
		..()

	Chase()
		if(!Target)
			ai_state = "Idle"
			return
		if(!isAI(Target))
			return ..()
		if(!QuincyFingerFightsAI(Target))
			RemoveTarget()
			ai_state = "Idle"
			return
		if(isCrowdControlled())
			return
		ai_state = "Chase"
		if(Target.KO || Target.Dead)
			RemoveTarget()
			ai_state = "Idle"
			return
		fleeing = FALSE
		var/dist = get_dist(src, Target)
		GoAfterTarget()
		if(dist <= 1)
			dir = get_dir(src, Target)
			Attack("melee")
		last_activity = world.time

	AIAvailablePower()
		var/mob/P = ai_owner
		..()
		if(!ismob(P))
			return
		temp_potential_power(P)
		var/want = P.potential_power_mult * finger_power
		var/used = potential_power_mult
		if(used > 0)
			Power *= want / used
		potential_power_mult = want

	proc/QuincyFingerFightsAI(mob/Player/AI/A)
		if(!istype(A) || A.ai_owner)
			return 0
		return !AllianceCheck(A)

	proc/QuincyFingerKeeps()
		var/mob/P = ai_owner
		if(!ismob(P) || !P.QuincyFingers || !(src in P.QuincyFingers))
			return 0
		if(KO || Dead || !loc || world.time >= finger_until)
			return 0
		if(P.KO || !P.QuincyVollstandigOnNow())
			return 0
		return 1

	proc/QuincyFingerLeash()
		var/mob/P = ai_owner
		if(P.z == z && get_dist(src, P) <= QUINCY_FINGER_LEASH)
			return
		loc = get_turf(P)
		step_x = 0
		step_y = 0
		RemoveTarget()
		ai_state = "Idle"

	proc/QuincyFingerVanish()
		if(finger_gone)
			return
		finger_gone = 1
		var/mob/P = ai_owner
		if(P)
			P.ai_followers -= src
			if(P.QuincyFingers)
				P.QuincyFingers -= src
		companion_ais -= src
		ticking_ai.Remove(src)
		ai_owner = null
		RemoveTarget()
		animate(src, alpha = 0, time = 5)
		spawn(5)
			if(src)
				del src

/mob/Players/Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
	if(src.PulledBy && !src.CompulsoryDriving && CompulsoryOwnStep() && CompulsoryPulledNow())
		return 0
	if(Dir && src.PullingTarget && CompulsoryOwnStep() && CompulsoryPullingNow())
		CompulsoryDrive(Dir)
		return 0
	return ..()

/mob/Player/AI/Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
	if(src.PulledBy && !src.CompulsoryDriving && CompulsoryOwnStep() && CompulsoryPulledNow())
		return 0
	return ..()

/mob/Players/QuincyDamageTakenMult(skilltype)
	. = ..()
	if(skilltype && CompulsoryKnows(skilltype) && SchriftNeeded("C"))
		. *= QUINCY_EVOLVE_MULT

/mob/Players/QuincySyncSkills()
	..()
	if(!SchriftNeeded("C"))
		if(src.NervePlanted || src.PullingTarget)
			NerveSnapAll()
		if(src.QuincyFingers)
			QuincyFingersGone()

/strikeHook/quincyNerve
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		var/melee = S.melee
		if(istype(a, /mob/Player/AI/Quincy_Finger))
			var/mob/Player/AI/Quincy_Finger/f = a
			a = f.ai_owner
			melee = 1
		if(!ismob(a) || a == d || a.QuincySchrift != "C" || !a.SchriftNeeded("C"))
			return
		if(!melee && !a.QuincyBombShot(S.skill))
			return
		d.NervePlant(a)

/strikeHook/quincyNerveSnap
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d == S.attacker || !istype(S.skill, /obj/Skills))
			return
		if(!d.NervePlanted && !d.PullingTarget)
			return
		if(!initial(S.skill.Shocking) && !initial(S.skill.Paralyzing))
			return
		d.NerveSnapAll()

/strikeHook/quincyCompulsoryLearn
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d == S.attacker || S.dealt <= 0 || !istype(S.skill, /obj/Skills))
			return
		if(d.QuincySchrift != "C" || !d.SchriftNeeded("C"))
			return
		d.CompulsoryLearn(S.skill.type)

/obj/Skills/Quincy/Compulsory_Pull
	name = "Compulsory Pull"
	desc = "With 3 or more of your Nerves in your target, your movement keys walk their body for 2 seconds while you stand still."
	Cooldown = 15
	Copyable = 0
	var/need = QUINCY_PULL_NEED
	var/pull_time = QUINCY_PULL_TIME

	verb/Compulsory_Pull()
		set name = "Compulsory Pull"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		PullFire(User)

	proc/PullFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("C"))
			User << "Only the bearer of The Compulsory can pull a body by its nerves."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.XAxisTarget()
		if(!t)
			User << "You need a target."
			return 0
		var/n = t.NerveBy == User ? t.NerveStacksNow() : 0
		if(n < src.need)
			User << "[t] carries [n] of your Nerves. You need [src.need]."
			return 0
		User.CompulsoryLink(t, src.pull_time)
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Compulsory_Tear
	name = "Compulsory Tear"
	desc = "With 5 of your Nerves in your target, tear them apart from inside: damage scaled by their own Strength, and a maim."
	Cooldown = 30
	Copyable = 0

	verb/Compulsory_Tear()
		set name = "Compulsory Tear"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		TearFire(User)

	proc/TearFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("C"))
			User << "Only the bearer of The Compulsory can tear the nerves."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.XAxisTarget()
		if(!t)
			User << "You need a target."
			return 0
		var/n = t.NerveBy == User ? t.NerveStacksNow() : 0
		if(n < QUINCY_TEAR_NEED)
			User << "[t] carries [n] of your Nerves. You need [QUINCY_TEAR_NEED]."
			return 0
		if(!User.CompulsoryTear(t))
			return 0
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Compulsory_Fingers
	name = "Fingers"
	desc = "In Vollstandig only: two Fingers tear free and fight beside you for 20 seconds. Their touch plants Nerves."
	Cooldown = 45
	Copyable = 0
	var/count = QUINCY_FINGER_COUNT
	var/seconds = QUINCY_FINGER_TIME

	verb/Fingers()
		set name = "Fingers"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		FingersFire(User)

	proc/FingersFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("C"))
			User << "Only the bearer of The Compulsory can loose the Fingers."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "The Fingers move only in Vollstandig."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		User.QuincyFingersGone()
		if(!User.QuincyFingerSpawn(src.count, src.seconds))
			return 0
		src.Cooldown(1, null, User)
		return 1

/proc/QuincyTestStepsC()
	return list("Plant 3 Nerves on target", "Plant 5 Nerves on target", "Pull", "Tear", "Fingers", "Snap links")

/mob/proc/QuincyTestC(step, mob/t)
	switch(step)
		if("Plant 3 Nerves on target")
			if(!t)
				return "no target"
			for(var/i = 1 to QUINCY_PULL_NEED)
				t.NervePlant(src)
			return "nerves [t.NerveStacksNow()]"
		if("Plant 5 Nerves on target")
			if(!t)
				return "no target"
			for(var/i = 1 to QUINCY_NERVE_MAX)
				t.NervePlant(src)
			return "nerves [t.NerveStacksNow()]"
		if("Pull")
			if(!t)
				return "no target"
			return "linked [CompulsoryLink(t, QUINCY_PULL_TIME)]"
		if("Tear")
			if(!t)
				return "no target"
			return "torn [CompulsoryTear(t)]"
		if("Fingers")
			if(!QuincyVollstandigOnNow())
				return "enter Vollstandig first"
			QuincyFingersGone()
			return "fingers [QuincyFingerSpawn(QUINCY_FINGER_COUNT, QUINCY_FINGER_TIME)]"
		if("Snap links")
			return "snapped [NerveSnapAll()]"
	return "unknown step"

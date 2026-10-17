#define QUINCY_Z_BLOOD_WOUND 5
#define QUINCY_Z_BLOOD_TIME 100
#define QUINCY_Z_STACK_LIFE 600
#define QUINCY_Z_RISE_NEED 3
#define QUINCY_Z_LIFE 600
#define QUINCY_Z_MAX 3
#define QUINCY_Z_STAT 0.7
#define QUINCY_Z_CLEANSE_PCT 30
#define QUINCY_Z_MEND_PCT 30
#define QUINCY_Z_SKELETONS 3
#define QUINCY_Z_SKELETON_TIME 200
#define QUINCY_Z_SKELETON_STAT 0.5
#define QUINCY_Z_LEASH 12

mob/var/tmp/BloodArmedUntil = 0
mob/var/tmp/list/ZombieStacks
mob/var/tmp/mob/ZombieBy
mob/var/tmp/ZombieSerial = 0
mob/var/tmp/obj/Effects/Quincy_Zombie_Mark/ZombieMarker
mob/var/tmp/list/QuincyZombies
mob/var/tmp/list/QuincySkeletons

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Z_The_Zombie/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Blood, /obj/Skills/Quincy/Flesh_Trade, /obj/Skills/Quincy/Consume_Zombie, /obj/Skills/Quincy/Dancing_Dead_Boys_Club)

/obj/Effects/Quincy_Zombie_Mark
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	maptext_width = 64
	maptext_height = 16
	maptext_x = -16
	maptext_y = 56
	var/text_color = "#b4002a"

/mob/proc/ZombieAlly(mob/m)
	if(!ismob(m))
		return 0
	if(m == src)
		return 1
	if(m.ckey && src.inParty(m.ckey))
		return 1
	if(src.ai_followers && (m in src.ai_followers))
		return 1
	if(istype(m, /mob/Player/AI/Quincy_Zombie))
		var/mob/Player/AI/Quincy_Zombie/z = m
		if(z.ai_owner == src)
			return 1
	return 0

/mob/proc/ZombieStacksNow()
	if(!src.ZombieStacks || !src.ZombieStacks.len)
		return 0
	var/list/keep = list()
	for(var/s in src.ZombieStacks)
		if(world.time - s < QUINCY_Z_STACK_LIFE)
			keep += s
	src.ZombieStacks = keep
	if(!keep.len)
		ZombieClear()
		return 0
	ZombieMarkShow()
	return keep.len

/mob/proc/ZombieMark(mob/by)
	if(!ismob(by))
		return 0
	var/n = ZombieStacksNow()
	if(src.ZombieBy != by)
		ZombieClear()
		n = 0
	if(!n)
		src.ZombieStacks = list()
	src.ZombieBy = by
	src.ZombieStacks += world.time
	ZombieMarkShow()
	ZombieWatch()
	return src.ZombieStacks.len

/mob/proc/ZombieMarkShow()
	if(!src.ZombieMarker)
		src.ZombieMarker = new /obj/Effects/Quincy_Zombie_Mark(null)
		src.vis_contents += src.ZombieMarker
	var/obj/Effects/Quincy_Zombie_Mark/o = src.ZombieMarker
	o.maptext = "<span style='text-align:center;color:[o.text_color]'>x[src.ZombieStacks ? src.ZombieStacks.len : 0]</span>"

/mob/proc/ZombieClear()
	src.ZombieStacks = null
	src.ZombieBy = null
	src.ZombieSerial++
	if(src.ZombieMarker)
		var/obj/Effects/Quincy_Zombie_Mark/o = src.ZombieMarker
		src.vis_contents -= o
		src.ZombieMarker = null
		del o

/mob/proc/ZombieWatch()
	set waitfor = 0
	var/serial = ++src.ZombieSerial
	while(src && src.ZombieSerial == serial && src.ZombieStacks && src.ZombieStacks.len)
		var/oldest = src.ZombieStacks[1]
		sleep(max(1, oldest + QUINCY_Z_STACK_LIFE - world.time + 1))
		if(!src || src.ZombieSerial != serial)
			return
		ZombieStacksNow()

/mob/proc/QuincyZombiesLive()
	var/list/keep = list()
	for(var/mob/Player/AI/Quincy_Zombie/z in src.QuincyZombies)
		if(!z.zombie_gone && z.loc)
			keep += z
	src.QuincyZombies = keep
	return keep

/mob/proc/QuincySkeletonsLive()
	var/list/keep = list()
	for(var/mob/Player/AI/Quincy_Zombie/z in src.QuincySkeletons)
		if(!z.zombie_gone && z.loc)
			keep += z
	src.QuincySkeletons = keep
	return keep

/mob/proc/QuincyUndeadGone()
	for(var/mob/Player/AI/Quincy_Zombie/z in QuincyZombiesLive())
		z.ZombieCrumble()
	for(var/mob/Player/AI/Quincy_Zombie/z in QuincySkeletonsLive())
		z.ZombieCrumble()
	src.QuincyZombies = null
	src.QuincySkeletons = null

/proc/ZombieTechniqueOK(T)
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
	return 1

/mob/proc/ZombieSetup(mob/Player/AI/Quincy_Zombie/z, turf/center, mob/look, stat_mult)
	ticking_ai.Remove(z)
	z.loc = QuincyFingerSpot(center)
	z.ai_owner = src
	z.ai_follow = 1
	z.ai_hostility = 1
	z.ai_focus_owner_target = 1
	z.ai_protection = 20
	z.companion_def_mode = 0
	z.prev_owner_health = src.Health
	z.Timeless = 1
	z.ai_team_fire = 0
	z.ai_alliances = src.NamekPokoAlliances()
	z.StrMod = round(stat_mult * (look.StrMod + look.StrAscension), 0.001)
	z.EndMod = round(stat_mult * (look.EndMod + look.EndAscension), 0.001)
	z.ForMod = round(stat_mult * (look.ForMod + look.ForAscension), 0.001)
	z.OffMod = round(stat_mult * (look.OffMod + look.OffAscension), 0.001)
	z.DefMod = round(stat_mult * (look.DefMod + look.DefAscension), 0.001)
	z.SpdMod = round(stat_mult * (look.SpdMod + look.SpdAscension), 0.001)
	z.VitMod = z.EndMod
	z.RecovMod = look.RecovMod
	z.AngerMax = look.AngerMax
	z.Potential = look.Potential
	z.zombie_power = stat_mult
	z.zombie_source = look
	z.SetHealthPct(100)
	src.ai_followers += z
	companion_ais += z

/mob/proc/ZombieRaise(mob/v)
	var/turf/center = get_turf(v)
	if(!center)
		return null
	var/list/live = QuincyZombiesLive()
	while(live.len >= QUINCY_Z_MAX)
		var/mob/Player/AI/Quincy_Zombie/old = live[1]
		live -= old
		old.ZombieCrumble()
	var/mob/Player/AI/Quincy_Zombie/z = new
	z.name = "[v.name] (zombie)"
	z.icon = v.icon
	z.icon_state = ""
	z.overlays = v.overlays
	z.underlays = v.underlays
	z.color = v.color
	z.zombie_until = world.time + QUINCY_Z_LIFE
	ZombieSetup(z, center, v, QUINCY_Z_STAT)
	if(!src.QuincyZombies)
		src.QuincyZombies = list()
	src.QuincyZombies += z
	for(var/T in QuincyLastSkillTypes(v))
		if(ZombieTechniqueOK(T))
			z.AddSkill(new T)
	z.AIAvailablePower()
	z.last_powercheck = world.time
	z.aiGain()
	var/mob/t = src.Target
	if(ismob(t) && t != src && t != v && QuincyAreaFoe(t, src))
		z.SetTarget(t)
	OMsg(src, "[v]'s blood answers [src]. [v] rises again as a zombie!")
	return z

/mob/proc/ZombieSkeletons(n, ds)
	var/turf/center = get_turf(src)
	if(!center || n <= 0)
		return 0
	for(var/mob/Player/AI/Quincy_Zombie/z in QuincySkeletonsLive())
		z.ZombieCrumble()
	src.QuincySkeletons = list()
	var/made = 0
	for(var/i = 1 to n)
		var/mob/Player/AI/Quincy_Zombie/Skeleton/s = new
		s.name = "[src]'s dancing skeleton"
		s.zombie_until = world.time + ds
		ZombieSetup(s, center, src, QUINCY_Z_SKELETON_STAT)
		src.QuincySkeletons += s
		s.AIAvailablePower()
		s.last_powercheck = world.time
		s.aiGain()
		var/mob/t = src.Target
		if(ismob(t) && t != src && QuincyAreaFoe(t, src))
			s.SetTarget(t)
		made++
	if(made)
		OMsg(src, "The Dancing Dead Boys Club takes the floor around [src]!")
	return made

/mob/proc/ZombieFleshTrade(mob/ally, mob/Player/AI/Quincy_Zombie/z)
	if(!ally || !z || z.zombie_gone)
		return 0
	var/inj = ally.TotalInjury
	var/list/m = ally.maims
	if(inj <= 0 && !(m && m.len))
		return 0
	if(m && m.len)
		if(!z.maims)
			z.maims = list()
		for(var/datum/maim/M in m)
			var/datum/maim/have = z.MaimGet(M.part)
			if(have)
				have.tier = min(MAIM_TIER_MAX, have.tier + M.tier)
			else
				z.maims += M
		ally.maims = null
		ally.MaimRebuild()
		z.MaimRebuild()
	if(inj > 0)
		z.TotalInjury = min(99, z.TotalInjury + inj)
		ally.TotalInjury = 0
		ally.MaxHealth()
		z.MaxHealth()
	OMsg(src, "[ally]'s wounds crawl out of their flesh and into [z]!")
	return 1

/mob/proc/ZombieFleshAllies()
	var/list/out = list()
	for(var/mob/Players/P in view(src))
		if(P == src || (P.ckey && src.inParty(P.ckey)))
			if(P.TotalInjury > 0 || (P.maims && P.maims.len))
				out += P
	return out

/mob/proc/ZombieConsume(mob/Player/AI/Quincy_Zombie/z, pct)
	if(!z || z.zombie_gone)
		return 0
	OMsg(src, "[src] drinks the blood back out of [z]!")
	z.ZombieCrumble(1)
	src.HealPct(pct)
	src.MaxHealth()
	return 1

/mob/proc/ZombiePickOne(msg)
	var/list/live = QuincyZombiesLive()
	if(!live.len)
		return null
	if(live.len == 1)
		return live[1]
	var/list/labels = PromptLabelAtoms(live, 1)
	var/pick = Ask(src, msg, "Zombie", null, "pick", labels, 1)
	if(isnull(pick))
		return null
	var/mob/Player/AI/Quincy_Zombie/z = labels[pick]
	if(!z || !(z in QuincyZombiesLive()))
		return null
	return z

/mob/Player/AI/Quincy_Zombie
	var/tmp/zombie_until = 0
	var/tmp/zombie_gone = 0
	var/tmp/zombie_power = QUINCY_Z_STAT
	var/tmp/mob/zombie_source

	Update()
		set waitfor = 0
		if(zombie_gone)
			return
		if(!ZombieKeeps())
			ZombieCrumble()
			return
		ZombieLeash()
		..()

	Del()
		var/mob/P = ai_owner
		if(P)
			P.ai_followers -= src
			if(P.QuincyZombies)
				P.QuincyZombies -= src
			if(P.QuincySkeletons)
				P.QuincySkeletons -= src
		companion_ais -= src
		..()

	Chase()
		if(!Target)
			ai_state = "Idle"
			return
		if(Target == ai_owner)
			RemoveTarget()
			ai_state = "Idle"
			return
		if(!isAI(Target))
			return ..()
		if(!ZombieFightsAI(Target))
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
		var/mob/P = zombie_source
		if(!ismob(P))
			P = ai_owner
		..()
		if(!ismob(P))
			return
		if(istype(P, /mob/Players))
			temp_potential_power(P)
		var/want = P.potential_power_mult * zombie_power
		var/used = potential_power_mult
		if(used > 0)
			Power *= want / used
		potential_power_mult = want

	proc/ZombieFightsAI(mob/Player/AI/A)
		if(!istype(A) || A.ai_owner)
			return 0
		return !AllianceCheck(A)

	proc/ZombieKeeps()
		var/mob/P = ai_owner
		if(!ismob(P))
			return 0
		if(!(src in P.QuincyZombies) && !(src in P.QuincySkeletons))
			return 0
		if(KO || Dead || !loc || world.time >= zombie_until)
			return 0
		if(P.KO)
			return 0
		return 1

	proc/ZombieLeash()
		var/mob/P = ai_owner
		if(P.z == z && get_dist(src, P) <= QUINCY_Z_LEASH)
			return
		loc = get_turf(P)
		step_x = 0
		step_y = 0
		RemoveTarget()
		ai_state = "Idle"

	proc/ZombieSwapOwner(mob/n)
		var/mob/P = ai_owner
		if(!ismob(n) || P == n || zombie_gone)
			return 0
		if(P)
			P.ai_followers -= src
			if(P.QuincyZombies)
				P.QuincyZombies -= src
			if(P.QuincySkeletons)
				P.QuincySkeletons -= src
		ai_owner = n
		n.ai_followers += src
		if(!n.QuincyZombies)
			n.QuincyZombies = list()
		n.QuincyZombies += src
		ai_alliances = n.NamekPokoAlliances()
		prev_owner_health = n.Health
		RemoveTarget()
		ai_state = "Idle"
		if(P)
			OMsg(n, "[src] falls for [n] and turns on [P]!")
		return 1

	proc/ZombieCrumble(quiet = 0)
		if(zombie_gone)
			return
		zombie_gone = 1
		var/mob/P = ai_owner
		if(P)
			P.ai_followers -= src
			if(P.QuincyZombies)
				P.QuincyZombies -= src
			if(P.QuincySkeletons)
				P.QuincySkeletons -= src
		companion_ais -= src
		ticking_ai.Remove(src)
		ai_owner = null
		RemoveTarget()
		maims = null
		TotalInjury = 0
		if(!quiet)
			OMsg(src, "[src] crumbles into dust.")
		animate(src, alpha = 0, time = 5)
		spawn(5)
			if(src)
				del src

/mob/Player/AI/Quincy_Zombie/Skeleton
	icon = 'Icons/NPCS/Skeleton.dmi'

/mob/Players/HealPct(pct)
	..()
	if(pct >= QUINCY_Z_CLEANSE_PCT && src.ZombieStacks)
		ZombieClear()
		src << "<font color=#b4002a>The heal washes the foreign blood out of you.</font>"

/mob/Players/Logout()
	if(src.QuincyZombies || src.QuincySkeletons)
		QuincyUndeadGone()
	..()

/mob/Players/QuincySyncSkills()
	..()
	if(!SchriftNeeded("Z"))
		src.BloodArmedUntil = 0
		if(src.QuincyZombies || src.QuincySkeletons)
			QuincyUndeadGone()

/mob/Players/QuincyFreeRegistry()
	..()
	src.BloodArmedUntil = 0
	if(src.QuincyZombies || src.QuincySkeletons)
		QuincyUndeadGone()

/strikeHook/quincyZombieBlood
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		if(a.QuincySchrift != "Z" || a.BloodArmedUntil <= world.time || !a.SchriftNeeded("Z"))
			return
		if(istype(d, /mob/Player/AI/Quincy_Zombie) || d.QuincyIsQuincy() || a.ZombieAlly(d))
			return
		d.ZombieMark(a)

/strikeHook/quincyZombieRise
	stage = "ko"
	fire(strike/S)
		var/mob/d = S ? S.defender : null
		if(!d)
			return
		if(d.QuincyZombies || d.QuincySkeletons)
			d.QuincyUndeadGone()
		if(!d.ZombieStacks || istype(d, /mob/Player/AI/Quincy_Zombie) || d.QuincyIsQuincy())
			return
		var/mob/by = d.ZombieBy
		if(d.ZombieStacksNow() < QUINCY_Z_RISE_NEED)
			return
		d.ZombieClear()
		if(!ismob(by) || !by.loc || by.KO || by.Dead || by == d || !by.SchriftNeeded("Z"))
			return
		by.ZombieRaise(d)

/obj/Skills/Quincy/Blood
	name = "Blood"
	desc = "Wound yourself for 5 percent of your health to arm your blood for 10 seconds. Every hit you land while it is armed marks the target. A foe knocked out with 3 marks rises as your zombie."
	Cooldown = 20
	Copyable = 0
	var/wound = QUINCY_Z_BLOOD_WOUND
	var/armed_time = QUINCY_Z_BLOOD_TIME

	verb/Blood()
		set name = "Blood"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		BloodFire(User)

	proc/BloodFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("Z"))
			User << "Only the bearer of The Zombie can arm their blood."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		User.WoundSelf(src.wound)
		User.BloodArmedUntil = world.time + src.armed_time
		OMsg(User, "[User] opens a vein. Their blood hungers for a host.")
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Flesh_Trade
	name = "Flesh Trade"
	desc = "Move an ally's maims and injuries, or your own, onto one of your zombies."
	Cooldown = 30
	Copyable = 0

	verb/Flesh_Trade()
		set name = "Flesh Trade"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		TradeFire(User)

	proc/TradeFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("Z"))
			User << "Only the bearer of The Zombie can trade flesh."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		if(!User.QuincyZombiesLive().len)
			User << "You have no zombie to carry the wounds."
			return 0
		var/list/allies = User.ZombieFleshAllies()
		if(!allies.len)
			User << "No one in view carries a wound or a maim."
			return 0
		var/mob/ally
		if(allies.len == 1)
			ally = allies[1]
		else
			var/list/labels = PromptLabelAtoms(allies, 1)
			var/pick = Ask(User, "Whose wounds do you take?", "Flesh Trade", null, "pick", labels, 1)
			if(isnull(pick))
				return 0
			ally = labels[pick]
		if(!ally || !(ally in User.ZombieFleshAllies()))
			return 0
		var/mob/Player/AI/Quincy_Zombie/z = User.ZombiePickOne("Which zombie carries them?")
		if(!z)
			return 0
		if(!User.ZombieFleshTrade(ally, z))
			return 0
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Consume_Zombie
	name = "Consume Zombie"
	desc = "Once per fight: drink the blood back out of one of your zombies. It crumbles and you heal 30 percent."
	Cooldown = -1
	Copyable = 0
	var/heal = QUINCY_Z_MEND_PCT

	verb/Consume_Zombie()
		set name = "Consume Zombie"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		ConsumeFire(User)

	proc/ConsumeFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("Z"))
			User << "Only the bearer of The Zombie can do this."
			return 0
		if(src.Using)
			User << "You have already fed on a zombie in this fight."
			return 0
		var/mob/Player/AI/Quincy_Zombie/z = User.ZombiePickOne("Which zombie do you consume?")
		if(!z)
			User << "You have no zombie to consume."
			return 0
		if(!User.ZombieConsume(z, src.heal))
			return 0
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Dancing_Dead_Boys_Club
	name = "Dancing Dead Boys Club"
	desc = "In Azhalbiora only: three skeletons rise and brawl beside you for 20 seconds."
	Cooldown = 60
	Copyable = 0
	var/count = QUINCY_Z_SKELETONS
	var/seconds = QUINCY_Z_SKELETON_TIME

	verb/Dancing_Dead_Boys_Club()
		set name = "Dancing Dead Boys Club"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		ClubFire(User)

	proc/ClubFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("Z"))
			User << "Only the bearer of The Zombie can call the dead to dance."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "The dead dance only in Azhalbiora."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		if(!User.ZombieSkeletons(src.count, src.seconds))
			return 0
		src.Cooldown(1, null, User)
		return 1

/proc/QuincyTestStepsZ()
	return list("Arm Blood", "Mark target 3 times", "Raise target as zombie", "Consume a zombie", "Skeletons", "Flesh Trade self")

/mob/proc/QuincyTestZ(step, mob/t)
	switch(step)
		if("Arm Blood")
			src.BloodArmedUntil = world.time + QUINCY_Z_BLOOD_TIME
			return "armed"
		if("Mark target 3 times")
			if(!t)
				return "no target"
			for(var/i = 1 to QUINCY_Z_RISE_NEED)
				t.ZombieMark(src)
			return "marks [t.ZombieStacksNow()]"
		if("Raise target as zombie")
			if(!t)
				return "no target"
			var/mob/Player/AI/Quincy_Zombie/z = ZombieRaise(t)
			return z ? "raised [z]" : "failed"
		if("Consume a zombie")
			var/list/live = QuincyZombiesLive()
			if(!live.len)
				return "no zombie"
			return "consumed [ZombieConsume(live[1], QUINCY_Z_MEND_PCT)]"
		if("Skeletons")
			return "skeletons [ZombieSkeletons(QUINCY_Z_SKELETONS, QUINCY_Z_SKELETON_TIME)]"
		if("Flesh Trade self")
			var/list/live = QuincyZombiesLive()
			if(!live.len)
				return "no zombie"
			return "traded [ZombieFleshTrade(src, live[1])]"
	return "unknown step"

#define QUINCY_S_RANGE 8
#define QUINCY_S_HEAL 2
#define QUINCY_S_STAR_EVERY 5
#define QUINCY_S_STAR_MAX 5
#define QUINCY_S_STAR_MAGNIFY 0.05
#define QUINCY_S_LINK_PCT 25
#define QUINCY_S_LINK_COST 50
#define QUINCY_S_MAX_ALIVE 4
#define QUINCY_S_SPLIT_GENS 2
#define QUINCY_S_SPLIT_HEALTH 50
#define QUINCY_S_LEASH 12
#define QUINCY_S_PUNCH_FULL 10

mob/var/StarStacks = 0
mob/var/SuperstarSleep = 0
mob/var/tmp/StarProgress = 0
mob/var/tmp/list/SuperstarJameses
mob/var/tmp/SuperstarGen = 0
mob/var/tmp/SuperstarLoopOn = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S_The_Superstar/New()
	..()
	kit_skills = list(/obj/Skills/Companion/Quincy/James, /obj/Skills/Projectile/Quincy/Star_Flash, /obj/Skills/Queue/Quincy/Star_Lariat, /obj/Skills/AutoHit/Quincy/Star_Rocket_Headbutt, /obj/Skills/AutoHit/Quincy/Star_Satsujin_Punch, /obj/Skills/AutoHit/Quincy/Super_Nova)

/obj/Skills/Companion/Quincy

/obj/Skills/Companion/Quincy/James
	name = "James"
	desc = "Call James to your side. While a living James stands within 8 tiles he cheers: you heal 2 percent a second, and every 5 seconds of fighting earns a Star (up to 5), each worth 5 percent more Strength and Speed. Knocked out while James lives, you get back up at 25 percent and James loses half his health. A James who falls comes back as two smaller Jameses, twice over, never more than 4 at once. When every James is gone, The Superstar falls silent until you meditate."
	Copyable = 0
	Cooldown = 60
	companion_name = "James"
	companion_icon = 'Makyo1.dmi'
	companion_potential = -1
	companion_ko_death = 1
	companion_team_fire = 0
	var/james_potential_share = 0.5
	var/james_stat_share = 0.5
	var/list/james_scales = list(1, 0.5, 0.35)
	var/james_pixel_x = 0
	var/james_pixel_y = 0

	New()
		..()
		verbs -= list(/obj/Skills/Companion/verb/Companion_Summon, /obj/Skills/Companion/verb/Companion_Attack, /obj/Skills/Companion/verb/Companion_Stop, /obj/Skills/Companion/verb/Companion_Follow, /obj/Skills/Companion/verb/Companion_Focus_Target, /obj/Skills/Companion/verb/Companion_Mode, /obj/Skills/Companion/verb/Companion_Def, /obj/Skills/Companion/verb/Companion_Stay, /obj/Skills/Companion/verb/CustomizeCompanion)

	verb/Summon_James()
		set name = "Summon James"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(ismob(User))
			User.SuperstarSummon(src)

	proc/JamesScale(gen)
		if(!james_scales || !james_scales.len)
			return 1
		return james_scales[clamp(gen + 1, 1, james_scales.len)]

	proc/JamesSpawn(mob/P, turf/T, gen, pct)
		if(!ismob(P) || !T)
			return null
		var/mob/Player/AI/Quincy_James/a = new
		ticking_ai.Remove(a)
		a.alpha = 0
		a.loc = T
		animate(a, alpha = 255, time = 10)
		a.ai_owner = P
		a.james_skill = src
		a.james_gen = gen
		a.ai_follow = 1
		a.name = companion_name
		a.icon = companion_icon
		a.icon_state = ""
		a.pixel_x = james_pixel_x
		a.pixel_y = james_pixel_y
		var/s = JamesScale(gen)
		if(s != 1)
			var/matrix/M = matrix()
			M.Scale(s)
			a.transform = M
		a.ai_hostility = 0
		a.ai_focus_owner_target = 0
		a.ai_protection = 0
		a.companion_def_mode = 0
		a.prev_owner_health = P.Health
		a.ai_spammer = 0
		a.ko_death = companion_ko_death
		a.Timeless = 1
		a.ai_team_fire = companion_team_fire
		a.ai_alliances = P.SuperstarAlliances()
		a.StrMod = round(james_stat_share * (P.StrMod + P.StrAscension), 0.001)
		a.EndMod = round(james_stat_share * (P.EndMod + P.EndAscension), 0.001)
		a.ForMod = round(james_stat_share * (P.ForMod + P.ForAscension), 0.001)
		a.OffMod = round(james_stat_share * (P.OffMod + P.OffAscension), 0.001)
		a.DefMod = round(james_stat_share * (P.DefMod + P.DefAscension), 0.001)
		a.SpdMod = round(james_stat_share * (P.SpdMod + P.SpdAscension), 0.001)
		a.VitMod = a.EndMod
		a.RecovMod = P.RecovMod
		a.AngerMax = P.AngerMax
		a.Potential = P.Potential * james_potential_share
		P.ai_followers += a
		if(!P.SuperstarJameses)
			P.SuperstarJameses = list()
		P.SuperstarJameses += a
		companion_ais += a
		a.aiGain()
		a.SetHealthPct(pct)
		P.SuperstarLoop()
		return a

/mob/Player/AI/Quincy_James
	var/tmp/obj/Skills/Companion/Quincy/James/james_skill
	var/tmp/james_gen = 0
	var/tmp/james_gone = 0

	Update()
		set waitfor = 0
		if(james_gone)
			return
		var/mob/P = ai_owner
		if(KO || Health <= 0)
			if(ismob(P))
				P.SuperstarFall(src)
			else
				JamesDespawn()
			return
		if(!JamesKeeps())
			JamesDespawn()
			return
		JamesLeash()
		..()

	Del()
		JamesForget()
		companion_ais -= src
		..()

	Chase()
		RemoveTarget()
		ai_state = "Idle"

	proc/JamesAlive()
		return !james_gone && loc && !KO && !Dead && Health > 0

	proc/JamesKeeps()
		var/mob/P = ai_owner
		if(!ismob(P) || Dead || !loc)
			return 0
		if(!P.SuperstarJameses || !(src in P.SuperstarJameses))
			return 0
		if(P.Dead || (!P.client && P.key))
			return 0
		if(!james_skill || james_skill.loc != P || !P.SchriftNeeded("S"))
			return 0
		return 1

	proc/JamesForget()
		var/mob/P = ai_owner
		if(ismob(P))
			P.ai_followers -= src
			if(P.SuperstarJameses)
				P.SuperstarJameses -= src

	proc/JamesDespawn()
		if(james_gone)
			return
		james_gone = 1
		JamesForget()
		companion_ais -= src
		ticking_ai -= src
		ai_owner = null
		RemoveTarget()
		animate(src, alpha = 0, time = 10)
		spawn(10)
			if(src)
				del src

	proc/JamesLeash()
		var/mob/P = ai_owner
		if(hold_position)
			return
		if(P.z == z && get_dist(src, P) <= QUINCY_S_LEASH)
			return
		var/turf/T = P.SuperstarSpot()
		if(!T)
			T = get_turf(P)
		if(!T)
			return
		loc = T
		step_x = 0
		step_y = 0
		RemoveTarget()
		ai_state = "Idle"

/mob/proc/SuperstarAlliances()
	var/list/out = list()
	if(src.ckey)
		out += "[src.ckey]"
	if(src.party && src.party.members)
		for(var/mob/m in src.party.members)
			if(m.ckey)
				out |= "[m.ckey]"
	return out

/mob/proc/SuperstarSpot()
	var/list/dirs = list(src.dir, NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	for(var/d in dirs)
		if(!d)
			continue
		var/turf/T = get_step(src, d)
		if(!T || T.density)
			continue
		var/open = 1
		for(var/atom/movable/A in T)
			if(A.density)
				open = 0
				break
		if(open)
			return T
	return null

/mob/proc/SuperstarAlive()
	var/list/out = list()
	if(!src.SuperstarJameses)
		return out
	for(var/mob/Player/AI/Quincy_James/j in src.SuperstarJameses.Copy())
		if(j.JamesAlive())
			out += j
	return out

/mob/proc/SuperstarCount()
	var/list/L = SuperstarAlive()
	return L.len

/mob/proc/SuperstarNear()
	var/list/out = list()
	for(var/mob/Player/AI/Quincy_James/j in SuperstarAlive())
		if(j.z == src.z && get_dist(src, j) <= QUINCY_S_RANGE)
			out += j
	return out

/mob/proc/SuperstarSummon(obj/Skills/Companion/Quincy/James/S)
	if(!S || src.KO)
		return 0
	if(!SchriftNeeded("S"))
		src << "Only the bearer of The Superstar can call James."
		return 0
	if(src.SuperstarSleep)
		src << "The Superstar is silent. Meditate to wake it."
		return 0
	if(SuperstarCount())
		src << "James is already here."
		return 0
	if(S.Using || S.cooldown_remaining > 0)
		src << "[S] is on cooldown."
		return 0
	var/turf/T = SuperstarSpot()
	if(!T)
		src << "There is no room beside you for James."
		return 0
	if(!S.JamesSpawn(src, T, 0, 100))
		return 0
	S.Cooldown(1, null, src)
	OMsg(src, "[src] calls for James! James bounds in, cheering wildly.")
	return 1

/mob/proc/SuperstarFall(mob/Player/AI/Quincy_James/j)
	if(!j || j.james_gone)
		return 0
	var/turf/T = get_turf(j)
	var/gen = j.james_gen
	var/obj/Skills/Companion/Quincy/James/S = j.james_skill
	j.JamesDespawn()
	var/made = 0
	if(T && S && S.loc == src && gen < QUINCY_S_SPLIT_GENS && SchriftNeeded("S") && !src.SuperstarSleep)
		for(var/i = 1 to 2)
			if(SuperstarCount() >= QUINCY_S_MAX_ALIVE)
				break
			if(S.JamesSpawn(src, T, gen + 1, QUINCY_S_SPLIT_HEALTH))
				made++
	if(made)
		OMsg(src, "James falls... and [made == 1 ? "a smaller James springs" : "two smaller Jameses spring"] up in his place!")
	else if(!SuperstarCount())
		SuperstarSilence()
	else
		OMsg(src, "A James falls.")
	return made

/mob/proc/SuperstarSilence()
	if(!SchriftNeeded("S"))
		return
	src.SuperstarSleep = 1
	StarClear()
	OMsg(src, "Every James has fallen. The Superstar goes silent.")
	src << "<font color=#ffd23a>The Superstar sleeps until you meditate.</font>"

/mob/proc/SuperstarDismiss()
	if(!src.SuperstarJameses)
		return
	for(var/mob/Player/AI/Quincy_James/j in src.SuperstarJameses.Copy())
		j.JamesDespawn()
	src.SuperstarJameses = null

/mob/proc/StarAdd()
	if(src.StarStacks >= QUINCY_S_STAR_MAX)
		return 0
	src.StarStacks++
	src.passive_handler.Increase("MagnifiedStr", QUINCY_S_STAR_MAGNIFY)
	src.passive_handler.Increase("MagnifiedSpd", QUINCY_S_STAR_MAGNIFY)
	src << "<font color=#ffd23a>James cheers! Stars: [src.StarStacks].</font>"
	return 1

/mob/proc/StarClear()
	if(src.StarStacks > 0)
		src.passive_handler.Decrease("MagnifiedStr", QUINCY_S_STAR_MAGNIFY * src.StarStacks)
		src.passive_handler.Decrease("MagnifiedSpd", QUINCY_S_STAR_MAGNIFY * src.StarStacks)
	src.StarStacks = 0
	src.StarProgress = 0

/mob/proc/SuperstarStrength()
	var/list/alive = SuperstarAlive()
	if(!alive.len)
		return 0
	var/list/near = SuperstarNear()
	return near.len / alive.len

/mob/proc/SuperstarLoop()
	set waitfor = 0
	if(src.SuperstarLoopOn)
		return
	src.SuperstarLoopOn = 1
	var/gen = ++src.SuperstarGen
	while(src && src.SuperstarGen == gen)
		sleep(10)
		if(!src || src.SuperstarGen != gen)
			return
		if(!SuperstarCount() || !SchriftNeeded("S"))
			if(src.StarStacks)
				StarClear()
			break
		SuperstarCheer()
	if(src && src.SuperstarGen == gen)
		src.SuperstarLoopOn = 0

/mob/proc/SuperstarCheer()
	var/power = SuperstarStrength()
	if(power > 0 && !src.KO)
		HealPct(QUINCY_S_HEAL * power)
		MaxHealth()
	if(QuincyFightIdle())
		if(src.StarStacks)
			StarClear()
		src.StarProgress = 0
		return power
	if(power > 0 && src.StarStacks < QUINCY_S_STAR_MAX)
		src.StarProgress += power
		if(src.StarProgress >= QUINCY_S_STAR_EVERY)
			src.StarProgress -= QUINCY_S_STAR_EVERY
			StarAdd()
	return power

/mob/proc/SuperstarLinkJames()
	var/mob/Player/AI/Quincy_James/best
	for(var/mob/Player/AI/Quincy_James/j in SuperstarNear())
		if(!best || j.HealthPct() > best.HealthPct())
			best = j
	return best

/mob/proc/SuperstarCanLink(mob/P)
	if(src.SuperstarSleep || src.NoVoid || !SchriftNeeded("S"))
		return 0
	if(ismob(P) && P != src && P.Lethal)
		return 0
	return SuperstarLinkJames() ? 1 : 0

/mob/proc/SuperstarLink(mob/P)
	var/mob/Player/AI/Quincy_James/j = SuperstarLinkJames()
	if(!j)
		return 0
	src.SetHealthPct(QUINCY_S_LINK_PCT)
	src.MaxHealth()
	src.OMessage(15, "James cheers, and [src] gets back up!", "<font color=red>[src]([src.key]) gets back up through The Superstar's Life Link.")
	var/left = j.HealthPct() - QUINCY_S_LINK_COST
	if(left <= 0)
		j.SetHealthPct(0)
		SuperstarFall(j)
	else
		j.SetHealthPct(left)
	return 1

/mob/Players/Unconscious(mob/P, text)
	if(SuperstarCanLink(P))
		SuperstarLink(P)
		return
	return ..()

/mob/Players/CinderTollReset()
	..()
	if(src.SuperstarSleep)
		src.SuperstarSleep = 0
		src << "<font color=#ffd23a>The Superstar wakes. James is ready to cheer again.</font>"

/mob/Players/QuincySyncSkills()
	..()
	if(!SchriftNeeded("S"))
		if(src.SuperstarJameses)
			SuperstarDismiss()
		if(src.StarStacks)
			StarClear()
		src.SuperstarSleep = 0

/mob/Players/Login()
	..()
	spawn(40)
		if(src && src.StarStacks && !SuperstarCount())
			StarClear()

/obj/Skills/Projectile/Quincy/Star_Flash
	name = "Star Flash"
	desc = "Strike a pose and fire a beam of star-shaped Reishi."
	DamageMult = 1.6
	Cooldown = 15
	Distance = 15
	Speed = 0.2
	Variation = 0
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	ActiveMessage = "strikes a pose. Star Flash!"

	verb/Star_Flash()
		set name = "Star Flash"
		set category = "Skills"
		if(!usr.SchriftNeeded("S"))
			usr << "Only the bearer of The Superstar can fire Star Flash."
			return
		usr.UseProjectile(src)

/obj/Skills/Queue/Quincy/Star_Lariat
	name = "Star Lariat"
	desc = "Your next blow is a running lariat that throws the target 3 tiles."
	DamageMult = 1.5
	KBAdd = 3
	Cooldown = 20
	Copyable = 0
	HitMessage = "clotheslines their foe with a Star Lariat!"

	Use(mob/user, noGCD = FALSE)
		if(ismob(user) && !user.SchriftNeeded("S"))
			user << "Only the bearer of The Superstar can throw a Star Lariat."
			return 0
		return ..()

	verb/Star_Lariat()
		set name = "Star Lariat"
		set category = "Skills"
		if(!usr.SchriftNeeded("S"))
			usr << "Only the bearer of The Superstar can throw a Star Lariat."
			return
		usr.SetQueue(src)

/obj/Skills/AutoHit/Quincy/Star_Rocket_Headbutt
	name = "Star Rocket Headbutt"
	desc = "Rocket into your target headfirst and stun them."
	Area = "Target"
	Rush = 1
	DamageMult = 1.8
	Stunner = 1
	Cooldown = 25
	Copyable = 0
	ActiveMessage = "rockets in headfirst!"

	verb/Star_Rocket_Headbutt()
		set name = "Star Rocket Headbutt"
		set category = "Skills"
		if(!usr.SchriftNeeded("S"))
			usr << "Only the bearer of The Superstar can rocket like this."
			return
		usr.Activate(src)

/obj/Skills/AutoHit/Quincy/Star_Satsujin_Punch
	name = "Star Satsujin Punch"
	desc = "A single killing punch. At five Stars it hits ten times as hard."
	Area = "Target"
	DamageMult = 2
	Cooldown = 45
	Copyable = 0
	ActiveMessage = "throws the Star Satsujin Punch!"
	var/full_star_mult = QUINCY_S_PUNCH_FULL

	adjust(mob/p)
		DamageMult = initial(DamageMult)
		if(p && p.StarStacks >= QUINCY_S_STAR_MAX)
			DamageMult *= full_star_mult

	verb/Star_Satsujin_Punch()
		set name = "Star Satsujin Punch"
		set category = "Skills"
		if(!usr.SchriftNeeded("S"))
			usr << "Only the bearer of The Superstar can throw this punch."
			return
		usr.Activate(src)

/obj/Skills/AutoHit/Quincy/Super_Nova
	name = "Super Nova"
	desc = "In Vollstandig only: rush in and burst like a dying star around you."
	Area = "Circle"
	Distance = 3
	DamageMult = 3
	Rush = 1
	Cooldown = 90
	Copyable = 0
	ActiveMessage = "goes supernova!"

	verb/Super_Nova()
		set name = "Super Nova"
		set category = "Skills"
		if(!usr.SchriftNeeded("S"))
			usr << "Only the bearer of The Superstar can go supernova."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "Super Nova answers only in Vollstandig."
			return
		usr.Activate(src)

/proc/QuincyTestStepsS()
	return list("Summon James", "Fell a James", "Five stars", "Knock me out", "Wake the letter", "Read the Jameses")

/mob/proc/QuincyTestS(step, mob/t)
	switch(step)
		if("Summon James")
			var/obj/Skills/Companion/Quincy/James/J = locate() in src
			if(!J)
				return "no James skill (engrave S first)"
			if(src.SuperstarSleep)
				return "the letter sleeps; wake it first"
			if(SuperstarCount())
				return "James is already here"
			var/turf/T = SuperstarSpot()
			if(!T)
				T = get_turf(src)
			var/mob/j = J.JamesSpawn(src, T, 0, 100)
			return "summoned [j ? 1 : 0], alive [SuperstarCount()]"
		if("Fell a James")
			var/list/alive = SuperstarAlive()
			if(!alive.len)
				return "no living James"
			var/mob/Player/AI/Quincy_James/j = alive[1]
			j.SetHealthPct(0)
			var/made = SuperstarFall(j)
			return "split into [made], alive [SuperstarCount()], asleep [src.SuperstarSleep]"
		if("Five stars")
			src.QuincyFightAt = world.time
			while(src.StarStacks < QUINCY_S_STAR_MAX)
				if(!StarAdd())
					break
			return "stars [src.StarStacks]"
		if("Knock me out")
			if(!SuperstarCanLink(null))
				return "no Life Link ready (hold S, awake, a living James within 8 tiles)"
			SetHealthPct(0)
			Unconscious(null, "testing The Superstar")
			return "health [round(HealthPct())] KO [src.KO]"
		if("Wake the letter")
			CinderTollReset()
			return "asleep [src.SuperstarSleep]"
		if("Read the Jameses")
			var/list/rows = list()
			for(var/mob/Player/AI/Quincy_James/j in SuperstarAlive())
				rows += "gen [j.james_gen] at [round(j.HealthPct())] percent, [get_dist(src, j)] tiles"
			return "[rows.len] alive, strength [SuperstarStrength()], stars [src.StarStacks], asleep [src.SuperstarSleep][rows.len ? ": [jointext(rows, "; ")]" : ""]"
	return "unknown step"

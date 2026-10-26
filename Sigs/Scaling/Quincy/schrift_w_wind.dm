#define QUINCY_WIND_FAST 0.2
#define QUINCY_WIND_TURN_EVERY 50
#define QUINCY_WIND_WARD_TIME 600
#define QUINCY_WIND_SIGHT_TICK 10
#define QUINCY_WIND_IDLE 300
#define QUINCY_WIND_NAG 10
#define QUINCY_WIND_BEND_MIN 60
#define QUINCY_WIND_BEND_MAX 120
#define QUINCY_TWIST_MAIM 25

obj/Skills/Projectile/_Projectile/var/tmp/WindBent = 0

mob/var/tmp/list/WindSeen
mob/var/tmp/WindSeenAt = 0
mob/var/tmp/WindTurnAt = 0
mob/var/tmp/mob/WindWard
mob/var/tmp/WindWardUntil = 0
mob/var/tmp/WindWardSerial = 0
mob/var/tmp/image/WindWardMark
mob/var/tmp/mob/WardedBy
mob/var/tmp/WindSightGen = 0
mob/var/tmp/WindNagAt = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/W_The_Wind/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Shield_Ward, /obj/Skills/AutoHit/Quincy/Twist)

/proc/QuincyWindBehind(face, travel)
	if(!face || !travel)
		return 0
	return travel == face || travel == turn(face, 45) || travel == turn(face, -45)

/proc/QuincyShotTravel(obj/Skills/Projectile/_Projectile/P)
	if(!isnull(P.FlightAngle))
		return GunAngleDir(P.FlightAngle)
	return P.dir

/proc/QuincyWindName(t)
	if(t == "melee")
		return "a bare swing"
	if(ispath(t, /obj/Skills))
		var/obj/Skills/s = t
		return "[initial(s.name)]"
	return "[t]"

/mob/proc/WindHolds()
	return src.QuincySchrift == "W" && SchriftNeeded("W")

/mob/proc/WindFacing()
	return DisplayedCardinal(src.dir, 0)

/mob/proc/WindSeenNow()
	if(src.WindSeen && QuincyFightIdle() && world.time - src.WindSeenAt >= QUINCY_WIND_IDLE)
		src.WindSeen = null
	return src.WindSeen

/mob/proc/WindSee(t)
	if(!t)
		return 0
	WindSeenNow()
	src.WindSeenAt = world.time
	if(!src.WindSeen)
		src.WindSeen = list()
	if(t in src.WindSeen)
		return 0
	src.WindSeen += t
	return 1

/mob/proc/WindKnows(t)
	if(!t)
		return 0
	var/list/L = WindSeenNow()
	if(!L)
		return 0
	return (t in L) ? 1 : 0

/mob/proc/WindWardOn()
	return ismob(src.WindWard) && src.WindWardUntil > world.time

/mob/proc/WindGuardian()
	if(WindHolds())
		return src
	var/mob/g = src.WardedBy
	if(ismob(g) && g.WindWard == src && g.WindWardOn() && g.WindHolds())
		return g
	return null

/mob/proc/WindProtector()
	if(src.KO)
		return null
	if(WindHolds())
		return WindWardOn() ? null : src
	var/mob/g = src.WardedBy
	if(ismob(g) && g.WindWard == src && g.WindWardOn() && !g.KO && g.WindHolds())
		return g
	return null

/mob/proc/WindBends(obj/Skills/Projectile/_Projectile/P)
	var/mob/o = P.Owner
	if(!ismob(o) || o == src || !QuincyAreaFoe(o, src))
		return 0
	var/obj/Skills/fs = P.from_skill
	if(!istype(fs, /obj/Skills) || !WindKnows(fs.type))
		return 0
	if(P.Speed <= QUINCY_WIND_FAST && !QuincyVollstandigOnNow())
		return 0
	if(QuincyWindBehind(WindFacing(), QuincyShotTravel(P)))
		return 0
	return 1

/mob/proc/WindBend(obj/Skills/Projectile/_Projectile/P, mob/who)
	P.WindBent = 1
	P.Homing = 0
	P.forcedTarget = null
	P.HyperHoming = 0
	if(P.Area != "Beam")
		if(isnull(P.FlightAngle))
			P.dir = turn(P.dir, pick(90, -90, 135, -135))
		else
			var/a = P.FlightAngle + pick(1, -1) * rand(QUINCY_WIND_BEND_MIN, QUINCY_WIND_BEND_MAX)
			while(a < 0)
				a += 360
			while(a >= 360)
				a -= 360
			P.FlightAngle = a
			P.dir = GunAngleDir(a)
	if(src.WindNagAt <= world.time)
		src.WindNagAt = world.time + QUINCY_WIND_NAG
		OMsg(who ? who : src, "The Wind turns it aside.")

/mob/proc/WindSightLoop()
	set waitfor = 0
	var/gen = ++src.WindSightGen
	while(src && src.WindSightGen == gen && WindHolds())
		sleep(QUINCY_WIND_SIGHT_TICK)
		if(!src || src.WindSightGen != gen)
			return
		if(src.WindWard && !WindWardOn())
			WindWardEnd()
		if(src.KO)
			continue
		for(var/mob/m in view(QuincyViewReach(), src))
			if(m == src || !QuincyAreaFoe(m, src))
				continue
			if(m.held_skill)
				WindSee(m.held_skill.type)
			if(m.AttackQueue)
				WindSee(m.AttackQueue.type)
	if(src && src.WindSightGen == gen && src.WindWard)
		WindWardEnd()

/mob/proc/WindWardChoices()
	var/list/out = list()
	for(var/mob/Players/P in view(QuincyViewReach(), src))
		if(P == src || !P.ckey || P.KO)
			continue
		if(!src.inParty(P.ckey))
			continue
		out += P
	return out

/mob/proc/WindWardStart(mob/t, ds)
	WindWardEnd(1)
	if(ismob(t.WardedBy))
		var/mob/old = t.WardedBy
		if(old != src && old.WindWard == t)
			old.WindWardEnd()
	src.WindWard = t
	src.WindWardUntil = world.time + ds
	var/serial = ++src.WindWardSerial
	t.WardedBy = src
	if(src.client)
		var/obj/Skills/Quincy/Shield_Ward/W = /obj/Skills/Quincy/Shield_Ward
		var/image/I = image(initial(W.ward_icon), t, null, initial(W.ward_layer))
		src.WindWardMark = I
		src.client.images += I
	src << "<font color=#9fd8ff>The Wind wraps around [t]. Attacks it has seen will bend away from them, not from you.</font>"
	t << "<font color=#9fd8ff>[src]'s Wind wraps around you.</font>"
	WindWardTimer(serial, src.WindWardUntil)
	return 1

/mob/proc/WindWardTimer(serial, until)
	set waitfor = 0
	sleep(max(1, until - world.time))
	if(src && src.WindWardSerial == serial)
		WindWardEnd()

/mob/proc/WindWardEnd(quiet = 0)
	var/mob/t = src.WindWard
	src.WindWard = null
	src.WindWardUntil = 0
	src.WindWardSerial++
	if(src.WindWardMark)
		if(src.client)
			src.client.images -= src.WindWardMark
		src.WindWardMark = null
	if(!ismob(t))
		return 0
	if(t.WardedBy == src)
		t.WardedBy = null
	if(!quiet)
		src << "<font color=#9fd8ff>The Wind leaves [t].</font>"
		t << "<font color=#9fd8ff>[src]'s Wind leaves you.</font>"
	return 1

/mob/Players/GunIntercept(obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(. || !P || P.WindBent)
		return
	var/mob/g = WindProtector()
	if(!g || !g.WindBends(P))
		return
	g.WindBend(P, src)
	return 1

/mob/Players/QuincyRollDefend(mob/o, melee)
	. = ..()
	if(. || !melee || !ismob(o) || src.KO)
		return
	if(!WindHolds() || WindWardOn())
		return
	if(src.WindTurnAt > world.time)
		return
	var/t = o.AttackQueue ? o.AttackQueue.type : "melee"
	if(!WindKnows(t))
		return
	if(QuincyWindBehind(WindFacing(), GunAngleDir(QuincyAimAngle(o, src))))
		return
	if(src.IsGuarding() || src.passive_handler.Get("NoDodge"))
		return
	src.WindTurnAt = world.time + QUINCY_WIND_TURN_EVERY
	src.SureDodge = 1
	OMsg(src, "The Wind turns [o]'s blow aside.")

/mob/getMeleeKnockback(mob/enemy)
	. = ..()
	QuincyMeleeFrom = src
	QuincyMeleeTo = enemy

/mob/Players/QuincySyncSkills()
	..()
	if(WindHolds())
		WindSightLoop()
	else
		src.WindSightGen++
		src.WindSeen = null
		if(src.WindWard)
			WindWardEnd()

/mob/Players/Login()
	..()
	spawn(40)
		if(src && WindHolds())
			WindSightLoop()

/mob/Players/Logout()
	if(src.WindWard)
		WindWardEnd(1)
	if(ismob(src.WardedBy))
		var/mob/g = src.WardedBy
		if(g.WindWard == src)
			g.WindWardEnd()
	..()

/strikeHook/quincyWindSeen
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d)
			return
		var/mob/g = d.WindGuardian()
		if(!g || !QuincyAreaFoe(a, g))
			return
		var/t = istype(S.skill, /obj/Skills) ? S.skill.type : (S.melee ? "melee" : null)
		if(t && g.WindSee(t))
			g << "<font color=#9fd8ff>The Wind has seen [QuincyWindName(t)].</font>"

/strikeHook/quincyTwist
	stage = "post"
	fire(strike/S)
		if(!istype(S.skill, /obj/Skills/AutoHit/Quincy/Twist))
			return
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		var/obj/Skills/AutoHit/Quincy/Twist/T = S.skill
		if(!prob(T.maim_chance))
			return
		var/part = d.QuincyMaimOnce(a)
		if(part)
			OMsg(d, "The Wind wrenches [d]'s [part]!")

/obj/Skills/Quincy/Shield_Ward
	name = "Shield Ward"
	desc = "Wrap a party member in view in The Wind for 60 seconds: attacks it has seen bend away from them. One ward at a time, and you are not protected while you ward. Press again to end the ward."
	Cooldown = 15
	Copyable = 0
	var/seconds = QUINCY_WIND_WARD_TIME
	var/ward_icon = 'Icons/Effects/SparkleArcane.dmi'
	var/ward_layer = FLY_LAYER

	verb/Shield_Ward()
		set name = "Shield Ward"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		WardFire(User)

	proc/WardFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.WindHolds())
			User << "Only the bearer of The Wind can ward another."
			return 0
		if(User.WindWardOn())
			User.WindWardEnd()
			return 1
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/list/c = User.WindWardChoices()
		if(!c.len)
			User << "No party member stands in view."
			return 0
		var/list/lab = PromptLabelAtoms(c, 1)
		var/pick = Ask(User, "Who does the Wind protect?", "Shield Ward", null, "pick", lab, 1)
		if(isnull(pick))
			return 0
		var/mob/t = lab[pick]
		if(!t || !(t in User.WindWardChoices()) || !User.WindHolds())
			return 0
		User.WindWardStart(t, src.seconds)
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/AutoHit/Quincy/Twist
	name = "Twist"
	desc = "The Wind bends your target's body: a guard-breaking twist that opens a bleeding wound and may maim."
	Area = "Target"
	Distance = 3
	ForScaling = 1
	DamageMult = 1.2
	GuardBreak = 1
	Bloodletting = 2
	Cooldown = 20
	ManaCost = 5
	Copyable = 0
	ActiveMessage = "bends the air around their target!"
	var/maim_chance = QUINCY_TWIST_MAIM

	verb/Twist()
		set name = "Twist"
		set category = "Skills"
		if(!usr.WindHolds())
			usr << "Only the bearer of The Wind can twist a body."
			return
		usr.Activate(src)

/proc/QuincyTestStepsW()
	return list("See target's queue or melee", "See Gunfire", "Show seen", "Ward target", "End ward", "Clear seen")

/mob/proc/QuincyTestW(step, mob/t)
	switch(step)
		if("See target's queue or melee")
			var/k = (t && t.AttackQueue) ? t.AttackQueue.type : "melee"
			WindSee(k)
			return "seen [QuincyWindName(k)]"
		if("See Gunfire")
			WindSee(/obj/Skills/Projectile/Gunfire)
			return "seen Gunfire"
		if("Show seen")
			var/list/L = WindSeenNow()
			if(!L || !L.len)
				return "nothing seen"
			var/out = ""
			for(var/k in L)
				out += "[QuincyWindName(k)]; "
			return out
		if("Ward target")
			if(!t)
				return "no target"
			return "warded [WindWardStart(t, QUINCY_WIND_WARD_TIME)]"
		if("End ward")
			return "ended [WindWardEnd()]"
		if("Clear seen")
			src.WindSeen = null
			return "cleared"
	return "unknown step"

#define QUINCY_DOSE_MAX 5
#define QUINCY_DOSE_LIFE 200
#define QUINCY_DOSE_PCT 2
#define QUINCY_DOSE_PER 10
#define QUINCY_DOSE_NAG 30
#define QUINCY_IMMUNE_HITS 3
#define QUINCY_IMMUNE_TIME 600
#define QUINCY_BEREICH_RADIUS 4
#define QUINCY_BEREICH_TIME 120
#define QUINCY_BEREICH_POSTS 6
#define QUINCY_DELUXE_RADIUS 6
#define QUINCY_DELUXE_TICK 20
#define QUINCY_DELUXE_TIME 100
#define QUINCY_RING_NEED 5
#define QUINCY_RING_PCT 25

mob/var/tmp/DoseStacks = 0
mob/var/tmp/DoseResource
mob/var/tmp/DoseAt = 0
mob/var/tmp/mob/DoseBy
mob/var/tmp/DoseNagAt = 0
mob/var/tmp/GiftNagAt = 0
mob/var/tmp/list/DeathdealingHits
mob/var/tmp/list/DeathdealingImmune
mob/var/tmp/DeathdealingGen = 0

var/list/QuincyGiftRings

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/D_The_Deathdealing/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/Gift_Ball, /obj/Skills/Quincy/Gift_Bereich, /obj/Skills/Quincy/Gift_Ball_Deluxe, /obj/Skills/Quincy/Gift_Ring)

/obj/Effects/Quincy_Gift_Ring
	name = "Gift Bereich"
	icon = 'Icons/Effects/SparkleArcane.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0

/obj/Effects/Quincy_Gift_Zone
	name = "Gift Ball Deluxe"
	icon = 'Icons/Effects/SparkleArcane.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0

/datum/QuincyGiftRing
	var/turf/center
	var/radius = QUINCY_BEREICH_RADIUS
	var/until = 0
	var/mob/owner
	var/list/posts

/mob/proc/DoseNow()
	if(src.DoseStacks && world.time - src.DoseAt >= QUINCY_DOSE_LIFE)
		DoseClear()
	return src.DoseStacks

/mob/proc/DoseClear()
	src.DoseStacks = 0
	src.DoseResource = null
	src.DoseAt = 0
	src.DoseBy = null

/proc/QuincyDoseResourceOf(mob/m)
	var/t = QuincyLastSkillType(m)
	if(!ispath(t, /obj/Skills))
		return "Energy"
	if(ispath(t, /obj/Skills/Projectile/Gunfire))
		return istype(m.EquippedGun(), /obj/Items/Gun/Quincy) ? "Mana" : "Energy"
	var/obj/Skills/S = t
	return initial(S.ManaCost) > 0 ? "Mana" : "Energy"

/mob/proc/DoseAdd(mob/by, quiet = 0)
	var/n = DoseNow()
	if(!n)
		src.DoseResource = QuincyDoseResourceOf(src)
	src.DoseStacks = min(QUINCY_DOSE_MAX, n + 1)
	src.DoseAt = world.time
	src.DoseBy = by
	if(!n)
		src << "<font color=#b07cff>Poison seeps into your [lowertext(src.DoseResource)]. Every bit you spend will cost you.</font>"
	if(by && !quiet)
		by << "<font color=#b07cff>[src] is dosed: [src.DoseStacks] of [QUINCY_DOSE_MAX], through their [lowertext(src.DoseResource)].</font>"
	return src.DoseStacks

/mob/proc/DoseSpend(res, spent)
	if(spent <= 0 || src.KO || !DoseNow() || src.DoseResource != res)
		return 0
	var/pct = QUINCY_DOSE_PCT * src.DoseStacks * spent / QUINCY_DOSE_PER
	if(pct <= 0)
		return 0
	if(src.DoseNagAt <= world.time)
		src.DoseNagAt = world.time + QUINCY_DOSE_NAG
		src << "<font color=#b07cff>Poisoned by what you rely on.</font>"
	DamageSelf(pct)
	return pct

/proc/QuincyFormSignature(mob/m)
	if(!ismob(m))
		return null
	var/obj/Skills/Buffs/B = m.SpecialBuff
	return "[m.transActive]|[istype(B) ? B.type : ""]"

/mob/proc/DeathdealingImmuneTo(t)
	if(!t || !src.DeathdealingImmune)
		return 0
	var/list/e = src.DeathdealingImmune[t]
	if(!islist(e))
		return 0
	if(e[1] <= world.time)
		src.DeathdealingImmune -= t
		return 0
	var/mob/a = e[2]
	if(ismob(a) && QuincyFormSignature(a) != e[3])
		src.DeathdealingImmune -= t
		var/obj/Skills/S = t
		src << "<font color=#b07cff>[a] has changed. [initial(S.name)] can hurt you again.</font>"
		return 0
	return 1

/mob/proc/DeathdealingCount(t, mob/a)
	if(!ispath(t))
		return
	if(!src.DeathdealingHits)
		src.DeathdealingHits = list()
	var/n = src.DeathdealingHits[t]
	n = (n ? n : 0) + 1
	src.DeathdealingHits[t] = n
	if(n >= QUINCY_IMMUNE_HITS && !DeathdealingImmuneTo(t))
		src.DeathdealingHits[t] = 0
		if(!src.DeathdealingImmune)
			src.DeathdealingImmune = list()
		src.DeathdealingImmune[t] = list(world.time + QUINCY_IMMUNE_TIME, a, QuincyFormSignature(a))
		var/obj/Skills/S = t
		src << "<font color=#b07cff>Your body has tasted [initial(S.name)] three times. It does nothing to you now.</font>"
		if(ismob(a))
			a << "<font color=#b07cff>[src] no longer feels [initial(S.name)].</font>"
	DeathdealingWatch()

/mob/proc/DeathdealingWatch()
	set waitfor = 0
	var/gen = ++src.DeathdealingGen
	while(src && src.DeathdealingGen == gen && src.DeathdealingHits)
		sleep(10)
		if(!src || src.DeathdealingGen != gen)
			return
		if(QuincyFightIdle())
			src.DeathdealingHits = null
			return

/proc/QuincyMoveTile(mob/m, turf/T, sx, sy)
	if(!isturf(T))
		return null
	var/px = (T.x - 1) * 32 + sx + m.bound_x + m.bound_width / 2
	var/py = (T.y - 1) * 32 + sy + m.bound_y + m.bound_height / 2
	return locate(round(px / 32) + 1, round(py / 32) + 1, T.z)

/proc/QuincyGiftRingsLive()
	if(!QuincyGiftRings)
		return list()
	var/list/keep = list()
	for(var/datum/QuincyGiftRing/R in QuincyGiftRings)
		if(R.until > world.time && R.center)
			keep += R
	QuincyGiftRings = keep
	return keep

/mob/proc/GiftRingHolds(turf/dest)
	if(!src.DoseStacks || !QuincyGiftRings || !QuincyGiftRings.len || !DoseNow())
		return 0
	var/turf/here = QuincyMoveTile(src, src.loc, src.step_x, src.step_y)
	if(!here || !dest)
		return 0
	for(var/datum/QuincyGiftRing/R in QuincyGiftRingsLive())
		if(R.center.z != here.z || get_dist(here, R.center) > R.radius)
			continue
		if(dest.z != R.center.z || get_dist(dest, R.center) > R.radius)
			return 1
	return 0

/mob/proc/GiftRingRefuse(atom/NewLoc, sx, sy)
	if(!src.DoseStacks || !QuincyGiftRings || !QuincyGiftRings.len || !isturf(NewLoc))
		return 0
	if(!GiftRingHolds(QuincyMoveTile(src, NewLoc, sx, sy)))
		return 0
	if(src.GiftNagAt <= world.time)
		src.GiftNagAt = world.time + QUINCY_DOSE_NAG
		src << "<font color=#b07cff>The ring of poison will not let you out.</font>"
	return 1

/mob/proc/GiftBereichRaise(ds)
	var/turf/c = get_turf(src)
	if(!c)
		return 0
	var/datum/QuincyGiftRing/R = new
	R.center = c
	R.until = world.time + ds
	R.owner = src
	R.posts = list()
	for(var/i = 0 to QUINCY_BEREICH_POSTS - 1)
		var/ang = i * 360 / QUINCY_BEREICH_POSTS
		var/tx = clamp(c.x + round(R.radius * cos(ang), 1), 1, world.maxx)
		var/ty = clamp(c.y + round(R.radius * sin(ang), 1), 1, world.maxy)
		var/turf/T = locate(tx, ty, c.z)
		if(T)
			R.posts += new /obj/Effects/Quincy_Gift_Ring(T)
	if(!QuincyGiftRings)
		QuincyGiftRings = list()
	QuincyGiftRings += R
	OMsg(src, "[src] raises Gift Bereich. The poisoned cannot leave it.")
	QuincyGiftRingFade(R)
	return R.posts.len

/proc/QuincyGiftRingFade(datum/QuincyGiftRing/R)
	set waitfor = 0
	sleep(max(1, R.until - world.time))
	QuincyGiftRingDrop(R)

/proc/QuincyGiftRingDrop(datum/QuincyGiftRing/R)
	if(QuincyGiftRings)
		QuincyGiftRings -= R
	for(var/obj/Effects/Quincy_Gift_Ring/o in R.posts)
		del o
	R.posts = null
	R.center = null
	R.owner = null

/mob/proc/GiftDeluxeRaise(ds)
	set waitfor = 0
	var/turf/c = get_turf(src)
	if(!c)
		return
	var/obj/Effects/Quincy_Gift_Zone/z = new(c)
	OMsg(src, "[src] swells Gift Ball Deluxe over the field!")
	var/ticks = max(1, round(ds / QUINCY_DELUXE_TICK))
	for(var/i = 1 to ticks)
		sleep(QUINCY_DELUXE_TICK)
		if(!src)
			break
		for(var/mob/m in view(QUINCY_DELUXE_RADIUS, c))
			if(!m.KO && QuincyAreaFoe(m, src))
				m.DoseAdd(src, 1)
	if(z)
		del z

/mob/proc/GiftRingClose(mob/t)
	if(!ismob(t) || t.DoseBy != src || t.DoseNow() < QUINCY_RING_NEED)
		return 0
	DisarmTarget(t)
	t.QuincyMaimOnce(src)
	OMsg(src, "Gift Ring closes around [t]!")
	t.DamageSelf(QUINCY_RING_PCT)
	return 1

/mob/Players/LoseMana(var/val, var/Override=0)
	var/before = src.ManaAmount
	. = ..()
	if(src.DoseStacks)
		DoseSpend("Mana", before - src.ManaAmount)

/mob/Players/LoseEnergy(var/val, _static = FALSE)
	var/before = src.Energy
	. = ..()
	if(src.DoseStacks)
		DoseSpend("Energy", before - src.Energy)

/mob/Player/AI/LoseMana(var/val, var/Override=0)
	var/before = src.ManaAmount
	. = ..()
	if(src.DoseStacks)
		DoseSpend("Mana", before - src.ManaAmount)

/mob/Player/AI/LoseEnergy(var/val, _static = FALSE)
	var/before = src.Energy
	. = ..()
	if(src.DoseStacks)
		DoseSpend("Energy", before - src.Energy)

/mob/Players/Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
	if(GiftRingRefuse(NewLoc, sx, sy))
		return 0
	return ..()

/mob/Player/AI/Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
	if(GiftRingRefuse(NewLoc, sx, sy))
		return 0
	return ..()

/mob/Players/QuincyDamageTakenMult(skilltype)
	. = ..()
	if(skilltype && src.DeathdealingImmune && SchriftNeeded("D") && DeathdealingImmuneTo(skilltype))
		. = 0

/strikeHook/quincyDeathdealing
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0)
			return
		if(istype(S.skill, /obj/Skills/Projectile/Quincy/Gift_Ball) && a.QuincySchrift == "D" && a.SchriftNeeded("D"))
			d.DoseAdd(a)
		if(istype(S.skill, /obj/Skills) && d.QuincySchrift == "D" && d.SchriftNeeded("D"))
			d.DeathdealingCount(S.skill.type, a)

/obj/Skills/Projectile/Quincy/Gift_Ball
	name = "Gift Ball"
	desc = "A slow, homing orb of poison. Each hit doses the target: whenever it spends the resource it relies on, it loses health."
	Speed = 1
	Homing = 2
	DamageMult = 0.2
	Cooldown = 8
	ManaCost = 4
	Variation = 0
	Copyable = 0
	IconLock = 'Icons/Effects/SparkleArcane.dmi'
	ActiveMessage = "looses a Gift Ball!"

	verb/Gift_Ball()
		set name = "Gift Ball"
		set category = "Skills"
		if(!usr.SchriftNeeded("D"))
			usr << "Only the bearer of The Deathdealing can brew a Gift Ball."
			return
		if(!usr.XAxisTarget())
			usr << "You need a target."
			return
		usr.UseProjectile(src)

/obj/Skills/Quincy/Gift_Bereich
	name = "Gift Bereich"
	desc = "In Hasshein only: a ring of poison around you for 12 seconds. Anyone may step in; a dosed body cannot walk out."
	Cooldown = 60
	Copyable = 0
	var/seconds = QUINCY_BEREICH_TIME

	verb/Gift_Bereich()
		set name = "Gift Bereich"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		BereichFire(User)

	proc/BereichFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("D"))
			User << "Only the bearer of The Deathdealing can raise Gift Bereich."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "Gift Bereich rises only in Hasshein."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		if(!User.GiftBereichRaise(src.seconds))
			return 0
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Gift_Ball_Deluxe
	name = "Gift Ball Deluxe"
	desc = "In Hasshein only: a field of poison 6 tiles around you. Every 2 seconds for 10 seconds, every foe inside takes a dose."
	Cooldown = 90
	Copyable = 0
	var/seconds = QUINCY_DELUXE_TIME

	verb/Gift_Ball_Deluxe()
		set name = "Gift Ball Deluxe"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		DeluxeFire(User)

	proc/DeluxeFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("D"))
			User << "Only the bearer of The Deathdealing can swell Gift Ball Deluxe."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "Gift Ball Deluxe swells only in Hasshein."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		User.GiftDeluxeRaise(src.seconds)
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Quincy/Gift_Ring
	name = "Gift Ring"
	desc = "In Hasshein only, on a target carrying 5 of your doses: the ring closes. It disarms them, maims them, and takes a quarter of their health."
	Cooldown = 45
	Copyable = 0

	verb/Gift_Ring()
		set name = "Gift Ring"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		RingFire(User)

	proc/RingFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("D"))
			User << "Only the bearer of The Deathdealing can close the Gift Ring."
			return 0
		if(!User.QuincyVollstandigOnNow())
			User << "The Gift Ring closes only in Hasshein."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.XAxisTarget()
		if(!t)
			User << "You need a target."
			return 0
		var/n = t.DoseBy == User ? t.DoseNow() : 0
		if(n < QUINCY_RING_NEED)
			User << "[t] carries [n] of your doses. You need [QUINCY_RING_NEED]."
			return 0
		if(!User.GiftRingClose(t))
			return 0
		src.Cooldown(1, null, User)
		return 1

/proc/QuincyTestStepsD()
	return list("Dose target x5", "Make target spend 10 Mana", "Make target spend 10 Energy", "Gift Bereich", "Gift Ball Deluxe", "Gift Ring")

/mob/proc/QuincyTestD(step, mob/t)
	switch(step)
		if("Dose target x5")
			if(!t)
				return "no target"
			for(var/i = 1 to QUINCY_DOSE_MAX)
				t.DoseAdd(src, 1)
			return "dose [t.DoseNow()] through [t.DoseResource]"
		if("Make target spend 10 Mana")
			if(!t)
				return "no target"
			var/before = t.HealthPct()
			t.LoseMana(10)
			return "health [round(before, 0.1)] to [round(t.HealthPct(), 0.1)]"
		if("Make target spend 10 Energy")
			if(!t)
				return "no target"
			var/before = t.HealthPct()
			t.LoseEnergy(10)
			return "health [round(before, 0.1)] to [round(t.HealthPct(), 0.1)]"
		if("Gift Bereich")
			return "posts [GiftBereichRaise(QUINCY_BEREICH_TIME)]"
		if("Gift Ball Deluxe")
			GiftDeluxeRaise(QUINCY_DELUXE_TIME)
			return "zone raised"
		if("Gift Ring")
			if(!t)
				return "no target"
			return "closed [GiftRingClose(t)]"
	return "unknown step"

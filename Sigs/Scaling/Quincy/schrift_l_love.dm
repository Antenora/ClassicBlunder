#define QUINCY_L_SHOT_CHARM 5
#define QUINCY_L_KISS_CHARM 8
#define QUINCY_L_NEAREST 5

mob/var/tmp/mob/LoveCharmBy
mob/var/tmp/LoveCharmUntil = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/L_The_Love/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/Love_Shot, /obj/Skills/Projectile/Quincy/Love_Kiss, /obj/Skills/AutoHit/Quincy/Love_Rope)

/mob/proc/LoveRefuses(atom/t)
	return src.LoveCharmBy && t == src.LoveCharmBy && src.LoveCharmUntil > world.time

/mob/proc/LoveImmune(mob/d)
	if(d.isRace(ANDROID) || d.Mechanized || d.CyberCancel)
		return 1
	return 0

/mob/proc/LoveNearest(mob/charmer, range)
	var/mob/best
	var/bd = range + 1
	for(var/mob/m in range(range, src))
		if(m == src || m == charmer || m.KO || m.Dead || !m.passive_handler || m.z != src.z)
			continue
		if(istype(m, /mob/irlNPC) || istype(m, /mob/Body))
			continue
		var/dd = get_dist(src, m)
		if(dd < bd)
			bd = dd
			best = m
	return best

/mob/proc/LoveStrike(mob/d, secs, range)
	if(!ismob(d) || d == src)
		return 0
	if(istype(d, /mob/Player/AI/Quincy_Zombie))
		var/mob/Player/AI/Quincy_Zombie/z = d
		if(z.ai_owner == src)
			return 0
		return z.ZombieSwapOwner(src) ? 2 : 0
	if(d.KO)
		return 0
	if(LoveImmune(d))
		src << "<font color=#ff7ab8>[d] has no heart for Love to win.</font>"
		return 0
	d.applyCharmed(src, secs)
	d.LoveCharmBy = src
	d.LoveCharmUntil = world.time + secs * 10
	d.LoveCharmEnd(src, d.LoveCharmUntil)
	var/mob/n = d.LoveNearest(src, range)
	if(n)
		d.NamekTargetLock(n, secs)
	if(d.Target == src)
		d.RemoveTarget()
	if(d.EquippedSword())
		DisarmTarget(d)
		if(d.passive_handler && d.passive_handler.Get("Disarmed"))
			d.disarm_timer = max(d.disarm_timer, secs)
			d << "<font color=#ff7ab8>Your blade has a heart too. It slips from your hand.</font>"
	OMsg(src, "[d] falls head over heels for [src]!")
	return 1

/mob/proc/LoveCharmEnd(mob/charmer, until)
	set waitfor = 0
	sleep(max(1, until - world.time + 1))
	if(!src || src.LoveCharmBy != charmer || src.LoveCharmUntil != until)
		return
	src.LoveCharmBy = null
	src.LoveCharmUntil = 0
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed/c = locate() in src
	if(c && c.charmer == charmer && src.BuffOn(c))
		c.Trigger(src, TRUE)

/mob/Players/SetTarget(atom/target)
	if(target && LoveRefuses(target))
		return
	return ..()

/mob/Player/AI/SetTarget(atom/target)
	if(target && LoveRefuses(target))
		return
	return ..()

/mob/Players/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, list/dmgTypes, strike/S = null)
	if(defender && defender != src && LoveRefuses(defender))
		return 0
	return ..()

/mob/Player/AI/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, list/dmgTypes, strike/S = null)
	if(defender && defender != src && LoveRefuses(defender))
		return 0
	return ..()

/strikeHook/quincyLove
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0 || S.didBlock)
			return
		var/secs
		var/range
		if(istype(S.skill, /obj/Skills/Projectile/Quincy/Love_Shot))
			var/obj/Skills/Projectile/Quincy/Love_Shot/L = S.skill
			secs = L.charm_seconds
			range = L.lock_range
		else if(istype(S.skill, /obj/Skills/Projectile/Quincy/Love_Kiss))
			var/obj/Skills/Projectile/Quincy/Love_Kiss/K = S.skill
			secs = K.charm_seconds
			range = K.lock_range
		else
			return
		if(!a.SchriftNeeded("L"))
			return
		a.LoveStrike(d, secs, range)

/obj/Skills/Projectile/Quincy/Love_Shot
	name = "Love Shot"
	desc = "A heart-shaped shot. On a clean hit the target is charmed for 5 seconds: they cannot target or hurt you, and they turn on whoever stands nearest them. A charmed sword user drops the blade. A block or a parry negates it, and a body with no heart is immune. A zombie it hits becomes yours."
	DamageMult = 0.3
	Speed = 0.3
	Distance = 10
	Cooldown = 12
	ManaCost = 5
	Dodgeable = 1
	Deflectable = 1
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	ActiveMessage = "fires a Love Shot!"
	var/charm_seconds = QUINCY_L_SHOT_CHARM
	var/lock_range = QUINCY_L_NEAREST

	verb/Love_Shot()
		set name = "Love Shot"
		set category = "Skills"
		if(!usr.SchriftNeeded("L"))
			usr << "Only the bearer of The Love can fire this."
			return
		usr.UseProjectile(src)

/obj/Skills/Projectile/Quincy/Love_Kiss
	name = "Love Kiss"
	desc = "A wider heart. On a clean hit the target is charmed for 8 seconds: they cannot target or hurt you, and they turn on whoever stands nearest them. A charmed sword user drops the blade. A block or a parry negates it, and a body with no heart is immune. A zombie it hits becomes yours."
	DamageMult = 0.5
	Speed = 0.3
	Distance = 10
	Cooldown = 30
	ManaCost = 5
	Dodgeable = 1
	Deflectable = 1
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1.5
	LockX = 0
	LockY = 0
	Variation = 0
	ActiveMessage = "blows a Love Kiss!"
	var/charm_seconds = QUINCY_L_KISS_CHARM
	var/lock_range = QUINCY_L_NEAREST

	verb/Love_Kiss()
		set name = "Love Kiss"
		set category = "Skills"
		if(!usr.SchriftNeeded("L"))
			usr << "Only the bearer of The Love can blow this kiss."
			return
		usr.UseProjectile(src)

/obj/Skills/AutoHit/Quincy/Love_Rope
	name = "Love Rope"
	desc = "In Gudoero only: a chain of hearts lashes your target through their guard and binds them for 5 seconds."
	Area = "Target"
	Distance = 6
	GuardBreak = 1
	Snaring = 5
	DamageMult = 1
	Cooldown = 25
	Copyable = 0
	ActiveMessage = "binds their target in the Love Rope!"

	verb/Love_Rope()
		set name = "Love Rope"
		set category = "Skills"
		if(!usr.SchriftNeeded("L"))
			usr << "Only the bearer of The Love can throw the Love Rope."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "The Love Rope answers only in Gudoero."
			return
		if(!usr.XAxisTarget())
			usr << "Love Rope needs a target."
			return
		usr.Activate(src)

/proc/QuincyTestStepsL()
	return list("Charm target", "Charm target with a kiss", "Name the nearest to target", "Steal the nearest zombie")

/mob/proc/QuincyTestL(step, mob/t)
	switch(step)
		if("Charm target")
			if(!t)
				return "no target"
			return "charmed [LoveStrike(t, QUINCY_L_SHOT_CHARM, QUINCY_L_NEAREST)], target now [t.Target]"
		if("Charm target with a kiss")
			if(!t)
				return "no target"
			return "charmed [LoveStrike(t, QUINCY_L_KISS_CHARM, QUINCY_L_NEAREST)], target now [t.Target]"
		if("Name the nearest to target")
			if(!t)
				return "no target"
			return "nearest [t.LoveNearest(src, QUINCY_L_NEAREST)]"
		if("Steal the nearest zombie")
			var/mob/Player/AI/Quincy_Zombie/best
			var/bd = 99
			for(var/mob/Player/AI/Quincy_Zombie/z in range(10, src))
				if(z.ai_owner != src && get_dist(src, z) < bd)
					best = z
					bd = get_dist(src, z)
			if(!best)
				return "no zombie in range"
			return "stolen [LoveStrike(best, QUINCY_L_SHOT_CHARM, QUINCY_L_NEAREST)]"
	return "unknown step"

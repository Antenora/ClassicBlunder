#define QUINCY_H_TIER_MAX 5
#define QUINCY_H_COLD_STEP 5
#define QUINCY_H_LAVA_TICKS 80
#define QUINCY_H_LAVA_BURN 1
#define QUINCY_H_TRAIL_TICKS 30
#define QUINCY_H_FORM_SHOTS 3
#define QUINCY_H_FORM_DELAY 3

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/H_The_Heat/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/Burner_Finger, /obj/Skills/AutoHit/Quincy/Burning_Stomp)

/mob/proc/HeatTier(benefit)
	var/tier = 1 + round(clamp(benefit, 0, 1) * (QUINCY_H_TIER_MAX - 1))
	var/cap = QUINCY_H_TIER_MAX - round(max(0, src.Slow) / QUINCY_H_COLD_STEP)
	if(tier > cap)
		src << "The cold numbs your fingers."
	return clamp(min(tier, cap), 1, QUINCY_H_TIER_MAX)

/mob/proc/QuincyLavaPatch(turf/t, ticks, radius = 1)
	if(!isturf(t) || ticks <= 0)
		return 0
	var/list/L = SpawnFireGround(t, ticks, QUINCY_H_LAVA_BURN, 0, radius)
	return islist(L) ? L.len : 0

/obj/Skills/Projectile/Quincy/Burner_Finger
	name = "Burner Finger"
	desc = "Hold to raise fingers of flame, one a second, up to five. One: a piercing beam through guards. Two: a sweep that detonates. Three: the ground melts into lava where it lands. Four: a fire blade. Five: Burning Full Fingers. Chill on your body lowers the fingers you can raise."
	HeldSkill = TRUE
	ChargePeriod = 5
	NoFizzle = 1
	Cooldown = 10
	ManaCost = 5
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ChargeMessage = "raises a finger of flame..."
	var/tmp/list/fingers

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		return HeatFire(p, p.HeatTier(benefit))

	proc/HeatShot(tier)
		var/list/types = list(/obj/Skills/Projectile/Quincy/Burner_Finger_One, /obj/Skills/Projectile/Quincy/Burner_Finger_Sweep, /obj/Skills/Projectile/Quincy/Burner_Finger_Melt, /obj/Skills/AutoHit/Quincy/Fire_Blade, /obj/Skills/AutoHit/Quincy/Burning_Full_Fingers)
		if(tier < 1 || tier > types.len)
			return null
		if(!fingers)
			fingers = list()
		var/T = types[tier]
		var/obj/Skills/S = fingers[T]
		if(!S)
			S = new T
			fingers[T] = S
		return S

	proc/HeatFire(mob/p, tier)
		var/obj/Skills/S = HeatShot(tier)
		if(!S)
			return 0
		var/form = tier == 1 && p.QuincyVollstandigOnNow()
		if(form)
			var/obj/Skills/Projectile/Quincy/Burner_Finger_One/one = S
			one.Blasts = QUINCY_H_FORM_SHOTS
			one.Delay = QUINCY_H_FORM_DELAY
		var/stamp = S.cooldown_start_wt
		var/fired = p.last_skill_fire_time
		if(istype(S, /obj/Skills/AutoHit))
			p.Activate(S, noGCD = TRUE)
		else
			p.UseProjectile(S, noGCD = TRUE)
		if(form)
			var/obj/Skills/Projectile/Quincy/Burner_Finger_One/one = S
			one.Blasts = initial(one.Blasts)
			one.Delay = initial(one.Delay)
		if(S.cooldown_start_wt == stamp && p.last_skill_fire_time == fired)
			return 0
		src.Cooldown(1, null, p)
		return 1

	verb/Burner_Finger()
		set name = "Burner Finger"
		set category = "Skills"
		if(!usr.SchriftNeeded("H"))
			usr << "Only the bearer of The Heat can raise Burner Finger."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/Projectile/Quincy/Burner_Finger_One
	name = "Burner Finger"
	Blasts = 1
	Piercing = 1
	ShieldPierce = 1
	Burning = 2
	DamageMult = 1.2
	Distance = 10
	Speed = 0.15
	Cooldown = 1
	ManaCost = 5
	NoGCD = 1
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ActiveMessage = "looses a piercing Burner Finger!"

/obj/Skills/Projectile/Quincy/Burner_Finger_Sweep
	name = "Burner Finger"
	Blasts = 3
	SpreadArc = 30
	Explode = 1
	Burning = 2
	DamageMult = 0.8
	Distance = 10
	Cooldown = 1
	ManaCost = 5
	NoGCD = 1
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ActiveMessage = "sweeps two fingers of flame!"

/obj/Skills/Projectile/Quincy/Burner_Finger_Melt
	name = "Burner Finger"
	DamageMult = 1
	Distance = 10
	Speed = 0.3
	Cooldown = 1
	ManaCost = 5
	NoGCD = 1
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	ActiveMessage = "points three fingers of flame, and the ground ahead begins to melt!"
	var/lava_ticks = QUINCY_H_LAVA_TICKS

/obj/Skills/AutoHit/Quincy/Fire_Blade
	name = "Burner Finger"
	Area = "Arc"
	Distance = 3
	DamageMult = 2.2
	Scorching = 1
	ForScaling = 1
	Cooldown = 1
	ManaCost = 5
	NoGCD = 1
	Copyable = 0
	HitSparkIcon = 'Slash - Hellfire.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkTurns = 1
	HitSparkSize = 1
	ActiveMessage = "draws four fingers of flame into a burning blade!"

/obj/Skills/AutoHit/Quincy/Burning_Full_Fingers
	name = "Burning Full Fingers"
	Area = "Arc"
	Distance = 4
	DamageMult = 2.5
	Scorching = 2
	ForScaling = 1
	Cooldown = 1
	ManaCost = 5
	NoGCD = 1
	Copyable = 0
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkSize = 0.5
	ActiveMessage = "raises every finger: Burning Full Fingers!"

/obj/Skills/AutoHit/Quincy/Burning_Stomp
	name = "Burning Stomp"
	desc = "Stomp the ground and burst into flame around you."
	Area = "Circle"
	Distance = 2
	DamageMult = 1.3
	Scorching = 1
	ForScaling = 1
	Cooldown = 15
	ManaCost = 4
	Copyable = 0
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkSize = 0.5
	ActiveMessage = "stomps, and the ground bursts into flame!"

	verb/Burning_Stomp()
		set name = "Burning Stomp"
		set category = "Skills"
		if(!usr.SchriftNeeded("H"))
			usr << "Only the bearer of The Heat can stomp the ground into flame."
			return
		usr.Activate(src)

turf/Click(turf/T)
	var/mob/u = usr
	var/turf/origin = (ismob(u) && u.QuincySchrift == "H") ? get_turf(u) : null
	. = ..()
	if(!origin || !u || get_turf(u) == origin)
		return
	if(!u.SchriftNeeded("H") || !u.QuincyVollstandigOnNow())
		return
	u.QuincyLavaPatch(origin, QUINCY_H_TRAIL_TICKS, 0)

/proc/QuincyTestStepsH()
	return list("Finger 1", "Finger 2", "Finger 3", "Finger 4", "Finger 5", "Lava under target", "Burning Stomp", "Chill 10 then Finger 5")

/mob/proc/QuincyHeatTestFire(n)
	var/obj/Skills/Projectile/Quincy/Burner_Finger/B = locate() in src
	if(!B)
		B = new
	if(B.Using || B.cooldown_remaining > 0)
		B.Using = 0
		B.cooldown_remaining = 0
		B.cooldown_start_wt = 0
	var/tier = HeatTier((n - 1) / (QUINCY_H_TIER_MAX - 1))
	var/r = B.HeatFire(src, tier)
	return "tier [tier] fired [r]"

/mob/proc/QuincyTestH(step, mob/t)
	switch(step)
		if("Finger 1")
			return QuincyHeatTestFire(1)
		if("Finger 2")
			return QuincyHeatTestFire(2)
		if("Finger 3")
			return QuincyHeatTestFire(3)
		if("Finger 4")
			return QuincyHeatTestFire(4)
		if("Finger 5")
			return QuincyHeatTestFire(5)
		if("Lava under target")
			if(!t)
				return "no target"
			return "lava tiles [QuincyLavaPatch(get_turf(t), QUINCY_H_LAVA_TICKS, 1)]"
		if("Burning Stomp")
			var/obj/Skills/AutoHit/Quincy/Burning_Stomp/S = locate() in src
			if(!S)
				S = new
			Activate(S)
			return "stomped"
		if("Chill 10 then Finger 5")
			src.Slow = 10
			return QuincyHeatTestFire(5)
	return "unknown step"

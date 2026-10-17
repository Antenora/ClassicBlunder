#define QUINCY_X_CRISIS_PCT 30
#define QUINCY_X_CRISIS_NEED 3
#define QUINCY_X_LAST_STAND_PCT 10
#define QUINCY_X_INTANGIBLE 80
#define QUINCY_X_NAG 10
#define QUINCY_X_RANGE_BONUS 4
#define QUINCY_X_MODEL_DAMAGE 1.3

obj/Skills/Projectile/var/QuincyReflectsHome = 0

mob/var/XDensityRestore = 0
mob/var/tmp/XCrisisCount = 0
mob/var/tmp/XCrisisGen = 0
mob/var/tmp/XIntangibleUntil = 0
mob/var/tmp/XIntangibleGen = 0
mob/var/tmp/XNagAt = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/X_The_X_Axis/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/X_Axis_Shot, /obj/Skills/Quincy/Open_Both_Eyes, /obj/Skills/Projectile/Quincy/Trompete)

obj/Items/Gun/Quincy/Diagramm
	name = "Diagramm"
	ModelDamage = QUINCY_X_MODEL_DAMAGE
	var/range_bonus = QUINCY_X_RANGE_BONUS

obj/Items/Gun/Quincy/Diagramm/New()
	GunClass = QuincyGunClass(/obj/Items/Gun/Handgun)
	..()

obj/Items/Gun/Quincy/Diagramm/ConjureShape(mob/p)
	..()
	if(!p)
		return
	GunClass = QuincyGunClass(/obj/Items/Gun/Handgun)
	ModelSpeed = 1
	ModelDamage = initial(ModelDamage) * (1 + 0.1 * (max(1, p.QuincyLevel) - 1))
	setStatLine()
	EnergyReset()

obj/Items/Gun/Quincy/Diagramm/ClassRange()
	return ..() + range_bonus

/mob/proc/XWeaponResync()
	var/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/W = locate() in src
	if(!W || !src.BuffOn(W))
		return 0
	var/want = src.SchriftNeeded("X") ? 1 : 0
	var/have = (W.MakesGun && W.GunPath == /obj/Items/Gun/Quincy/Diagramm) ? 1 : 0
	if(want == have)
		return 0
	W.Trigger(src, 1)
	src << "Your Spirit Weapon comes apart in your hands. Draw it again."
	return 1

/mob/Players/QuincySyncSkills()
	..()
	XWeaponResync()
	if(src.XIntangibleUntil && !SchriftNeeded("X"))
		XIntangibleEnd(1)

/mob/proc/XCrisisNow()
	if(src.XCrisisCount && QuincyFightIdle())
		src.XCrisisCount = 0
	return src.XCrisisCount

/mob/proc/XCrisisAdd()
	src.XCrisisCount++
	if(src.XCrisisCount == QUINCY_X_CRISIS_NEED)
		src << "<font color=#9fd8ff>You have stood at the edge [QUINCY_X_CRISIS_NEED] times. Both eyes can open now.</font>"
	XCrisisWatch()

/mob/proc/XCrisisWatch()
	set waitfor = 0
	var/gen = ++src.XCrisisGen
	while(src && src.XCrisisGen == gen && src.XCrisisCount)
		sleep(10)
		if(!src || src.XCrisisGen != gen)
			return
		if(QuincyFightIdle())
			src.XCrisisCount = 0
			return

/mob/proc/XEyesReady()
	return XCrisisNow() >= QUINCY_X_CRISIS_NEED || HealthPct() < QUINCY_X_LAST_STAND_PCT

/mob/proc/XIntangibleNow()
	return src.XIntangibleUntil > world.time

/mob/proc/XOpenEyes(ds)
	set waitfor = 0
	if(!src.XDensityRestore)
		src.XDensityRestore = (src.density ? 1 : 0) + 1
	src.density = 0
	src.XIntangibleUntil = world.time + ds
	var/gen = ++src.XIntangibleGen
	OMsg(src, "[src] opens both eyes. Nothing can touch them, and they can touch nothing.")
	sleep(ds)
	if(src && src.XIntangibleGen == gen)
		XIntangibleEnd()

/mob/proc/XIntangibleEnd(quiet = 0)
	src.XIntangibleGen++
	src.XIntangibleUntil = 0
	if(src.XDensityRestore)
		src.density = src.XDensityRestore - 1
		src.XDensityRestore = 0
	if(!quiet)
		OMsg(src, "[src] closes one eye. They are solid again.")

/mob/proc/XRefuse()
	if(src.XNagAt > world.time)
		return
	src.XNagAt = world.time + QUINCY_X_NAG
	src << "You touch nothing, and nothing touches you."

/mob/proc/QuincyReflectsShot(obj/Skills/Projectile/_Projectile/P)
	if(src.passive_handler && src.passive_handler["RoyalGuarding"])
		return 1
	if(!src.HasDeflection())
		return 0
	return !Deflection_Formula(P.Owner, src, P.AccMult * 0.1 / (1 + src.GetDeflection()), BaseChance = glob.WorldDefaultAcc)

/mob/proc/QuincyReflectHome(obj/Skills/Projectile/_Projectile/P, mob/o)
	P.QuincyReflected = 1
	P.TransferOwner(src)
	P.Homing = o
	P.forcedTarget = o
	P.HyperHoming = 0
	P.Distance = max(P.Distance, P.DistanceMax, get_dist(src, o) + 2)
	FlashDeflect(src, P)
	OMsg(src, "[src] turns the line back on [o]!")

/mob/Players/Login()
	..()
	if(src.XDensityRestore)
		src.density = src.XDensityRestore - 1
		src.XDensityRestore = 0
		src.XIntangibleUntil = 0

/mob/Players/Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
	if(!src.XDensityRestore || !XIntangibleNow())
		return ..()
	src.density = src.XDensityRestore - 1
	. = ..()
	if(src && XIntangibleNow())
		src.density = 0

/mob/Players/FireGun(obj/Items/Gun/g)
	if(XIntangibleNow())
		XRefuse()
		return 0
	return ..()

/mob/Players/UseProjectile(var/obj/Skills/Projectile/Z, noGCD = FALSE)
	if(XIntangibleNow())
		XRefuse()
		return 0
	return ..()

/mob/Players/Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE, ignoreAttackLock = FALSE, noGCD = FALSE, noAdjust = FALSE)
	if(XIntangibleNow())
		XRefuse()
		return 0
	return ..()

/mob/Players/SetQueue(var/obj/Skills/Queue/Q, noGCD = FALSE)
	if(XIntangibleNow())
		XRefuse()
		return 0
	return ..()

/mob/Players/BeginHeldSkill(var/obj/Skills/Z)
	if(XIntangibleNow())
		XRefuse()
		return 0
	return ..()

/mob/Players/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, AsuraStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0, WhipOnly = 0)
	if(XIntangibleNow())
		XRefuse()
		return 0
	return ..()

/strikeHook/quincyXCrisis
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d == S.attacker || S.dealt <= 0 || d.QuincySchrift != "X" || !d.SchriftNeeded("X"))
			return
		var/now = d.HealthPct()
		if(now >= QUINCY_X_CRISIS_PCT || now + d.HPToPct(S.dealt) < QUINCY_X_CRISIS_PCT)
			return
		d.XCrisisAdd()

/proc/QuincyAimAngle(mob/p, mob/t)
	var/dx = ((t.x - 1) * 32 + t.step_x) - ((p.x - 1) * 32 + p.step_x)
	var/dy = ((t.y - 1) * 32 + t.step_y) - ((p.y - 1) * 32 + p.step_y)
	if(!dx && !dy)
		return GunDirAngle(p.dir)
	var/ang = arctan(dx, dy)
	while(ang < 0)
		ang += 360
	return ang

/proc/QuincyAimTiles(mob/p, mob/t)
	var/dx = ((t.x - 1) * 32 + t.step_x) - ((p.x - 1) * 32 + p.step_x)
	var/dy = ((t.y - 1) * 32 + t.step_y) - ((p.y - 1) * 32 + p.step_y)
	return sqrt(dx * dx + dy * dy) / 32

/mob/proc/XAxisTarget()
	var/mob/t = src.Target
	if(!ismob(t) || t == src || t.z != src.z)
		return null
	return t

/obj/Skills/Projectile/Quincy/X_Axis_Shot
	name = "X-Axis Shot"
	desc = "Take aim with Diagramm and fire a line at your target. It pierces everyone and everything up to the target and never past it, and it cannot be dodged or blocked. Only a reflection turns it back on you."
	HeldSkill = TRUE
	ChargePeriod = 1.5
	NoFizzle = 1
	Cooldown = 12
	ManaCost = 6
	DamageMult = 2.5
	Distance = 20
	Speed = 0.1
	Variation = 0
	Dodgeable = -1
	Deflectable = 0
	Piercing = 1
	ShieldPierce = 1
	EndEffectiveness = 0
	QuincyReflectsHome = 1
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	ChargeMessage = "levels Diagramm..."
	ActiveMessage = "fires along the X-Axis!"
	var/jilliel_lines = 6
	var/jilliel_arc = 30

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		var/mob/t = p.XAxisTarget()
		if(!t)
			p << "The X-Axis needs a target."
			return
		XAxisFire(p, t)

	proc/XAxisFire(mob/p, mob/t)
		Distance = max(1, QuincyAimTiles(p, t))
		FlightAngle = QuincyAimAngle(p, t)
		DirOverride = GunAngleDir(FlightAngle)
		if(p.QuincyVollstandigOnNow())
			Blasts = jilliel_lines
			SpreadArc = jilliel_arc
		. = p.UseProjectile(src)
		ResetHeldConfig()
		SpreadArc = initial(SpreadArc)
		FlightAngle = null
		DirOverride = 0

	verb/X_Axis_Shot()
		set name = "X-Axis Shot"
		set category = "Skills"
		if(!usr.SchriftNeeded("X"))
			usr << "Only the bearer of The X-Axis can fire this line."
			return
		if(!usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		if(!usr.XAxisTarget())
			usr << "The X-Axis needs a target."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/Quincy/Open_Both_Eyes
	name = "Open Both Eyes"
	desc = "Open both eyes for 8 seconds: nothing can touch you and you can touch nothing. It opens only after you have fallen below 30 percent health three times in one fight, or while you stand below 10 percent."
	Cooldown = 60
	Copyable = 0
	var/seconds = QUINCY_X_INTANGIBLE

	verb/Open_Both_Eyes()
		set name = "Open Both Eyes"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		EyesFire(User)

	proc/EyesFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("X"))
			User << "Only the bearer of The X-Axis can open both eyes."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		if(!User.XEyesReady())
			User << "Your second eye stays shut. Fall below 30 percent three times in this fight, or stand below 10 percent."
			return 0
		User.XOpenEyes(src.seconds)
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Projectile/Quincy/Trompete
	name = "Trompete"
	desc = "In Jilliel only: a huge line blast that pierces everything in its path. It cannot be dodged, but a reflection turns it back on you."
	Cooldown = 90
	DamageMult = 5
	Distance = 15
	Speed = 0.2
	Variation = 0
	Dodgeable = -1
	Deflectable = 0
	Piercing = 1
	QuincyReflectsHome = 1
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 3
	LockX = 0
	LockY = 0
	ActiveMessage = "sounds the Trompete!"

	verb/Trompete()
		set name = "Trompete"
		set category = "Skills"
		if(!usr.SchriftNeeded("X"))
			usr << "Only the bearer of The X-Axis can sound the Trompete."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "The Trompete sounds only in Jilliel."
			return
		var/mob/t = usr.XAxisTarget()
		if(t)
			FlightAngle = QuincyAimAngle(usr, t)
			DirOverride = GunAngleDir(FlightAngle)
		usr.UseProjectile(src)
		FlightAngle = null
		DirOverride = 0

/proc/QuincyTestStepsX()
	return list("Three crises", "Open Both Eyes", "Fire the X-Axis Shot", "Sound the Trompete", "Resync the weapon")

/mob/proc/QuincyTestX(step, mob/t)
	switch(step)
		if("Three crises")
			src.XCrisisCount = QUINCY_X_CRISIS_NEED
			src.QuincyFightAt = world.time
			XCrisisWatch()
			return "crises [src.XCrisisCount]"
		if("Open Both Eyes")
			XOpenEyes(QUINCY_X_INTANGIBLE)
			return "intangible until [src.XIntangibleUntil]"
		if("Fire the X-Axis Shot")
			if(!t)
				return "no target"
			var/obj/Skills/Projectile/Quincy/X_Axis_Shot/S = locate() in src
			if(!S)
				S = new
			return "fired [S.XAxisFire(src, t)]"
		if("Sound the Trompete")
			var/obj/Skills/Projectile/Quincy/Trompete/S = locate() in src
			if(!S)
				S = new
			if(t)
				S.FlightAngle = QuincyAimAngle(src, t)
				S.DirOverride = GunAngleDir(S.FlightAngle)
			. = "fired [src.UseProjectile(S)]"
			S.FlightAngle = null
			S.DirOverride = 0
			return .
		if("Resync the weapon")
			return "resynced [XWeaponResync()]"
	return "unknown step"

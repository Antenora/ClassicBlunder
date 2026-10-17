#define QUINCY_P_LIFT_REACH 1
#define QUINCY_P_LIFT_Y 28
#define QUINCY_P_THROW_LAUNCH 2
#define QUINCY_P_THROW_SAFETY 60
#define QUINCY_P_HALTERES_WINDOW 20
#define QUINCY_P_HALTERES_SWING 5
#define QUINCY_P_HALTERES_BONUS 0.5

mob/var/tmp/atom/movable/PowerLifted
mob/var/tmp/image/PowerLiftedImage
mob/var/tmp/PowerThrownDensity = 0
mob/var/tmp/PowerThrownAlpha = 255
mob/var/tmp/PowerInFlight = 0
mob/var/tmp/HalteresAt = 0
mob/var/tmp/HalteresSwingUntil = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/P_The_Power/New()
	..()
	kit_skills = list(/obj/Skills/Buffs/SlotlessBuffs/Quincy_Muscle, /obj/Skills/Quincy/Lift, /obj/Skills/AutoHit/Quincy/Diamond_Push)

/mob/proc/PowerLiftCandidates()
	var/list/out = list()
	for(var/obj/O in range(QUINCY_P_LIFT_REACH, src))
		if(!O.density || !O.Grabbable || !O.mouse_opacity)
			continue
		if(istype(O, /obj/Skills) || istype(O, /obj/Effects) || istype(O, /obj/Exchange/npc))
			continue
		if(istype(O, /obj/Items))
			var/obj/Items/I = O
			if(I.Pickable == 1)
				continue
		var/obj/Seal/s = locate(/obj/Seal) in O.contents
		if(s && s.Creator != src.ckey)
			continue
		out += O
	for(var/mob/m in range(QUINCY_P_LIFT_REACH, src))
		if(m == src || m.Dead)
			continue
		if(src.Grab == m || m.KO)
			out += m
	return out

/mob/proc/PowerLiftNow(atom/movable/A)
	if(!A || src.PowerLifted)
		return 0
	if(ismob(A))
		var/mob/m = A
		if(src.Grab != m)
			if(src.Grab)
				return 0
			src.Grab_Mob(m, Forced = 1)
			if(src.Grab != m)
				return 0
		src.PowerLifted = m
		OMsg(src, "[src] hoists [m] overhead!")
		return 1
	var/obj/O = A
	var/image/I = image(icon = O.icon, icon_state = O.icon_state)
	I.pixel_x = O.pixel_x
	I.pixel_y = O.pixel_y + QUINCY_P_LIFT_Y
	I.dir = O.dir
	src.PowerLiftedImage = I
	src.overlays += I
	O.loc = null
	src.PowerLifted = O
	OMsg(src, "[src] tears [O] free and lifts it overhead!")
	return 1

/mob/proc/PowerLiftOverlayOff()
	if(src.PowerLiftedImage)
		src.overlays -= src.PowerLiftedImage
		src.PowerLiftedImage = null

/mob/proc/PowerLiftDrop(quiet = 0)
	var/atom/movable/A = src.PowerLifted
	src.PowerLifted = null
	PowerLiftOverlayOff()
	if(!A)
		return 0
	if(ismob(A))
		if(src.Grab == A)
			src.Grab_Release()
	else
		var/turf/t = get_turf(src)
		if(t)
			A.loc = t
	if(!quiet)
		OMsg(src, "[src] sets [A] down.")
	return 1

/mob/proc/PowerThrowHide(mob/m)
	m.PowerInFlight = 1
	m.PowerThrownDensity = m.density
	m.PowerThrownAlpha = m.alpha
	m.density = 0
	m.alpha = 0
	m.Frozen = 1

/mob/proc/PowerThrowShow()
	if(!src.PowerInFlight)
		return
	src.PowerInFlight = 0
	src.density = src.PowerThrownDensity
	src.alpha = src.PowerThrownAlpha
	src.Frozen = 0

/proc/PowerThrowHit(mob/owner, mob/m, mult)
	if(!ismob(owner) || !ismob(m) || mult <= 0)
		return 0
	var/dp = m.Power
	if(dp <= 0)
		dp = 1
	var/powerDif = owner.Power / dp
	if(glob.CLAMP_POWER && !owner.ignoresPowerClamp(m))
		powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
	var/dmg = strikeCoreDamage(powerDif, owner.GetStr(1), m.getEndStat(1))
	dmg *= mult
	dmg *= m.ccProrationMult(owner, 0, 0)
	if(dmg <= 0)
		return 0
	var/strike/S = new(owner, m, dmg)
	. = S.resolve()
	if(m)
		m.ccCountHit()

/mob/proc/PowerThrow(obj/Skills/Quincy/Lift/L)
	var/atom/movable/A = src.PowerLifted
	if(!A)
		return 0
	if(ismob(A) && src.Grab != A)
		src.PowerLifted = null
		src << "You lost your hold."
		return 0
	var/obj/Skills/Projectile/Quincy/Thrown_Thing/P = L ? L.throw_skill : null
	if(!P)
		P = new
		if(L)
			L.throw_skill = P
	P.lifted = A
	P.thrower = src
	P.hit_turf = null
	P.IconLock = A.icon
	if(L)
		P.DamageMult = L.throw_mult
		P.Distance = L.throw_range
		P.Knockback = L.throw_knockback
	var/mob/t = XAxisTarget()
	if(t)
		P.FlightAngle = QuincyAimAngle(src, t)
		P.DirOverride = GunAngleDir(P.FlightAngle)
	if(ismob(A))
		PowerThrowHide(A)
	P.Using = 0
	src.UseProjectile(P, noGCD = TRUE)
	P.FlightAngle = null
	P.DirOverride = 0
	if(!src)
		return 0
	if(!P.Using)
		P.lifted = null
		if(ismob(A))
			var/mob/m = A
			m.PowerThrowShow()
		return 0
	src.PowerLifted = null
	PowerLiftOverlayOff()
	if(ismob(A) && src.Grab == A)
		src.Grab_Release()
	if(L)
		L.Cooldown(1, null, src)
	OMsg(src, "[src] hurls [A]!")
	PowerThrowSafety(P, A)
	return 1

/mob/proc/PowerThrowSafety(obj/Skills/Projectile/Quincy/Thrown_Thing/P, atom/movable/A)
	set waitfor = 0
	sleep(QUINCY_P_THROW_SAFETY)
	if(P && A && P.lifted == A)
		P.ThrownLand(get_turf(src))

/mob/Players/attackModifiers(mob/defender, list/forcedDmgList=list())
	. = ..()
	if(src.HalteresSwingUntil > world.time)
		src.HalteresSwingUntil = 0
		. += QUINCY_P_HALTERES_BONUS

/mob/Players/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, AsuraStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0, WhipOnly = 0)
	if(src.HalteresAt && world.time - src.HalteresAt <= QUINCY_P_HALTERES_WINDOW && SchriftNeeded("P") && QuincyVollstandigOnNow())
		src.HalteresAt = 0
		src.HalteresSwingUntil = world.time + QUINCY_P_HALTERES_SWING
	return ..()

turf/Click(turf/T)
	if(!usr || !usr.client || usr.QuincySchrift != "P")
		return ..()
	var/obj/Skills/Hoho/Hirenkyaku/s = locate(/obj/Skills/Hoho/Hirenkyaku) in usr.contents
	if(!s || !s.HirenkyakuToggle)
		return ..()
	var/mob/u = usr
	var/before = s.Charges
	var/turf/was = get_turf(u)
	. = ..()
	if(u && s && s.Charges < before && get_turf(u) != was)
		u.HalteresAt = world.time

/mob/proc/PowerDumbbellsOn()
	var/obj/Skills/Buffs/SlotlessBuffs/Quincy_Dumbbells/D = locate() in src
	if(!D)
		D = new
		src.AddSkill(D)
	if(!D.SlotlessOn)
		D.Trigger(src, 1)
	return D.SlotlessOn

/mob/proc/PowerDumbbellsOff()
	var/list/drop = list()
	for(var/obj/Skills/Buffs/SlotlessBuffs/Quincy_Dumbbells/D in src)
		drop += D
	for(var/obj/Skills/Buffs/SlotlessBuffs/Quincy_Dumbbells/D in drop)
		if(D.SlotlessOn)
			D.Trigger(src, 1)
		src.DeleteSkill(D)

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig) && SchriftNeeded("P"))
		PowerDumbbellsOn()

/mob/Players/AllSkillsRemove(obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig))
		PowerDumbbellsOff()

/mob/Players/Login()
	..()
	if(src.PowerInFlight)
		PowerThrowShow()
	spawn(50)
		if(src && !QuincyVollstandigOnNow())
			PowerDumbbellsOff()

/mob/Players/Logout()
	if(src.PowerLifted)
		PowerLiftDrop(1)
	..()

/mob/Players/QuincySyncSkills()
	..()
	if(!SchriftNeeded("P"))
		if(src.PowerLifted)
			PowerLiftDrop(1)
		PowerDumbbellsOff()

/mob/Players/QuincyFreeRegistry()
	..()
	if(src.PowerLifted)
		PowerLiftDrop(1)
	PowerDumbbellsOff()

/strikeHook/quincyThrownHit
	stage = "post"
	fire(strike/S)
		if(!istype(S.skill, /obj/Skills/Projectile/Quincy/Thrown_Thing) || !S.defender)
			return
		var/obj/Skills/Projectile/Quincy/Thrown_Thing/T = S.skill
		if(T.lifted && !T.hit_turf)
			T.hit_turf = get_turf(S.defender)

/strikeHook/quincyPowerKO
	stage = "ko"
	fire(strike/S)
		var/mob/d = S ? S.defender : null
		if(d && d.PowerLifted)
			d.PowerLiftDrop()

/obj/Skills/Buffs/SlotlessBuffs/Quincy_Muscle
	name = "Muscle"
	BuffName = "Quincy Muscle"
	desc = "Toggle. Reishi swells your muscles: Strength x1.5, Speed x0.8, and it leaks 1 Mana."
	StrMult = 1.5
	SpdMult = 0.8
	passives = list("ManaLeak" = 1)
	Copyable = 0
	ActiveMessage = "swells with Reishi-hardened muscle!"
	OffMessage = "lets their muscles settle."

	verb/Muscle()
		set name = "Muscle"
		set category = "Skills"
		if(!usr.BuffOn(src) && !usr.SchriftNeeded("P"))
			usr << "Only the bearer of The Power can swell like this."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Quincy_Dumbbells
	name = "Dumbbells"
	BuffName = "Dumbbells"
	desc = "Pornipora: Dumbbell Duster strikes twice and Baton Beat reaches farther. A melee swing within 2 seconds of a Hirenkyaku step hits harder."
	passives = list("DoubleStrike" = 1, "Extend" = 1)
	Copyable = 0
	ActiveMessage = "takes up the Dumbbells!"
	OffMessage = "lets the Dumbbells fade."

/obj/Skills/Quincy/Lift
	name = "Lift"
	desc = "Lift a dense object beside you, or a body you hold or one that is knocked out. Use it again to throw what you hold: it flies at your target and lands where it stops."
	Cooldown = 15
	Copyable = 0
	var/throw_mult = 1.5
	var/throw_range = 8
	var/throw_knockback = 3
	var/launch_time = QUINCY_P_THROW_LAUNCH
	var/tmp/obj/Skills/Projectile/Quincy/Thrown_Thing/throw_skill

	verb/Lift()
		set name = "Lift"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		LiftUse(User)

	proc/LiftUse(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("P"))
			User << "Only the bearer of The Power can lift like this."
			return 0
		if(User.PowerLifted)
			return User.PowerThrow(src)
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/list/cands = User.PowerLiftCandidates()
		if(!cands.len)
			User << "There is nothing beside you to lift."
			return 0
		var/atom/movable/A
		if(cands.len == 1)
			A = cands[1]
		else
			var/list/labels = PromptLabelAtoms(cands, 1)
			var/pick = Ask(User, "Lift what?", "Lift", null, "pick", labels, 1)
			if(isnull(pick))
				return 0
			A = labels[pick]
		if(!A || !(A in User.PowerLiftCandidates()))
			return 0
		return User.PowerLiftNow(A)

/obj/Skills/Projectile/Quincy/Thrown_Thing
	name = "Thrown"
	DamageMult = 1.5
	Knockback = 3
	Distance = 8
	Speed = 0.3
	UsesStr = 1
	StrScaling = 1
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	Copyable = 0
	Cooldown = 15
	var/tmp/atom/movable/lifted
	var/tmp/mob/thrower
	var/tmp/turf/hit_turf

	proc/ThrownLand(turf/t)
		var/atom/movable/A = src.lifted
		var/mob/o = src.thrower
		src.lifted = null
		if(src.hit_turf)
			t = src.hit_turf
		src.hit_turf = null
		if(!A)
			return 0
		if(!isturf(t) || t.density)
			t = o ? get_turf(o) : null
		if(!t)
			t = get_turf(A)
		if(ismob(A))
			var/mob/m = A
			if(t)
				m.loc = t
			m.step_x = 0
			m.step_y = 0
			m.PowerThrowShow()
			if(o && QuincyAreaFoe(m, o))
				PowerThrowHit(o, m, src.DamageMult)
				if(m && o)
					var/obj/Skills/Quincy/Lift/L = locate() in o
					LaunchEffect(o, m, L ? L.launch_time : QUINCY_P_THROW_LAUNCH)
			return 1
		if(t)
			A.loc = t
		return 1

/obj/Skills/AutoHit/Quincy/Diamond_Push
	name = "Diamond Push"
	desc = "Charge your target, seize them and shove them ten tiles away, stunned."
	Area = "Target"
	Distance = 6
	Rush = 5
	Grapple = 1
	GrabTrigger = "/obj/Skills/Grapple/Quincy/Diamond_Push"
	DamageMult = 1.2
	Cooldown = 25
	Copyable = 0
	ActiveMessage = "charges in with a Diamond Push!"

	verb/Diamond_Push()
		set name = "Diamond Push"
		set category = "Skills"
		if(!usr.SchriftNeeded("P"))
			usr << "Only the bearer of The Power can push like this."
			return
		if(!usr.XAxisTarget())
			usr << "Diamond Push needs a target."
			return
		usr.Activate(src)

/obj/Skills/Grapple/Quincy/Diamond_Push
	name = "Diamond Push"
	UnarmedOnly = 0
	NeedsSword = 0
	DamageMult = 0
	ThrowMult = 0
	ThrowAdd = 10
	Stunner = 1
	TriggerMessage = "drives a Diamond Push into"
	Effect = "Shockwave"
	EffectMult = 1
	Copyable = 0
	removeAfter = TRUE

/proc/QuincyTestStepsP()
	return list("Lift the nearest thing", "Throw", "Diamond Push target", "Halteres stamp", "Muscle")

/mob/proc/QuincyTestP(step, mob/t)
	switch(step)
		if("Lift the nearest thing")
			var/list/c = PowerLiftCandidates()
			if(!c.len)
				return "nothing to lift"
			return "lifted [PowerLiftNow(c[1])] [src.PowerLifted]"
		if("Throw")
			var/obj/Skills/Quincy/Lift/L = locate() in src
			if(!L)
				L = new
			return "thrown [PowerThrow(L)]"
		if("Diamond Push target")
			if(!t)
				return "no target"
			var/obj/Skills/AutoHit/Quincy/Diamond_Push/D = locate() in src
			if(!D)
				D = new
			return "pushed [src.Activate(D)]"
		if("Halteres stamp")
			src.HalteresAt = world.time
			return "stamped"
		if("Muscle")
			var/obj/Skills/Buffs/SlotlessBuffs/Quincy_Muscle/M = locate() in src
			if(!M)
				return "no Muscle skill"
			M.Trigger(src)
			return "muscle [src.BuffOn(M)]"
	return "unknown step"
